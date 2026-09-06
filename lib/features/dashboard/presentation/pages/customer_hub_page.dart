import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/cc_app_bar.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/express_delivery_banner.dart';
import '../widgets/fast_moving_essentials_section.dart';
import '../widgets/prescription_fast_upload_card.dart';
import '../widgets/quick_actions_grid.dart';

class CustomerHubPage extends StatefulWidget {
  const CustomerHubPage({super.key});

  @override
  State<CustomerHubPage> createState() => _CustomerHubPageState();
}

class _CustomerHubPageState extends State<CustomerHubPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLocationPicker(BuildContext context, DashboardState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final locations = [
          'Comfort Mall, Life Camp, Abuja',
          'Plot 1044, Adetokunbo Crescent, Wuse 2',
          'Maitama District Hospital Road, Abuja',
          'Jabi Lake Promenade, Abuja',
          'Gwarinpa 1st Avenue Hub, Abuja',
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Abuja Delivery Address',
                style: ctx.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ...locations.map((loc) {
                final isSelected = loc == state.deliveryLocation;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.location_on,
                    color: isSelected ? ctx.colorScheme.primary : ctx.colorScheme.outline,
                  ),
                  title: Text(
                    loc,
                    style: ctx.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? ctx.colorScheme.primary : ctx.colorScheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: ctx.colorScheme.secondary)
                      : null,
                  onTap: () {
                    context.read<DashboardBloc>().add(ChangeDeliveryLocation(loc));
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

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          appBar: CCAppBar(
            showBrandLogo: true,
            showLocationSelector: true,
            showProfileAvatar: true,
            selectedLocation: state.deliveryLocation,
            onLocationTap: () => _showLocationPicker(context, state),
            cartItemCount: context.watch<CartBloc>().state.totalItems,
            onNotificationsTap: () {
              context.showSnackBar('No new alerts. Cold-chain storage normal.');
            },
            onProfileTap: () => context.go('/profile'),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(LoadDashboardData());
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prescription Fast Upload Card (Have a Prescription? Snap & Send)
                      const PrescriptionFastUploadCard(),
                      const SizedBox(height: 14),

                      // 4 Action Buttons in One Single Row (Compact & Minimalistic)
                      const QuickActionsGrid(),
                      const SizedBox(height: 18),

                      // Express Delivery Banner
                      ExpressDeliveryBanner(
                        destination: state.deliveryLocation.split(',').first,
                        onChangeDestination: () => _showLocationPicker(context, state),
                      ),
                      const SizedBox(height: 14),

                      // Retail vs Wholesale Mode Switcher
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  context.read<DashboardBloc>().add(
                                        const ToggleRetailWholesaleMode(false),
                                      );
                                },
                                borderRadius: BorderRadius.circular(26),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: !state.isWholesaleMode
                                        ? colorScheme.surfaceContainerLowest
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: !state.isWholesaleMode
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                  alpha: context.isDarkMode ? 0.3 : 0.05),
                                              blurRadius: 4,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 16,
                                        color: !state.isWholesaleMode
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Retail Packs',
                                        style: textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: !state.isWholesaleMode
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  context.read<DashboardBloc>().add(
                                        const ToggleRetailWholesaleMode(true),
                                      );
                                },
                                borderRadius: BorderRadius.circular(26),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: state.isWholesaleMode
                                        ? colorScheme.surfaceContainerLowest
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: state.isWholesaleMode
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                  alpha: context.isDarkMode ? 0.3 : 0.05),
                                              blurRadius: 4,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.domain,
                                        size: 16,
                                        color: state.isWholesaleMode
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Wholesale Bulk',
                                        style: textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: state.isWholesaleMode
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: colorScheme.secondary,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'UP TO 25%',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Modern Search Capsule with Barcode Scanner
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: colorScheme.surfaceContainerHigh),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: state.isWholesaleMode
                                ? 'Search wholesale hospital cartons, clinical packs...'
                                : 'Search medicines, cold-chain insulin, devices...',
                            hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                            prefixIcon: Icon(Icons.search, color: colorScheme.outline),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.barcode_reader, color: colorScheme.primary),
                              onPressed: () {
                                context.showSnackBar('Barcode scanner ready for NAFDAC verification.');
                              },
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onSubmitted: (query) {
                            context.push('/products');
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Fast-Moving Essentials Section (2x2 Grid matching Mockup)
                      const FastMovingEssentialsSection(),
                      const SizedBox(height: 24),

                      // Abuja Cold-Chain Telemetry Status Notice
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.surfaceContainerHigh),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.ac_unit, color: colorScheme.secondary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Abuja Cold-Chain Certified',
                                    style: textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'All biologics, insulins & vaccines stored at 2°C - 8°C in Life Camp Central Depot.',
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
