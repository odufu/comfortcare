import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../../core/widgets/cc_button.dart';
import '../../../../core/widgets/cc_chip.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../orders/presentation/bloc/orders_bloc.dart';
import '../../../orders/presentation/bloc/orders_event.dart';
import '../../domain/entities/payment_transaction.dart';
import '../bloc/payments_bloc.dart';
import '../bloc/payments_event.dart';
import '../bloc/payments_state.dart';

class PaymentClinicalAuthorizationPage extends StatelessWidget {
  const PaymentClinicalAuthorizationPage({super.key});

  void _onAuthorizeAndPay(BuildContext context, CartState cartState) {
    context.read<PaymentsBloc>().add(
          AuthorizeAndPayEvent(
            orderId: 'ORDER-${DateTime.now().millisecondsSinceEpoch}',
            amount: cartState.grandTotal,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final cartState = context.watch<CartBloc>().state;

    return BlocConsumer<PaymentsBloc, PaymentsState>(
      listener: (context, state) {
        if (state.status == PaymentsStatus.authorized) {
          // Place order in orders bloc
          context.read<OrdersBloc>().add(
                PlaceOrderEvent(
                  items: cartState.items,
                  totalAmount: cartState.grandTotal,
                ),
              );
          // Clear cart
          context.read<CartBloc>().add(ClearCartEvent());
          // Navigate to Step 4: Confirmation
          context.go('/checkout/confirmed');
        } else if (state.status == PaymentsStatus.error && state.errorMessage != null) {
          context.showSnackBar(state.errorMessage!, isError: true);
        }
      },
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
                const Text('Clinical Checkout & Payment'),
                Text(
                  'Step 3 of 4: Authorization & Gateway',
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
                // Step Progress Bar (Step 3 active)
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
                  ],
                ),
                const SizedBox(height: 18),

                // Section 1: Clinical Sign-off & Prescriber Badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colorScheme.surfaceContainerHigh),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
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
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer.withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person, color: colorScheme.primary, size: 24),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Pharm. Halima Bello',
                                        style: textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      CCChip(
                                        label: 'PCN #44912',
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'ComfortCare Supervising Pharmacist',
                                    style: textTheme.bodySmall?.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          CCChip(
                            label: 'Vetted & Approved',
                            variant: CCChipVariant.secondary,
                            icon: const Icon(Icons.verified, size: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                                Icon(Icons.task_alt, size: 14, color: colorScheme.secondary),
                                const SizedBox(width: 6),
                                Text(
                                  'Ready for Instant Dispense',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Patient allergy profile clear: No adverse reactions to Artemether/Lumefantrine or Paracetamol confirmed via AI triage protocol.',
                              style: textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Clinical Docket #ABJ-89104',
                            style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                          ),
                          Text(
                            'Cold-Chain Staged',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Section 2: Payment Method Selection
                Text(
                  'Select Payment Method',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // Method 1: Gateway
                _buildPaymentOptionTile(
                  context,
                  method: PaymentMethod.gateway,
                  title: 'Paystack / Flutterwave Instant Gateway',
                  subtitle: 'Cards, USSD, Verve, Apple Pay & Bank App Transfer',
                  icon: Icons.credit_card,
                  badge: 'INSTANT',
                  isSelected: state.selectedMethod == PaymentMethod.gateway,
                  onTap: () {
                    context.read<PaymentsBloc>().add(
                          const SelectPaymentMethodEvent(PaymentMethod.gateway),
                        );
                  },
                ),
                const SizedBox(height: 10),

                // Method 2: Health Wallet
                _buildPaymentOptionTile(
                  context,
                  method: PaymentMethod.wallet,
                  title: 'ComfortCare Health Wallet',
                  subtitle: 'Balance: ₦24,500 Available for instant debit',
                  icon: Icons.account_balance_wallet,
                  badge: 'WALLET',
                  isSelected: state.selectedMethod == PaymentMethod.wallet,
                  onTap: () {
                    context.read<PaymentsBloc>().add(
                          const SelectPaymentMethodEvent(PaymentMethod.wallet),
                        );
                  },
                ),
                const SizedBox(height: 10),

                // Method 3: Direct Bank Transfer
                _buildPaymentOptionTile(
                  context,
                  method: PaymentMethod.bankTransfer,
                  title: 'Direct Bank Transfer',
                  subtitle: 'Zenith Bank • ComfortCare Clinical Logistics',
                  icon: Icons.account_balance,
                  badge: 'TRANSFER',
                  isSelected: state.selectedMethod == PaymentMethod.bankTransfer,
                  onTap: () {
                    context.read<PaymentsBloc>().add(
                          const SelectPaymentMethodEvent(PaymentMethod.bankTransfer),
                        );
                  },
                ),
                const SizedBox(height: 10),

                // Method 4: Cash on Delivery
                _buildPaymentOptionTile(
                  context,
                  method: PaymentMethod.cashOnDelivery,
                  title: 'Cash / POS on Clinical Delivery',
                  subtitle: 'Pay rider upon medicine verification (Abuja Metro)',
                  icon: Icons.local_atm,
                  badge: 'POS / CASH',
                  isSelected: state.selectedMethod == PaymentMethod.cashOnDelivery,
                  onTap: () {
                    context.read<PaymentsBloc>().add(
                          const SelectPaymentMethodEvent(PaymentMethod.cashOnDelivery),
                        );
                  },
                ),
                const SizedBox(height: 22),

                // Price Summary
                Container(
                  padding: const EdgeInsets.all(16),
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
                          Text('Order Subtotal', style: textTheme.bodyMedium),
                          Text(cartState.subtotal.toNaira(), style: textTheme.labelLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Abuja Priority Delivery', style: textTheme.bodyMedium),
                          Text(cartState.deliveryFee.toNaira(), style: textTheme.labelLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Clinical Pharmacist Review', style: textTheme.bodyMedium),
                          Text('FREE', style: textTheme.labelLarge?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      if (cartState.discount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Dispensary Formulary Discount', style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary)),
                            Text('-${cartState.discount.toNaira()}', style: textTheme.labelLarge?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ],
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grand Total',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            cartState.grandTotal.toNaira(),
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                CCButton(
                  label: 'Authorize Payment & Release Meds (${cartState.grandTotal.toNaira()})',
                  isLoading: state.status == PaymentsStatus.processing,
                  onPressed: () => _onAuthorizeAndPay(context, cartState),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOptionTile(
    BuildContext context, {
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
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
                      Flexible(
                        child: Text(
                          title,
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      CCChip(
                        label: badge,
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
