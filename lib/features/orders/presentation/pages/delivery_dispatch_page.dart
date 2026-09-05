import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../../core/widgets/cc_button.dart';
import '../../../../core/widgets/cc_chip.dart';
import '../../domain/entities/order.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';

class DeliveryDispatchPage extends StatelessWidget {
  const DeliveryDispatchPage({super.key});

  void _showAddressModal(BuildContext context) {
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
          },
          {
            'title': 'Suite 12, Comfort Mall Commercial Wing',
            'sub': 'Life Camp, Abuja',
            'contact': 'Dr. Farouk Al-Mansur (+234 803 265 1505)',
          },
          {
            'title': 'Plot 82, Gana Street, Maitama',
            'sub': 'Maitama, Abuja',
            'contact': 'Amina Bello (+234 802 345 6789)',
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
              const SizedBox(height: 16),
              ...addresses.map((a) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.location_on, color: ctx.colorScheme.primary),
                  title: Text(a['title']!, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${a['sub']} • ${a['contact']}'),
                  onTap: () {
                    context.read<OrdersBloc>().add(
                          SelectDestinationAddressEvent(
                            address: '${a['title']}, ${a['sub']}',
                            contactName: a['contact']!.split('(').first.trim(),
                            contactPhone: '+234 803 265 1505',
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
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
                  'Step 2 of 4: Destination & Courier',
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
                                'SELECTED FCT DESTINATION',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          CCChip(
                            label: 'Active Clinic',
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, size: 14, color: colorScheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  '${state.recipientName} • ${state.recipientPhone}',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.info_outline, size: 14, color: colorScheme.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Deliver to Clinic Front Desk, Gate 2',
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
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              'Change Abuja Address',
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            'Hub: Life Camp Depot',
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
                const SizedBox(height: 22),

                // Dispatch Speed & Fleet Section
                Text(
                  'Dispatch Speed & Fleet',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dedicated pharmaceutical couriers with calibrated transport cases.',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),

                // Option 1: Abuja Priority Express
                _buildDispatchCard(
                  context,
                  speed: DispatchSpeed.express,
                  title: 'Abuja Priority Express',
                  eta: '25 - 35 mins ETA',
                  price: 1200.0,
                  badgeText: 'FASTEST',
                  badgeColor: CCChipVariant.secondary,
                  icon: Icons.electric_moped,
                  isSelected: state.selectedDispatchSpeed == DispatchSpeed.express,
                  onSelect: () {
                    context.read<OrdersBloc>().add(
                          const SelectDispatchSpeedEvent(DispatchSpeed.express, 1200.0),
                        );
                  },
                ),
                const SizedBox(height: 10),

                // Option 2: Standard Cold-Chain
                _buildDispatchCard(
                  context,
                  speed: DispatchSpeed.scheduled,
                  title: 'Standard Cold-Chain Delivery',
                  eta: 'Same-day 3-4 hours (Temp Logged)',
                  price: 800.0,
                  badgeText: 'COLD-CHAIN',
                  badgeColor: CCChipVariant.primary,
                  icon: Icons.local_shipping,
                  isSelected: state.selectedDispatchSpeed == DispatchSpeed.scheduled,
                  onSelect: () {
                    context.read<OrdersBloc>().add(
                          const SelectDispatchSpeedEvent(DispatchSpeed.scheduled, 800.0),
                        );
                  },
                ),
                const SizedBox(height: 10),

                // Option 3: Depot Pickup
                _buildDispatchCard(
                  context,
                  speed: DispatchSpeed.depotPickup,
                  title: 'Direct Pick-Up at Life Camp Depot',
                  eta: 'Ready in 15 mins (Comfort Mall)',
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
              ? colorScheme.primaryContainer.withValues(alpha: 0.12)
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
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      CCChip(
                        label: badgeText,
                        variant: badgeColor,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    eta,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price == 0 ? 'FREE' : price.toNaira(),
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: price == 0 ? colorScheme.secondary : colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
