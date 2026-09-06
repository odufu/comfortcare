import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/pages/product_details_page.dart';

class FastMovingItemData {
  final String id;
  final String category;
  final String title;
  final String subtitle;
  final double price;
  final double? originalPrice;
  final String? extraNote;
  final Color? extraNoteColor;
  final String topBadgeText;
  final Color topBadgeBgColor;
  final Color topBadgeTextColor;
  final IconData? topBadgeIcon;
  final String imageOverlayBadge;
  final String imageUrl;

  const FastMovingItemData({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.price,
    this.originalPrice,
    this.extraNote,
    this.extraNoteColor,
    required this.topBadgeText,
    required this.topBadgeBgColor,
    required this.topBadgeTextColor,
    this.topBadgeIcon,
    required this.imageOverlayBadge,
    required this.imageUrl,
  });

  ProductEntity toProductEntity() {
    return ProductModel(
      id: id,
      name: title,
      brand: subtitle.split('•').first.trim(),
      genericName: subtitle,
      packSize: subtitle.contains('•') ? subtitle.split('•').last.trim() : subtitle,
      price: price,
      wholesalePrice: (price * 0.8).roundToDouble(),
      category: category,
      description: '$title - $subtitle. Verified authentic with batch tracking.',
      dosageInstructions: 'Use as clinically directed by your physician or pharmacist.',
      activeIngredients: title,
      nafdacNumber: imageOverlayBadge,
      imageUrl: imageUrl,
    );
  }
}

class FastMovingEssentialsSection extends StatelessWidget {
  const FastMovingEssentialsSection({super.key});

  static const List<FastMovingItemData> items = [
    // 1. Coartem
    FastMovingItemData(
      id: 'prod-coartem-80-480',
      category: 'Antimalarial',
      title: 'Coartem 80/480mg',
      subtitle: 'Novartis • 6 Tablets',
      price: 4200.0,
      originalPrice: 4800.0,
      topBadgeText: 'In Stock',
      topBadgeBgColor: Color(0xFFE6F9E6),
      topBadgeTextColor: Color(0xFF1B6D24),
      imageOverlayBadge: 'NAFDAC: 04-2011',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCYoLw9r-RmsXTnOXgJM3rXNLOWTp4aNanpbJT4yg1dHRH5bh8wBJw_eZkLeWPOHuZZ_kVoP-UXzPUtD-sfGLck1C3w9gjm4SZ56JuI0g4F_HK7Ob0BQbZ3Bi0BW4x66DmgyxUZGJx_OLz-TnFNPyQg49zsaiNsncvjT35QqHDYEHcDPjQ54vxtV0J_wBbh5rV6n2cXy_EKqVhLe6jV77o16zZPiZGVmHho2akb6gLVW1oRjZXo8o5CaNgYsVNmVvK3mQ',
    ),
    // 2. Omron M2 Basic BP
    FastMovingItemData(
      id: 'prod-omron-m2-bp',
      category: 'Health Monitor',
      title: 'Omron M2 Basic BP',
      subtitle: 'Upper Arm Digital',
      price: 38500.0,
      extraNote: 'Free Delivery',
      extraNoteColor: Color(0xFF1B6D24),
      topBadgeText: 'Device',
      topBadgeBgColor: Color(0xFFEBF3FE),
      topBadgeTextColor: Color(0xFF006194),
      imageOverlayBadge: '3yr Warranty',
      imageUrl:
          'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=600&auto=format&fit=crop&q=80',
    ),
    // 3. Amoxil 500mg
    FastMovingItemData(
      id: 'prod-amoxil-500',
      category: 'Antibiotic',
      title: 'Amoxil 500mg',
      subtitle: 'GSK • 20 Capsules',
      price: 3600.0,
      extraNote: 'Pack of 20',
      topBadgeText: 'Rx Required',
      topBadgeIcon: Icons.receipt_long,
      topBadgeBgColor: Color(0xFFFFEBEE),
      topBadgeTextColor: Color(0xFFBA1A1A),
      imageOverlayBadge: 'Wholesale Avail',
      imageUrl:
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600&auto=format&fit=crop&q=80',
    ),
    // 4. Latex Gloves (100s)
    FastMovingItemData(
      id: 'prod-latex-gloves',
      category: 'Consumables',
      title: 'Latex Gloves (100s)',
      subtitle: 'Powder-Free Medium',
      price: 6500.0,
      extraNote: 'Carton: ₦58k',
      topBadgeText: 'Bulk Deal',
      topBadgeBgColor: Color(0xFFE6F9E6),
      topBadgeTextColor: Color(0xFF1B6D24),
      imageOverlayBadge: 'Clinic Grade',
      imageUrl:
          'https://images.unsplash.com/photo-1584744982491-665216d95f8b?w=600&auto=format&fit=crop&q=80',
    ),
  ];

  void _showDrugDetails(BuildContext context, String productId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.88,
          child: ProductDetailsPage(productId: productId),
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, FastMovingItemData item) {
    final product = item.toProductEntity();
    context.read<CartBloc>().add(AddToCart(product: product));
    context.showSnackBar('Added ${item.title} to cart!', isSuccess: true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fast-Moving Essentials',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Verified authentic with batch tracking',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.push('/products'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View More',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Responsive Grid (2 columns on mobile, 4 columns on tablet/desktop)
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 2;
            final childAspectRatio = constraints.maxWidth >= 720 ? 0.72 : 0.66;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildProductCard(context, item, isDark, colorScheme);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    FastMovingItemData item,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
      child: InkWell(
        onTap: () => _showDrugDetails(context, item.id),
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
              // Image Container with Top Badge & Overlay Badge
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
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colorScheme.surfaceContainerHighest
                              : item.topBadgeBgColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.topBadgeIcon != null) ...[
                              Icon(
                                item.topBadgeIcon,
                                size: 10,
                                color: isDark
                                    ? colorScheme.error
                                    : item.topBadgeTextColor,
                              ),
                              const SizedBox(width: 3),
                            ],
                            Text(
                              item.topBadgeText,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? colorScheme.onSurface
                                    : item.topBadgeTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bottom Right Glassmorphic Badge (NAFDAC, 3yr Warranty, etc.)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
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
                          item.imageOverlayBadge,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF283044),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Category Tag
              Text(
                item.category,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),

              // Product Title
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Subtitle
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Price & Circular "+" Action Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.price.toNaira(),
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (item.originalPrice != null)
                          Text(
                            item.originalPrice!.toNaira(),
                            style: TextStyle(
                              fontSize: 10.5,
                              decoration: TextDecoration.lineThrough,
                              color: colorScheme.outline,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else if (item.extraNote != null)
                          Text(
                            item.extraNote!,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: item.extraNoteColor ?? colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Circular "+" Button
                  Material(
                    color: const Color(0xFF006194),
                    shape: const CircleBorder(),
                    elevation: 2,
                    shadowColor: const Color(0xFF006194).withValues(alpha: 0.35),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _addToCart(context, item),
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
