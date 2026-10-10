import 'dart:math' as math;
import 'package:comfort_care/core/services/nova_express_logistics_service.dart';
import 'package:comfort_care/features/cart/domain/entities/cart_item.dart';
import 'package:comfort_care/features/pharmacy_portal/data/repositories/mock_community_pharmacies.dart';
import 'package:comfort_care/features/pharmacy_portal/domain/entities/pharmacy_entity.dart';

/// Priority rationale applied during the sourcing decision
enum SourcingDecisionRationale {
  /// A single pharmacy had all items and is close to client (Fastest & 1 stop = ₦3,500)
  singlePharmacyProximityConsolidated,

  /// Time of arrival took maximum priority: Distant pharmacy with full stock was bypassed
  /// in favor of rapid local split-stops to deliver medications significantly faster
  rapidArrivalPriorityOverDistantFullStock,

  /// No single pharmacy had 100% of items, so order was split across fastest local pharmacies
  multiPharmacySplitRequired,

  /// Cart is partially unfulfilled across platform
  partialNetworkCoverage,
}

/// Sourcing result detailing which community pharmacies fulfill the order,
/// logistics pricing breakdown, and arrival ETA.
class PharmacySourcingResult {
  final List<CommunityPharmacyEntity> selectedPharmacies;
  final List<PharmacyPickupStop> pickupStops;
  final Map<String, String> itemAllocations; // drugName -> pharmacyName
  final int estimatedArrivalMinutes;
  final double maxDistanceKm;
  final int pickupStopsCount;
  final double totalLogisticsFee;
  final double baseDeliveryFee;
  final double additionalStopSurcharge;
  final bool isSplitOrder;
  final bool allFulfilled;
  final List<String> unfulfilledItems;
  final SourcingDecisionRationale rationale;
  final String dispatchExplanation;

  const PharmacySourcingResult({
    required this.selectedPharmacies,
    required this.pickupStops,
    required this.itemAllocations,
    required this.estimatedArrivalMinutes,
    required this.maxDistanceKm,
    required this.pickupStopsCount,
    required this.totalLogisticsFee,
    this.baseDeliveryFee = NovaExpressLogisticsService.baseFlatRateFee,
    this.additionalStopSurcharge = 0.0,
    required this.isSplitOrder,
    required this.allFulfilled,
    this.unfulfilledItems = const [],
    required this.rationale,
    required this.dispatchExplanation,
  });

  /// True if customer saved ₦1,500 by consolidating to a single pharmacy pickup
  bool get hasConsolidationSavings => pickupStopsCount == 1;

  /// String formatted ETA badge
  String get etaBadgeText => '$estimatedArrivalMinutes mins ETA';

  /// Primary fulfillment pharmacy (Stop 1)
  CommunityPharmacyEntity? get primaryPharmacy =>
      selectedPharmacies.isNotEmpty ? selectedPharmacies.first : null;
}

/// Smart Pharmacy Sourcing & Multi-Objective Dispatch Engine.
///
/// Implements ComfortCare's core routing rules:
/// 1. Maximum Priority: Time of Arrival (fastest delivery to patient).
/// 2. Secondary Priority: Inventory depth (pharmacies covering more contents take precedence
///    to minimize extra pickup stops and save the customer ₦1,500 per additional stop).
/// 3. Decision Overrides: If a distant pharmacy has 100% of items but is far from the client
///    (ETA exceeds local arrival by > 12 mins), TIME OF ARRIVAL strictly overrides it,
///    selecting faster local split-stops to save patient critical wait time.
class PharmacySourcingEngine {
  /// Base flat rate delivery fee for a single-stop pharmacy pickup
  static const double baseSinglePickupFee = NovaExpressLogisticsService.baseFlatRateFee; // ₦3,500

  /// Additional surcharge per extra pickup stop
  static const double extraPickupStopFee = NovaExpressLogisticsService.additionalPickupFeePerStop; // ₦1,500

