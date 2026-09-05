import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final bool isWholesale;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.isWholesale = false,
    this.onAddToCart,
  });

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'timer':
        return Icons.timer_outlined;
      case 'prescriptions':
        return Icons.receipt_long;
      case 'pin_drop':
        return Icons.pin_drop_outlined;
      case 'local_shipping':
        return Icons.local_shipping_outlined;
      case 'verified_user':
        return Icons.verified_user_outlined;
      case 'flash_on':
        return Icons.flash_on;
      case 'check_circle':
        return Icons.check_circle_outline;
      case 'medical_services':
        return Icons.medical_services_outlined;
      case 'inventory_2':
        return Icons.inventory_2_outlined;
      case 'done_all':
        return Icons.done_all;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'verified':
      default:
        return Icons.verified_outlined;
    }
  }

  String _getTag(ProductEntity product) {
    if (product.id == 'prod-coartem-80-480') return 'ANTIMALARIAL • NOVARTIS';
    if (product.id == 'prod-augmentin-625') return 'BROAD SPECTRUM • GSK';
    if (product.id == 'prod-omron-m2') return 'DIAGNOSTIC • OMRON HEALTHCARE';
    if (product.id == 'prod-lonart-ds') return 'ANTIMALARIAL • BLISS GVS';
    if (product.id == 'prod-latex-gloves') return 'CONSUMABLES • SAFETOUCH';
    if (product.id == 'prod-emzor-paracetamol') return 'ANALGESIC • EMZOR NIGERIA';
    return '${product.category.toUpperCase()} • ${product.brand.toUpperCase()}';
  }

  Color _getBadge1Bg(BuildContext context) {
    if (product.id == 'prod-coartem-80-480' || product.id == 'prod-emzor-paracetamol') {
      return const Color(0xFF1B6D24); // secondary green
    }
    if (product.id == 'prod-augmentin-625' || product.requiresPrescription) {
      return const Color(0xFFB7131A); // tertiary red
    }
    if (product.id == 'prod-omron-m2' || product.id == 'prod-lonart-ds') {
      return const Color(0xFFA0F399); // secondary container
    }
    if (product.id == 'prod-latex-gloves') {
      return const Color(0xFFCCE5FF); // primary fixed
    }
    return context.colorScheme.primary;
  }

  Color _getBadge1TextColor(BuildContext context) {
    if (product.id == 'prod-coartem-80-480' ||
        product.id == 'prod-emzor-paracetamol' ||
        product.id == 'prod-augmentin-625' ||
        product.requiresPrescription) {
      return Colors.white;
    }
    if (product.id == 'prod-omron-m2' || product.id == 'prod-lonart-ds') {
      return const Color(0xFF005312);
    }
    if (product.id == 'prod-latex-gloves') {
      return const Color(0xFF001D31);
    }
    return Colors.white;
  }

  Color _getBadge2TextColor(BuildContext context) {
    if (product.id == 'prod-augmentin-625') {
      return context.colorScheme.onSurface;
    }
    if (product.id == 'prod-latex-gloves') {
      return const Color(0xFF1B6D24);
    }
    return context.colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final price = isWholesale ? product.wholesalePrice : product.price;

    // Cart reactivity
    final cartState = context.watch<CartBloc>().state;
    final cartItemIndex = cartState.items.indexWhere((i) => i.product.id == product.id);
    final quantityInCart = cartItemIndex != -1 ? cartState.items[cartItemIndex].quantity : 0;

    final badge1Label = product.badge1 ?? (product.requiresPrescription ? 'Rx Required' : 'In Stock');
    final badge2Label = product.badge2 ?? product.nafdacNumber;
    final packLabel = product.packLabel ?? (isWholesale ? 'Wholesale Bulk' : 'Retail Pack');

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Preview Container
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 176,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () => context.push('/products/${product.id}'),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colorScheme.surfaceContainerLow,
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colorScheme.surfaceContainerLow,
                        child: Icon(
                          Icons.medication,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  // Top Left Badges
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge 1 (Solid pill)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getBadge1Bg(context),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getIconData(product.badge1Icon),
                                size: 12,
                                color: _getBadge1TextColor(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                badge1Label,
                                style: TextStyle(
                                  color: _getBadge1TextColor(context),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Badge 2 (Glassmorphic pill)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getIconData(product.badge2Icon),
                                size: 12,
                                color: _getBadge2TextColor(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                badge2Label,
                                style: TextStyle(
                                  color: _getBadge2TextColor(context),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Upper Category & Brand Tag
          Text(
            _getTag(product),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.6,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Product Title
          InkWell(
            onTap: () => context.push('/products/${product.id}'),
            child: Text(
              product.name,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),

          // Subtitle / Generic Name
          Text(
            product.genericName,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Bottom Pricing Tray
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        packLabel,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        price.toNaira(),
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (product.cartonText != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          product.cartonText!,
                          style: textTheme.labelSmall?.copyWith(
                            color: product.isCartonHighlight
                                ? const Color(0xFF1B6D24)
                                : colorScheme.onSurfaceVariant,
                            fontWeight: product.isCartonHighlight
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Cart Stepper or Add Button
                if (quantityInCart > 0)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Minus Button
                        InkWell(
                          onTap: () {
                            if (quantityInCart == 1) {
                              context.read<CartBloc>().add(RemoveCartItem(product.id));
                            } else {
                              context.read<CartBloc>().add(UpdateCartItemQuantity(
                                    productId: product.id,
                                    quantity: quantityInCart - 1,
                                  ));
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLowest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '$quantityInCart',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // Plus Button
                        InkWell(
                          onTap: () {
                            context.read<CartBloc>().add(UpdateCartItemQuantity(
                                  productId: product.id,
                                  quantity: quantityInCart + 1,
                                ));
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  InkWell(
                    onTap: () {
                      context.read<CartBloc>().add(AddToCart(product: product));
                      onAddToCart?.call();
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            product.id == 'prod-augmentin-625'
                                ? Icons.add_shopping_cart
                                : Icons.add,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
