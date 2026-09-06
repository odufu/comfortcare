import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../../core/widgets/cc_button.dart';
import '../../../../core/widgets/cc_chip.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/prescription_dossier_card.dart';

class CartPrescriptionReviewPage extends StatefulWidget {
  const CartPrescriptionReviewPage({super.key});

  @override
  State<CartPrescriptionReviewPage> createState() => _CartPrescriptionReviewPageState();
}

class _CartPrescriptionReviewPageState extends State<CartPrescriptionReviewPage> {
  bool _isPriorityColdChain = false;
  final TextEditingController _promoController = TextEditingController();
  String? _appliedPromoCode;
  double _promoDiscount = 0.0;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromoCode(double subtotal) {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    if (code == 'COMFORT10' || code == 'ABUJAHEALTH') {
      setState(() {
        _appliedPromoCode = code;
        _promoDiscount = subtotal * 0.10; // 10% off
      });
      context.showSnackBar('Formulary discount code "$code" applied: -${_promoDiscount.toNaira()}!', isSuccess: true);
    } else {
      context.showSnackBar('Invalid or expired coupon code.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cart & Prescription Review'),
            Row(
              children: [
                Icon(Icons.verified_user, size: 12, color: colorScheme.secondary),
                const SizedBox(width: 4),
                Text(
                  'Verified Clinical Dispensary Flow',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.secondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.lock, size: 12, color: colorScheme.secondary),
                const SizedBox(width: 4),
                Text(
                  'Rx Safe',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shopping_bag_outlined, size: 44, color: colorScheme.outline),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your Prescription Cart is Empty',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse our formulary of authentic NAFDAC-certified medications and clinic diagnostic equipment.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CCButton(
                      label: 'Explore Pharmacy Catalog',
                      onPressed: () => context.push('/products'),
                    ),
                  ],
                ),
              ),
            );
          }

          final dispatchFee = _isPriorityColdChain ? 2500.0 : state.deliveryFee;
          final totalDiscount = state.discount + _promoDiscount;
          final finalTotal = (state.subtotal + dispatchFee + state.clinicalVerificationFee - totalDiscount).clamp(0.0, double.infinity);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 920;

              if (isDesktop) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Items, Rx Dossier & Cold Chain (Flex 6)
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStepTracker(context, state.totalItems),
                                const SizedBox(height: 16),
                                _buildColdChainBanner(context),
                                const SizedBox(height: 16),
                                PrescriptionDossierCard(
                                  onReupload: () {
                                    context.showSnackBar('Prescription upload dialog opened.');
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildItemsListHeader(context),
                                const SizedBox(height: 12),
                                _buildItemsList(context, state),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () => context.push('/products'),
                                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                                  label: const Text('+ Add More Medications from Pharmacy'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 28),

                          // Right Column: Summary Card, Delivery Tier & Checkout (Flex 4)
                          Expanded(
                            flex: 4,
                            child: _buildOrderSummaryCard(
                              context,
                              state: state,
                              dispatchFee: dispatchFee,
                              totalDiscount: totalDiscount,
                              finalTotal: finalTotal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Mobile Layout (< 920px)
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepTracker(context, state.totalItems),
                    const SizedBox(height: 14),
                    _buildColdChainBanner(context),
                    const SizedBox(height: 14),
                    PrescriptionDossierCard(
                      onReupload: () {
                        context.showSnackBar('Prescription upload dialog opened.');
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildItemsListHeader(context),
                    const SizedBox(height: 10),
                    _buildItemsList(context, state),
                    const SizedBox(height: 16),
                    _buildOrderSummaryCard(
                      context,
                      state: state,
                      dispatchFee: dispatchFee,
                      totalDiscount: totalDiscount,
                      finalTotal: finalTotal,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Step 1 of 4 Progress Bar
  Widget _buildStepTracker(BuildContext context, int totalItems) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Step 1 of 4',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(color: colorScheme.outline, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Order & Rx Review',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$totalItems items',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
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
        ],
      ),
    );
  }

  // Active Cold-Chain Safety Banner
  Widget _buildColdChainBanner(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.ac_unit, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'NAFDAC & Cold-Chain Monitored',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    CCChip(
                      label: '2°C - 8°C Verified',
                      variant: CCChipVariant.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Temperature-sensitive medications are stored in validated cold units and delivered in insulated thermal packaging.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Items List Header
  Widget _buildItemsListHeader(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Medications Review',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          'BATCH VERIFIED',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.secondary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // Items List
  Widget _buildItemsList(BuildContext context, CartState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = state.items[i];
        return CartItemTile(
          item: item,
          onQuantityChanged: (newQty) {
            context.read<CartBloc>().add(
                  UpdateCartItemQuantity(
                    productId: item.product.id,
                    quantity: newQty,
                  ),
                );
          },
          onRemove: () {
            context.read<CartBloc>().add(RemoveCartItem(item.product.id));
            context.showSnackBar('${item.product.name} removed from cart.');
          },
        );
      },
    );
  }

  // Order Summary Card with Delivery Speed & Promo Code
  Widget _buildOrderSummaryCard(
    BuildContext context, {
    required CartState state,
    required double dispatchFee,
    required double totalDiscount,
    required double finalTotal,
  }) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),

          // Abuja Delivery Speed Option Selector
          Text(
            'Abuja Dispatch Method',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          // Standard Option
          _buildDeliveryOptionTile(
            title: 'Standard Dispatch',
            subtitle: '1–3 Hours across Abuja FCT',
            price: state.deliveryFee.toNaira(),
            icon: Icons.electric_moped_outlined,
            isSelected: !_isPriorityColdChain,
            onTap: () => setState(() => _isPriorityColdChain = false),
          ),
          const SizedBox(height: 8),

          // Priority Cold-Chain Option
          _buildDeliveryOptionTile(
            title: 'Priority Cold-Chain Express',
            subtitle: '30–45 Mins • Active thermal cold box',
            price: 2500.0.toNaira(),
            icon: Icons.ac_unit,
            isSelected: _isPriorityColdChain,
            onTap: () => setState(() => _isPriorityColdChain = true),
          ),
          const SizedBox(height: 16),

          // Promo Code Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.surfaceContainerHigh),
            ),
            child: Row(
              children: [
                Icon(Icons.confirmation_number_outlined, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Promo Code (try COMFORT10)',
                      hintStyle: textTheme.bodySmall?.copyWith(fontSize: 12),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _applyPromoCode(state.subtotal),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_appliedPromoCode != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: colorScheme.secondary),
                const SizedBox(width: 4),
                Text(
                  'Applied: $_appliedPromoCode (-${_promoDiscount.toNaira()})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),

          // Financial Line Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
              Text(state.subtotal.toNaira(), style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Abuja Dispatch', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(width: 4),
                  Icon(_isPriorityColdChain ? Icons.ac_unit : Icons.electric_moped, size: 13, color: colorScheme.primary),
                ],
              ),
              Text(dispatchFee.toNaira(), style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Clinical Verification Fee', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
              Text('FREE', style: textTheme.labelLarge?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tamper-Evident Thermal Seal', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
              Text('INCLUDED', style: textTheme.labelLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w800)),
            ],
          ),
          if (totalDiscount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dispensary Formulary Savings', style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary)),
                Text('-${totalDiscount.toNaira()}', style: textTheme.labelLarge?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
          const Divider(height: 24),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Total',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                finalTotal.toNaira(),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Checkout CTA
          CCButton(
            label: 'Proceed to Delivery Dispatch (Step 2 of 4)',
            onPressed: () {
              context.push('/checkout/delivery');
            },
          ),
          const SizedBox(height: 12),

          // Security footnote
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 14, color: colorScheme.outline),
              const SizedBox(width: 4),
              Text(
                'PCN Verified • Temperature Monitored',
                style: textTheme.labelSmall?.copyWith(color: colorScheme.outline, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOptionTile({
    required String title,
    required String subtitle,
    required String price,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withValues(alpha: 0.08) : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHigh,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

