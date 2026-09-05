import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/cc_button.dart';
import '../../../../core/widgets/cc_chip.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_state.dart';

class OrderConfirmedPage extends StatelessWidget {
  const OrderConfirmedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        final activeOrder = state.activeOrder;
        final orderId = activeOrder?.id ?? 'CC-84920';

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Success Badge Ring
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 36, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Order Placed Title
                  Text(
                    'Prescription Order Confirmed',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Order #$orderId has been approved by Supervising Pharmacist Halima Bello.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Confirmation Dossier Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colorScheme.surfaceContainerHigh),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Abuja Logistics Hub',
                              style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                            ),
                            CCChip(
                              label: 'NAFDAC Released',
                              variant: CCChipVariant.secondary,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.two_wheeler, color: colorScheme.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeOrder?.riderName ?? 'Rider Ibrahim',
                                    style: textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    activeOrder?.eta ?? 'ETA 18-25 mins (Shehu Shagari Way)',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Delivery Security PIN
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DELIVERY SECURITY PIN',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    'Give this to rider upon clinical verification',
                                    style: textTheme.bodySmall?.copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '4892',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Actions
                  CCButton(
                    label: 'Track Live Delivery on Map',
                    leadingIcon: const Icon(Icons.near_me, size: 18, color: Colors.white),
                    onPressed: () {
                      context.push('/orders/$orderId/track');
                    },
                  ),
                  const SizedBox(height: 12),
                  CCButton(
                    label: 'Return to Dispensary Hub',
                    variant: CCButtonVariant.outline,
                    onPressed: () {
                      context.go('/dashboard');
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
