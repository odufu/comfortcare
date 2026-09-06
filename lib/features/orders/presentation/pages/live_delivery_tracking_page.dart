import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';

class LiveDeliveryTrackingPage extends StatefulWidget {
  final String orderId;

  const LiveDeliveryTrackingPage({super.key, required this.orderId});

  @override
  State<LiveDeliveryTrackingPage> createState() => _LiveDeliveryTrackingPageState();
}

class _LiveDeliveryTrackingPageState extends State<LiveDeliveryTrackingPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(TrackOrderEvent(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        final order = state.activeOrder;
        final orderId = order?.id ?? widget.orderId;

        return Scaffold(
          appBar: AppBar(
            leading: context.canPop()
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  )
                : const Icon(Icons.receipt_long_outlined),
            title: const Text('Live Order Tracking'),
            actions: [
              IconButton(
                icon: const Icon(Icons.support_agent),
                onPressed: () {
                  context.showSnackBar('ComfortCare 24/7 Clinical Support: +234 800 266 3678');
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Status & ETA Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ACTIVE LOGISTICS DISPATCH',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '#$orderId',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 14, color: colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                order?.eta ?? '18 mins • Arriving ~3:45 PM',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Circular Progress (68%)
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: 0.68,
                                strokeWidth: 4,
                                backgroundColor: colorScheme.surfaceContainerHigh,
                                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                              ),
                              Text(
                                '68%',
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Simulated Live GPS Route Map representation
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.surfaceContainerHigh),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Map Background graphic
                      Container(
                        color: colorScheme.surfaceContainer,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      // Top Map Badges
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.ac_unit, size: 13, color: colorScheme.secondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    order?.coldChainTemp ?? 'Cold Chain Log: 3.8°C',
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.bolt, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Priority Courier',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Visual Route Elements
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Origin: Life Camp
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.storefront, color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Life Camp',
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              // Mid-route courier
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.secondary.withValues(alpha: 0.4),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.two_wheeler, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order?.riderName ?? 'Rider Ibrahim',
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: colorScheme.secondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              // Destination: Wuse 2
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: colorScheme.tertiary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.location_on, color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Wuse 2',
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Bottom Transit Label
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.navigation, size: 12, color: colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                'In Transit: Shehu Shagari Way',
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Logistics Stepper
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colorScheme.surfaceContainerHigh),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logistics Verification Status',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLogisticsStep(
                        context,
                        title: 'Prescription Triage & Validation',
                        desc: 'Approved by Supervising Pharmacist Halima Bello',
                        isCompleted: true,
                        isLast: false,
                      ),
                      _buildLogisticsStep(
                        context,
                        title: 'Dispensed from Life Camp Central Depot',
                        desc: 'Packed in calibrated cold-chain transport case (3.8°C)',
                        isCompleted: true,
                        isLast: false,
                      ),
                      _buildLogisticsStep(
                        context,
                        title: 'In Transit with Express Rider',
                        desc: 'En route along Shehu Shagari Way to destination',
                        isCompleted: true,
                        isActive: true,
                        isLast: false,
                      ),
                      _buildLogisticsStep(
                        context,
                        title: 'Delivery Hand-off & PIN Verification',
                        desc: 'Recipient presents 4-digit code upon arrival',
                        isCompleted: false,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Rider Contact Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.surfaceContainerHigh),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, color: colorScheme.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order?.riderName ?? 'Rider Ibrahim',
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'ComfortCare Abuja Logistics Courier',
                              style: textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.phone, size: 18),
                        onPressed: () {
                          context.showSnackBar('Dialing Rider Ibrahim: ${order?.riderPhone ?? "+234 812 345 6789"}');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildLogisticsStep(
    BuildContext context, {
    required String title,
    required String desc,
    required bool isCompleted,
    bool isActive = false,
    required bool isLast,
  }) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isCompleted
                    ? (isActive ? colorScheme.primary : colorScheme.secondary)
                    : colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isCompleted
                    ? colorScheme.secondary.withValues(alpha: 0.5)
                    : colorScheme.surfaceContainerHigh,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isCompleted ? colorScheme.onSurface : colorScheme.outline,
                ),
              ),
              Text(
                desc,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