  /// Proximity arrival tolerance threshold (minutes):
  /// If a single pharmacy with full inventory arrives within this buffer of the fastest
  /// local split option, it takes precedence to eliminate extra stop fees (saves customer ₦1,500).
  /// If its arrival time exceeds this buffer, TIME OF ARRIVAL takes maximum priority!
  static const int rapidArrivalToleranceMinutes = 12;

  /// Optimizes pharmacy sourcing for the given cart items and customer GPS coordinates.
  static PharmacySourcingResult optimizeSourcing({
    required List<CartItemEntity> items,
    required double customerLat,
    required double customerLng,
    List<CommunityPharmacyEntity>? candidatePharmacies,
    String? orderId,
  }) {
    final effectiveOrderId = orderId ?? 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final candidates = (candidatePharmacies ??
            MockCommunityPharmaciesRepository.instance.getAll())
        .where((p) => p.isOpen)
        .toList();

    if (items.isEmpty || candidates.isEmpty) {
      return PharmacySourcingResult(
        selectedPharmacies: const [],
        pickupStops: const [],
        itemAllocations: const {},
        estimatedArrivalMinutes: 25,
        maxDistanceKm: 0.0,
        pickupStopsCount: 1,
        totalLogisticsFee: baseSinglePickupFee,
        baseDeliveryFee: baseSinglePickupFee,
        additionalStopSurcharge: 0.0,
        isSplitOrder: false,
        allFulfilled: false,
        rationale: SourcingDecisionRationale.partialNetworkCoverage,
        dispatchExplanation: 'No items or candidate pharmacies available.',
      );
    }

    // Step 1: Evaluate candidate pharmacies covering 100% of the cart
    final pharmaciesWithFullCoverage = candidates.where((pharmacy) {
      return items.every((item) =>
          pharmacy.hasStock(item.product.name, item.quantity));
    }).toList();

    CommunityPharmacyEntity? bestSinglePharmacy;
    int bestSingleEta = 999999;
    if (pharmaciesWithFullCoverage.isNotEmpty) {
      // Sort full-coverage pharmacies primarily by lowest arrival time (proximity)
      pharmaciesWithFullCoverage.sort((a, b) {
        final etaA = a.etaMinutesTo(customerLat, customerLng);
        final etaB = b.etaMinutesTo(customerLat, customerLng);
        return etaA.compareTo(etaB);
      });
      final chosenSingle = pharmaciesWithFullCoverage.first;
      bestSinglePharmacy = chosenSingle;
      bestSingleEta = chosenSingle.etaMinutesTo(customerLat, customerLng);
    }

    // Step 2: Build the fastest local multi-stop plan (greedy set-cover prioritizing arrival time)
    final localPlanPharmacies = _findFastestLocalFulfillmentPlan(
      items: items,
      candidates: candidates,
      customerLat: customerLat,
      customerLng: customerLng,
    );

    final localPlanStops = localPlanPharmacies.length;
    final maxLocalPharmacyEta = localPlanPharmacies.isEmpty
        ? 999999
        : localPlanPharmacies
            .map((p) => p.etaMinutesTo(customerLat, customerLng))
            .reduce(math.max);
    // Multi-stop transit buffer: 5 mins extra per subsequent stop
    final localPlanTotalEta = localPlanPharmacies.isEmpty
        ? 999999
        : maxLocalPharmacyEta + ((localPlanStops - 1) * 5);

    // Step 3: Apply the Core Priority Rules
    // User Rule: "in the case the pharmacy with highest number is not close to client,
    // more precedence to the one that will arrive quicker. In fact, time of arrival is maximum priority."
    bool useSingleConsolidation = false;
    SourcingDecisionRationale decisionRationale;
    String decisionExplanation;

    if (bestSinglePharmacy != null) {
      if (localPlanStops <= 1) {
        // Both single and local plan require 1 stop; pick the fastest
        useSingleConsolidation = true;
        decisionRationale = SourcingDecisionRationale.singlePharmacyProximityConsolidated;
        decisionExplanation =
            'Optimal Proximity & 100% Stock: Sourced from ${bestSinglePharmacy.name} ($bestSingleEta mins ETA). Base delivery ₦3,500 (1 pickup stop).';
      } else {
        // Local split plan requires multiple stops (e.g. 2 stops), while bestSinglePharmacy has 100% stock.
        // Compare ETAs: Is bestSinglePharmacy "close" to the client?
        final etaDifference = bestSingleEta - localPlanTotalEta;

        if (etaDifference <= rapidArrivalToleranceMinutes) {
          // Single pharmacy arrives within reasonable buffer (≤ 12 mins) of the split option.
          // Prioritize higher item coverage to reduce logistics price for customer!
          useSingleConsolidation = true;
          decisionRationale = SourcingDecisionRationale.singlePharmacyProximityConsolidated;
          decisionExplanation =
              'Consolidated Sourcing: ${bestSinglePharmacy.name} covers 100% of order contents within rapid range ($bestSingleEta mins ETA). Saved customer ₦1,500 extra pickup stop fee.';
        } else {
          // Distant pharmacy takes significantly longer (e.g. 48 mins vs 18 mins).
          // TIME OF ARRIVAL IS THE MAXIMUM PRIORITY!
          useSingleConsolidation = false;
          decisionRationale = SourcingDecisionRationale.rapidArrivalPriorityOverDistantFullStock;
          decisionExplanation =
              'Maximum Arrival Priority: Patient receives medications in $localPlanTotalEta mins via $localPlanStops local dispensaries (overriding distant store at $bestSingleEta mins). Surcharge: +₦${((localPlanStops - 1) * extraPickupStopFee).toInt()} for extra pickup.';
        }
      }
    } else {
      // No single pharmacy has 100% stock; multi-stop split is required
      useSingleConsolidation = false;
      decisionRationale = SourcingDecisionRationale.multiPharmacySplitRequired;
      decisionExplanation =
          'Multi-Dispensary Fulfillment: Order split across $localPlanStops community pharmacies for rapid $localPlanTotalEta mins arrival. Additional stop surcharge: +₦${((localPlanStops - 1) * extraPickupStopFee).toInt()}.';
    }

    // Step 4: Finalize selected pharmacies, item allocations, and pickup stops
    final finalSelectedPharmacies = useSingleConsolidation
        ? [bestSinglePharmacy!]
        : localPlanPharmacies;

    final itemAllocations = <String, String>{};
    final pharmacyToItemsMap = <String, List<String>>{};
    for (final p in finalSelectedPharmacies) {
      pharmacyToItemsMap[p.id] = [];
    }

    final unfulfilled = <String>[];
    for (final item in items) {
      final drugName = item.product.name;
      CommunityPharmacyEntity? assignedPharmacy;

      for (final p in finalSelectedPharmacies) {
        if (p.hasStock(drugName, item.quantity)) {
          assignedPharmacy = p;
          break;
        }
      }

      if (assignedPharmacy != null) {
        itemAllocations[drugName] = assignedPharmacy.name;
        pharmacyToItemsMap[assignedPharmacy.id]!
            .add('$drugName (x${item.quantity})');
      } else {
        unfulfilled.add(drugName);
      }
    }

    final stopsCount = finalSelectedPharmacies.length;
    final totalLogisticsFee = NovaExpressLogisticsService.calculateTotalLogisticsFee(stopsCount);
    final additionalSurcharge = stopsCount > 1 ? (stopsCount - 1) * extraPickupStopFee : 0.0;

    final maxDistance = finalSelectedPharmacies.isEmpty
        ? 0.0
        : finalSelectedPharmacies
            .map((p) => p.distanceTo(customerLat, customerLng))
            .reduce(math.max);

    final finalEta = useSingleConsolidation
        ? bestSingleEta
        : localPlanTotalEta;

    // Build PharmacyPickupStop objects ready for NovaExpress JSON POST payload
    final pickupStops = <PharmacyPickupStop>[];
    for (int i = 0; i < finalSelectedPharmacies.length; i++) {
      final p = finalSelectedPharmacies[i];
      final assignedDrugs = pharmacyToItemsMap[p.id] ?? [];
      final stopSuffix = String.fromCharCode(65 + i); // 'A', 'B', 'C'

      pickupStops.add(
        PharmacyPickupStop(
          pharmacyId: p.id,
          pharmacyName: p.name,
          address: p.address,
          city: p.city,
          state: p.state,
          lga: p.lga,
          landmark: p.landmark,
          contactPerson: p.pharmacistInCharge,
          contactPhone: p.phone,
          contactWhatsapp: p.whatsapp,
          drugNames: assignedDrugs,
          sealedBagRef: 'SEAL-$effectiveOrderId-$stopSuffix',
        ),
      );
    }

    return PharmacySourcingResult(
      selectedPharmacies: finalSelectedPharmacies,
      pickupStops: pickupStops,
      itemAllocations: itemAllocations,
      estimatedArrivalMinutes: finalEta,
      maxDistanceKm: (maxDistance * 10).round() / 10.0,
      pickupStopsCount: stopsCount,
      totalLogisticsFee: totalLogisticsFee,
      baseDeliveryFee: baseSinglePickupFee,
      additionalStopSurcharge: additionalSurcharge,
      isSplitOrder: stopsCount > 1,
      allFulfilled: unfulfilled.isEmpty,
      unfulfilledItems: unfulfilled,
      rationale: decisionRationale,
      dispatchExplanation: decisionExplanation,
    );
  }

