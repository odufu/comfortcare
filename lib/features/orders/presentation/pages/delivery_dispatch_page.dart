import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../../core/widgets/cc_button.dart';
import '../../../../core/widgets/cc_chip.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../pharmacy_portal/domain/services/pharmacy_sourcing_engine.dart';
import '../../domain/entities/order.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';

class DeliveryDispatchPage extends StatelessWidget {
  const DeliveryDispatchPage({super.key});

  void _showAddressModal(BuildContext context) {
    final cartItems = context.read<CartBloc>().state.items;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final addresses = [
          {
            'title': 'Plot 1044, Adetokunbo Ademola Crescent',
            'sub': 'Wuse 2, Abuja • Active Clinic',
            'contact': 'Dr. Farouk Al-Mansur (+234 803 265 1505)',
            'lat': 9.0765,
            'lng': 7.4720,
          },
          {
            'title': 'Suite 12, Comfort Mall Commercial Wing',
            'sub': 'Life Camp, Abuja',
            'contact': 'Dr. Farouk Al-Mansur (+234 803 265 1505)',
            'lat': 9.0125,
            'lng': 7.4080,
          },
          {
            'title': 'Plot 82, Gana Street, Maitama',
            'sub': 'Maitama, Abuja',
            'contact': 'Amina Bello (+234 802 345 6789)',
            'lat': 9.0880,
            'lng': 7.4980,
          },
          {
            'title': 'Area 11, Muhammadu Buhari Way',
            'sub': 'Garki 2, Abuja',
            'contact': 'Halima Aliyu (+234 809 333 4455)',
            'lat': 9.0340,
            'lng': 7.4890,
          },
          {
            'title': 'Phase 4, Gado Nasko Way, Kubwa',
            'sub': 'Kubwa Satellite District, Abuja',
            'contact': 'Musa Haruna (+234 805 123 4567)',
            'lat': 9.1550,
            'lng': 7.3200,
          },
        ];

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Destination Address',
                style: ctx.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Dispensary selection automatically re-optimizes to ensure fastest arrival at lowest logistics cost.',
                style: ctx.textTheme.bodySmall?.copyWith(color: ctx.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ...addresses.map((a) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.location_on, color: ctx.colorScheme.primary),
                  title: Text(a['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${a['sub']} • ${a['contact']}'),
                  onTap: () {
                    context.read<OrdersBloc>().add(
                          SelectDestinationAddressEvent(
                            address: '${a['title']}, ${a['sub']}',
                            contactName: (a['contact'] as String).split('(').first.trim(),
                            contactPhone: '+234 803 265 1505',
                            latitude: a['lat'] as double,
                            longitude: a['lng'] as double,
                            cartItems: cartItems,
                          ),
                        );
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showEditContactModal(BuildContext context, OrdersState state) {
    final nameCtrl = TextEditingController(text: state.recipientName);
    final phoneCtrl = TextEditingController(text: state.recipientPhone);
    final whatsappCtrl = TextEditingController(text: state.recipientWhatsapp);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Receiver & Contact Details',
                        style: ctx.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Receiver Full Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Receiver Call Phone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: whatsappCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Receiver WhatsApp Number',
                      prefixIcon: Icon(Icons.chat_bubble, color: Color(0xFF16A34A)),
                      helperText: 'Used by NovaExpress for automated dispatch updates & rider chat',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setModalState(() {
                            whatsappCtrl.text = phoneCtrl.text;
                          });
                        },
                        icon: const Icon(Icons.copy, size: 14, color: Color(0xFF16A34A)),
                        label: const Text(
                          'Same as Call Phone Number',
                          style: TextStyle(color: Color(0xFF16A34A), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CCButton(
                    label: 'Save & Update Dispatch Payload',
                    onPressed: () {
                      context.read<OrdersBloc>().add(
                            UpdateRecipientContactEvent(
                              contactName: nameCtrl.text.trim(),
                              contactPhone: phoneCtrl.text.trim(),
                              contactWhatsapp: whatsappCtrl.text.trim(),
                            ),
                          );
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final cartItems = context.watch<CartBloc>().state.items;

    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        // Real-time pharmacy sourcing optimization
        final sourcing = state.sourcingResult ??
            PharmacySourcingEngine.optimizeSourcing(
              items: cartItems,
              customerLat: state.destinationLat,
              customerLng: state.destinationLng,
            );

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery & Dispatch Options'),
                Text(
                  'Step 2 of 4: Sourcing & Courier Routing',
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Progress Bar (Step 2 active)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Selected FCT Destination Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colorScheme.surfaceContainerHigh),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, size: 14, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'DELIVERY DESTINATION',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          CCChip(
                            label: 'Active FCT Clinic',
                            variant: CCChipVariant.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.destinationAddress,
                                  style: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.surfaceContainerHigh),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, size: 14, color: colorScheme.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${state.recipientName} • Phone: ${state.recipientPhone}',
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFF16A34A)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'WhatsApp: ${state.recipientWhatsapp} (Rider & Dispatch alerts)',
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.info_outline, size: 14, color: colorScheme.secondary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Deliver to Clinic Front Desk, Gate 2 • Sealed Rx Pack',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => _showAddressModal(context),
                                icon: Icon(Icons.add_location_alt, size: 16, color: colorScheme.primary),
                                label: Text(
                                  'Change Address',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => _showEditContactModal(context, state),
                                icon: const Icon(Icons.edit, size: 14, color: Color(0xFF16A34A)),
                                label: Text(
                                  'Edit Contacts',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: const Color(0xFF16A34A),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'GPS: (${state.destinationLat.toStringAsFixed(3)}, ${state.destinationLng.toStringAsFixed(3)})',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // NovaExpress 3PL Partner Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Powered by NovaExpress Dedicated Fleet',
                              style: textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0D9488),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Flat-rate dispatch (₦3,500) • Community dispensary routing with GPS custody tracking.',
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // SMART COMMUNITY PHARMACY SOURCING CARD
                _buildPharmacySourcingCard(context, sourcing: sourcing, ordersState: state),
                const SizedBox(height: 20),

                // Dispatch Speed & Fleet Section
                Text(
                  'Courier Dispatch Mode (NovaExpress Fleet)',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dedicated pharmaceutical couriers with calibrated thermal transport cases.',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),

                // Option 1: Abuja Priority Express
                _buildDispatchCard(
                  context,
                  speed: DispatchSpeed.express,
                  title: 'NovaExpress Priority Express',
                  eta: '${sourcing.estimatedArrivalMinutes} mins ETA • Maximum Arrival Priority',
                  price: sourcing.totalLogisticsFee,
                  badgeText: sourcing.isSplitOrder ? 'PRIORITY SPLIT' : 'FLAT RATE',
                  badgeColor: sourcing.isSplitOrder ? CCChipVariant.warning : CCChipVariant.secondary,
                  icon: Icons.electric_moped,
                  isSelected: state.selectedDispatchSpeed == DispatchSpeed.express,
                  onSelect: () {
                    context.read<OrdersBloc>().add(
                          SelectDispatchSpeedEvent(DispatchSpeed.express, sourcing.totalLogisticsFee),
                        );
                  },
                ),
                const SizedBox(height: 10),

                // Option 2: Standard Cold-Chain
                _buildDispatchCard(
                  context,
                  speed: DispatchSpeed.scheduled,
                  title: 'NovaExpress Cold-Chain Scheduled',
                  eta: 'Same-day monitored 2-8°C box • ${sourcing.pickupStopsCount} stops',
                  price: sourcing.totalLogisticsFee,
                  badgeText: 'COLD-CHAIN',
                  badgeColor: CCChipVariant.primary,
                  icon: Icons.ac_unit,
                  isSelected: state.selectedDispatchSpeed == DispatchSpeed.scheduled,
                  onSelect: () {
                    context.read<OrdersBloc>().add(
                          SelectDispatchSpeedEvent(DispatchSpeed.scheduled, sourcing.totalLogisticsFee),
                        );
                  },
                ),
                const SizedBox(height: 10),

                // Option 3: Depot Pickup
                _buildDispatchCard(
                  context,
                  speed: DispatchSpeed.depotPickup,
                  title: 'Direct Pick-Up at Life Camp Depot',
                  eta: 'Self-collect in 15 mins (Comfort Mall Commercial Wing)',
                  price: 0.0,
                  badgeText: 'FREE',
                  badgeColor: CCChipVariant.neutral,
                  icon: Icons.storefront,
                  isSelected: state.selectedDispatchSpeed == DispatchSpeed.depotPickup,
                  onSelect: () {
                    context.read<OrdersBloc>().add(
                          const SelectDispatchSpeedEvent(DispatchSpeed.depotPickup, 0.0),
                        );
                  },
                ),
                const SizedBox(height: 28),

                // Proceed Button
                CCButton(
                  label: 'Proceed to Clinical Authorization & Payment (Step 3)',
                  onPressed: () {
                    // Pre-store sourcing result into bloc state before checkout payment
                    if (state.sourcingResult == null) {
                      context.read<OrdersBloc>().add(
                            OptimizePharmacySourcingEvent(
                              items: cartItems,
                              customerLat: state.destinationLat,
                              customerLng: state.destinationLng,
                            ),
                          );
                    }
                    context.push('/checkout/payment');
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPharmacySourcingCard(
    BuildContext context, {
    required PharmacySourcingResult sourcing,
    required OrdersState ordersState,
  }) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final isDarkMode = context.isDarkMode;

    final isMaxPriorityArrival = sourcing.rationale ==
        SourcingDecisionRationale.rapidArrivalPriorityOverDistantFullStock;
    final isConsolidated = sourcing.rationale ==
        SourcingDecisionRationale.singlePharmacyProximityConsolidated;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMaxPriorityArrival
              ? const Color(0xFF0D9488)
              : colorScheme.surfaceContainerHigh,
          width: isMaxPriorityArrival ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with priority badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_pharmacy_rounded,
                          color: isMaxPriorityArrival
                              ? const Color(0xFF0D9488)
                              : colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'COMMUNITY PHARMACY SOURCING',
                          style: textTheme.labelSmall?.copyWith(
                            color: isMaxPriorityArrival
                                ? const Color(0xFF0D9488)
                                : colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Decentralized Micro-Dispensary Routing',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              CCChip(
                label: isMaxPriorityArrival
                    ? '⚡ ARRIVAL PRIORITY'
                    : isConsolidated
                        ? 'CONSOLIDATED (1 STOP)'
                        : 'MULTI-STOP SOURCING',
                variant: isMaxPriorityArrival
                    ? CCChipVariant.secondary
                    : (isConsolidated
                        ? CCChipVariant.primary
                        : CCChipVariant.neutral),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Live ETA Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isMaxPriorityArrival
                      ? const Color(0xFF0D9488)
                      : colorScheme.primary)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isMaxPriorityArrival
                        ? const Color(0xFF0D9488)
                        : colorScheme.primary)
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isMaxPriorityArrival
                        ? const Color(0xFF0D9488)
                        : colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.timer_rounded, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${sourcing.estimatedArrivalMinutes} Mins Estimated Arrival',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isMaxPriorityArrival
                              ? const Color(0xFF0D9488)
                              : colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sourcing.dispatchExplanation,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // List of Sourced Dispensary Stops
          Text(
            'Assigned Pickup Stops (${sourcing.pickupStopsCount} dispensary${sourcing.pickupStopsCount > 1 ? 's' : ''}):',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          ...sourcing.pickupStops.asMap().entries.map((entry) {
            final idx = entry.key;
            final stop = entry.value;
            final stopLetter = String.fromCharCode(65 + idx);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.surfaceContainerHigh),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      stopLetter,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                stop.pharmacyName,
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              stop.sealedBagRef,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stop.address,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: stop.drugNames.map((d) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                d,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 18),

          // Logistics Cost Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Base NovaExpress Flat Rate',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11.5,
                    ),
                  ),
                  if (sourcing.isSplitOrder)
                    Text(
                      'Extra Pickup Surcharge (${sourcing.pickupStopsCount - 1} stop)',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFD97706),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text(
                      'Consolidation Discount (1 stop)',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF16A34A),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    3500.0.currencyFormat,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                  if (sourcing.isSplitOrder)
                    Text(
                      '+${sourcing.additionalStopSurcharge.currencyFormat}',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD97706),
                        fontSize: 11.5,
                      ),
                    )
                  else
                    Text(
                      '₦0 (Saved ₦1,500)',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF16A34A),
                        fontSize: 11.5,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Logistics Delivery Fee',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  sourcing.totalLogisticsFee.currencyFormat,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isMaxPriorityArrival
                        ? const Color(0xFF0D9488)
                        : colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchCard(
    BuildContext context, {
    required DispatchSpeed speed,
    required String title,
    required String eta,
    required double price,
    required String badgeText,
    required CCChipVariant badgeColor,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.05)
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHigh,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.12)
                    : colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      CCChip(
                        label: badgeText,
                        variant: badgeColor,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    eta,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    price == 0 ? 'FREE' : price.currencyFormat,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
