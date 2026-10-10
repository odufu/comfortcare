import 'package:flutter_test/flutter_test.dart';
import 'package:comfort_care/features/cart/domain/entities/cart_item.dart';
import 'package:comfort_care/features/pharmacy_portal/domain/services/pharmacy_sourcing_engine.dart';
import 'package:comfort_care/features/products/domain/entities/product.dart';

void main() {
  group('PharmacySourcingEngine Sourcing & Priority Optimization', () {
    const wuse2Lat = 9.0765;
    const wuse2Lng = 7.4720;

    final productCoartem = const ProductEntity(
      id: 'prod-coartem-1',
      name: 'Coartem 80/480mg',
      brand: 'Novartis',
      genericName: 'Artemether / Lumefantrine',
      packSize: '6 Tablets',
      price: 4200.0,
      wholesalePrice: 3360.0,
      category: 'Antimalarial',
      description: 'First-line malaria treatment',
      dosageInstructions: 'Take with food',
      activeIngredients: 'Artemether, Lumefantrine',
      nafdacNumber: '04-2011',
      imageUrl: 'coartem.png',
    );

    final productAmoxil = const ProductEntity(
      id: 'prod-amoxil-1',
      name: 'Amoxil 500mg',
      brand: 'GSK',
      genericName: 'Amoxicillin',
      packSize: '20 Capsules',
      price: 3600.0,
      wholesalePrice: 2880.0,
      category: 'Antibiotic',
      description: 'Broad spectrum antibiotic',
      dosageInstructions: '8-hourly',
      activeIngredients: 'Amoxicillin',
      nafdacNumber: '04-1234',
      imageUrl: 'amoxil.png',
    );

    final productVentolin = const ProductEntity(
      id: 'prod-ventolin-1',
      name: 'Ventolin Inhaler',
      brand: 'GSK',
      genericName: 'Salbutamol',
      packSize: '200 Doses',
      price: 7500.0,
      wholesalePrice: 6000.0,
      category: 'Respiratory',
      description: 'Bronchodilator for asthma relief',
      dosageInstructions: 'Inhale 1-2 puffs as required',
      activeIngredients: 'Salbutamol',
      nafdacNumber: '04-5678',
      imageUrl: 'ventolin.png',
    );

    test('Consolidated Single-Stop: When close pharmacy has 100% of items, select 1 stop and ₦3,500', () {
      final cart = [
        CartItemEntity(product: productCoartem, quantity: 1),
        CartItemEntity(product: productAmoxil, quantity: 1),
      ];

      final result = PharmacySourcingEngine.optimizeSourcing(
        items: cart,
        customerLat: wuse2Lat,
        customerLng: wuse2Lng,
      );

      expect(result.allFulfilled, isTrue);
      // H-Medix is in Wuse 2 and has both Coartem and Amoxil
      expect(result.pickupStopsCount, equals(1));
      expect(result.totalLogisticsFee, equals(3500.0));
      expect(result.isSplitOrder, isFalse);
      expect(result.hasConsolidationSavings, isTrue);
      expect(result.selectedPharmacies.first.name, contains('H-Medix'));
      expect(result.pickupStops.first.drugNames.length, equals(2));
      expect(result.rationale, equals(SourcingDecisionRationale.singlePharmacyProximityConsolidated));
    });

    test('MAXIMUM PRIORITY: Time of arrival strictly overrides distant full-stock pharmacy', () {
      // Coartem + Ventolin
      // H-Medix (Wuse 2, 7 mins ETA) has Coartem, but NOT Ventolin.
      // HealthPlus (Maitama, ~12 mins ETA) has Ventolin.
      // M-Care (Kubwa, ~50 mins ETA) has BOTH Coartem and Ventolin!
      // User Rule: Time of arrival is MAXIMUM priority!
      // Local split plan arrives in ~17 mins. Distant single pharmacy arrives in ~50 mins.
      // Engine MUST prioritize the rapid arrival local split!
      final cart = [
        CartItemEntity(product: productCoartem, quantity: 1),
        CartItemEntity(product: productVentolin, quantity: 1),
      ];

      final result = PharmacySourcingEngine.optimizeSourcing(
        items: cart,
        customerLat: wuse2Lat,
        customerLng: wuse2Lng,
      );

      expect(result.allFulfilled, isTrue);
      expect(result.isSplitOrder, isTrue);
      expect(result.pickupStopsCount, equals(2));
      expect(result.totalLogisticsFee, equals(5000.0)); // ₦3,500 base + ₦1,500 extra stop
      expect(result.rationale, equals(SourcingDecisionRationale.rapidArrivalPriorityOverDistantFullStock));
      expect(result.estimatedArrivalMinutes, lessThan(30)); // Local arrival is way faster than Kubwa (~50m)

      // Distant Kubwa pharmacy should NOT be chosen because time of arrival has maximum priority!
      final selectedIds = result.selectedPharmacies.map((p) => p.id).toList();
      expect(selectedIds, isNot(contains('ph-mcare-kubwa-distant')));

      // NovaExpress pickup stops are prepared correctly
      expect(result.pickupStops.length, equals(2));
      expect(result.pickupStops[0].sealedBagRef, contains('ORD-'));
      expect(result.pickupStops[1].sealedBagRef, contains('ORD-'));
    });

    test('Item Coverage Precedence: Pharmacy with more contents takes precedence within arrival tier', () {
      // 3 items needed
      final cart = [
        CartItemEntity(product: productCoartem, quantity: 1),
        CartItemEntity(product: productAmoxil, quantity: 1),
        CartItemEntity(product: productVentolin, quantity: 1),
      ];

      final result = PharmacySourcingEngine.optimizeSourcing(
        items: cart,
        customerLat: wuse2Lat,
        customerLng: wuse2Lng,
      );

      // H-Medix covers 2 items (Coartem + Amoxil) in Wuse 2.
      // HealthPlus covers Ventolin in Maitama.
      // Total stops should be 2, NOT 3!
      expect(result.allFulfilled, isTrue);
      expect(result.pickupStopsCount, equals(2));
      expect(result.totalLogisticsFee, equals(5000.0));
      expect(result.dispatchExplanation, contains('Priority'));
    });

    test('Reverse Proximity: When client is located in Kubwa, M-Care is closest and selected for ₦3,500', () {
      const kubwaClientLat = 9.1550;
      const kubwaClientLng = 7.3200;

      final cart = [
        CartItemEntity(product: productCoartem, quantity: 1),
        CartItemEntity(product: productVentolin, quantity: 1),
      ];

      final result = PharmacySourcingEngine.optimizeSourcing(
        items: cart,
        customerLat: kubwaClientLat,
        customerLng: kubwaClientLng,
      );

      expect(result.allFulfilled, isTrue);
      expect(result.pickupStopsCount, equals(1));
      expect(result.totalLogisticsFee, equals(3500.0));
      expect(result.selectedPharmacies.first.id, equals('ph-mcare-kubwa-distant'));
      expect(result.rationale, equals(SourcingDecisionRationale.singlePharmacyProximityConsolidated));
    });

    test('Empty Cart Graceful Fallback', () {
      final result = PharmacySourcingEngine.optimizeSourcing(
        items: const [],
        customerLat: wuse2Lat,
        customerLng: wuse2Lng,
      );

      expect(result.allFulfilled, isFalse);
      expect(result.totalLogisticsFee, equals(3500.0));
      expect(result.pickupStopsCount, equals(1));
    });
  });
}
