import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../domain/entities/product.dart';
import '../pages/product_details_page.dart';

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

  void _showDrugDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.88,
          child: ProductDetailsPage(productId: product.id),
        ),
      ),
    );
  }

  String _getCategoryTag() {
    final cat = product.category.trim();
    if (cat.contains('Antimalarial')) return 'Antimalarial';
    if (cat.contains('Cardiovascular') || cat.contains('Device') || product.id.contains('omron')) {
      return 'Health Monitor';
    }
    if (cat.contains('Antibiotic')) return 'Antibiotic';
    if (cat.contains('Consumables') || product.id.contains('gloves')) return 'Consumables';
    if (cat.contains('Vitamin')) return 'Vitamins';
    return cat;
  }

  Widget _buildTopBadge(BuildContext context, bool isDark, ColorScheme colorScheme) {
    final isRx = product.requiresPrescription || (product.badge1 == 'Rx Required');
    final isDevice = product.category.contains('Device') ||
        product.category.contains('Cardiovascular') ||
        (product.badge1 == 'Device') ||
        product.id.contains('omron');
    final isBulk = product.badge1 == 'Bulk Deal';

    Color bg;
    Color textColor;
    IconData? icon;
    String label;

    if (isRx) {
      bg = isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFFFEBEE);
      textColor = isDark ? colorScheme.error : const Color(0xFFBA1A1A);
      icon = Icons.receipt_long;
      label = 'Rx Required';
    } else if (isDevice) {
      bg = isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFEBF3FE);
      textColor = isDark ? colorScheme.primary : const Color(0xFF006194);
      label = 'Device';
    } else if (isBulk) {
      bg = isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFE6F9E6);
      textColor = isDark ? const Color(0xFFA0F399) : const Color(0xFF1B6D24);
      label = 'Bulk Deal';
    } else {
      bg = isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFE6F9E6);
      textColor = isDark ? const Color(0xFFA0F399) : const Color(0xFF1B6D24);
      label = product.badge1 ?? 'In Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayBadge(bool isDark) {
    final text = product.badge2 ?? product.nafdacNumber;
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF283044),
        ),
      ),
    );
  }

  Widget _buildSubPriceNote(ColorScheme colorScheme) {
    if (product.id == 'prod-coartem-80-480') {
      return Text(
        '₦4,800',
        style: TextStyle(
          fontSize: 10.5,
          decoration: TextDecoration.lineThrough,
          color: colorScheme.outline,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    if (product.id.contains('omron') || product.cartonText == 'Free Delivery') {
      return const Text(
        'Free Delivery',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B6D24),
        ),
      );
    }

    if (product.id.contains('amoxil') || product.cartonText == 'Pack of 20') {
      return Text(
        'Pack of 20',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (product.cartonText != null && product.cartonText!.isNotEmpty) {
      return Text(
        product.cartonText!,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: product.isCartonHighlight
              ? const Color(0xFF1B6D24)
              : colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (isWholesale) {
      return Text(
        'Wholesale Unit',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Text(
      product.packLabel ?? 'In Stock',
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;
    final price = isWholesale ? product.wholesalePrice : product.price;

    // Cart reactivity
    final cartState = context.watch<CartBloc>().state;
    final cartItemIndex = cartState.items.indexWhere((i) => i.product.id == product.id);
    final quantityInCart = cartItemIndex != -1 ? cartState.items[cartItemIndex].quantity : 0;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
      child: InkWell(
        onTap: () => _showDrugDetails(context),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Container with Top-Left Badge and Bottom-Right Badge
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: colorScheme.surfaceContainerLow,
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Icon(
                            Icons.medication,
                            color: colorScheme.primary,
                            size: 32,
                          ),
                        ),
                      ),
                    ),

                    // Top Left Status Badge (In Stock, Device, Rx Required, Bulk Deal)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _buildTopBadge(context, isDark, colorScheme),
                    ),

                    // Bottom Right Glassmorphic Badge (NAFDAC, 3yr Warranty, etc.)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: _buildOverlayBadge(isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 2. Category Tag
              Text(
                _getCategoryTag(),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // 3. Product Title
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),

              // 4. Subtitle
              Text(
                product.genericName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // 5. Price & Circular "+" / Stepper Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price.toNaira(),
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        _buildSubPriceNote(colorScheme),
                      ],
                    ),
                  ),

                  // Circular "+" button or active stepper
                  if (quantityInCart > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006194),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF006194).withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Icon(Icons.remove, size: 14, color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '$quantityInCart',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              context.read<CartBloc>().add(UpdateCartItemQuantity(
                                    productId: product.id,
                                    quantity: quantityInCart + 1,
                                  ));
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Icon(Icons.add, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Material(
                      color: const Color(0xFF006194),
                      shape: const CircleBorder(),
                      elevation: 2,
                      shadowColor: const Color(0xFF006194).withValues(alpha: 0.35),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          context.read<CartBloc>().add(AddToCart(product: product));
                          onAddToCart?.call();
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