  /// Finds the fastest set of local pharmacies that covers all items.
  /// Uses a greedy set-cover heuristic where pharmacies are ranked by:
  /// 1. Proximity / Arrival time (lower ETA is higher priority).
  /// 2. Remaining items covered (more items covered takes precedence to minimize stops).
  static List<CommunityPharmacyEntity> _findFastestLocalFulfillmentPlan({
    required List<CartItemEntity> items,
    required List<CommunityPharmacyEntity> candidates,
    required double customerLat,
    required double customerLng,
  }) {
    final neededItems = Set<String>.from(items.map((i) => i.product.name));
    final selected = <CommunityPharmacyEntity>[];
    final remainingCandidates = List<CommunityPharmacyEntity>.from(candidates);

    while (neededItems.isNotEmpty && remainingCandidates.isNotEmpty) {
      // Sort candidates by combined score:
      // Priority 1: Arrival Time (lower ETA wins).
      // Priority 2: Higher coverage count among needed items (to minimize stops & logistics cost).
      remainingCandidates.sort((a, b) {
        final coverageA = items
            .where((i) =>
                neededItems.contains(i.product.name) &&
                a.hasStock(i.product.name, i.quantity))
            .length;
        final coverageB = items
            .where((i) =>
                neededItems.contains(i.product.name) &&
                b.hasStock(i.product.name, i.quantity))
            .length;

        // Candidate must cover at least 1 remaining item
        if (coverageA == 0 && coverageB == 0) return 0;
        if (coverageA == 0) return 1;
        if (coverageB == 0) return -1;

        final etaA = a.etaMinutesTo(customerLat, customerLng);
        final etaB = b.etaMinutesTo(customerLat, customerLng);

        // Arrival Time priority windows (e.g. 8-minute tiers):
        // If ETA is in the same tier, the one with MORE items wins to reduce stops & price!
        const arrivalWindow = 8;
        final tierA = etaA ~/ arrivalWindow;
        final tierB = etaB ~/ arrivalWindow;

        if (tierA != tierB) {
          // Time of arrival is maximum priority!
          return tierA.compareTo(tierB);
        }

        // Within the same arrival window, pharmacy with MORE items takes precedence
        if (coverageA != coverageB) {
          return coverageB.compareTo(coverageA); // descending
        }

        // Exact ETA tie-breaker
        return etaA.compareTo(etaB);
      });

      final bestPharmacy = remainingCandidates.first;
      final newlyCovered = items
          .where((i) =>
              neededItems.contains(i.product.name) &&
              bestPharmacy.hasStock(i.product.name, i.quantity))
          .map((i) => i.product.name)
          .toList();

      if (newlyCovered.isEmpty) {
        // No remaining candidate has the remaining items
        break;
      }

      selected.add(bestPharmacy);
      neededItems.removeAll(newlyCovered);
      remainingCandidates.remove(bestPharmacy);
    }

    return selected;
  }
}
