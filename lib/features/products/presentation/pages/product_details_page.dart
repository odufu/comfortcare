import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../../core/widgets/cc_button.dart';
import '../../../../core/widgets/cc_chip.dart';
import '../../../../core/widgets/cc_stepper.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_event.dart';
import '../bloc/products_state.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(LoadProductDetails(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        final product = state.selectedProduct ??
            (state.products.isNotEmpty
                ? state.products.firstWhere(
                    (p) => p.id == widget.productId,
                    orElse: () => state.products.first,
                  )
                : null);

        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          );
        }

        final unitPrice = state.isWholesale ? product.wholesalePrice : product.price;
        final totalPrice = unitPrice * _quantity;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text(product.name),
            actions: [
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_bag_outlined),
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${context.watch<CartBloc>().state.totalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () => context.push('/cart'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Hero Image
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.surfaceContainerHigh),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Center(
                          child: Icon(Icons.medication, size: 70, color: colorScheme.primary),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Row(
                          children: [
                            if (product.requiresPrescription)
                              CCChip(
                                label: 'Rx Required',
                                variant: CCChipVariant.tertiary,
                              ),
                            if (product.isColdChain) ...[
                              const SizedBox(width: 8),
                              CCChip(
                                label: 'Cold-Chain 2°C - 8°C',
                                variant: CCChipVariant.primary,
                                icon: const Icon(Icons.ac_unit, size: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Brand & Generic
                Text(
                  product.brand.toUpperCase(),
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.genericName,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Clinical Badges Strip
                Row(
                  children: [
                    CCChip(
                      label: product.nafdacNumber,
                      icon: Icon(Icons.verified, size: 14, color: colorScheme.secondary),
                      variant: CCChipVariant.secondary,
                    ),
                    const SizedBox(width: 8),
                    CCChip(
                      label: '${product.stock} in Stock (Abuja Hub)',
                      variant: CCChipVariant.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Price & Pack Size
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.surfaceContainerHigh),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dispense Price',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            unitPrice.toNaira(),
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                          if (state.isWholesale)
                            Text(
                              'Wholesale Bulk Rate (Tier 2)',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          product.packSize,
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Clinical Dosage Instructions
                Text(
                  'Clinical Dosage & Administration',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colorScheme.surfaceContainerHigh),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.schedule, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          product.dosageInstructions,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Active Ingredients & Description
                Text(
                  'Active Ingredients & Pharmacology',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.activeIngredients,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),

                // Storage Temperature
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.thermostat, color: colorScheme.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Storage: ${product.storageTemp}',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              border: Border(
                top: BorderSide(color: colorScheme.surfaceContainerHigh),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: context.isDarkMode ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  CCStepper(
                    value: _quantity,
                    onChanged: (newVal) {
                      setState(() {
                        _quantity = newVal;
                      });
                    },
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CCButton(
                      label: 'Add to Cart • ${totalPrice.toNaira()}',
                      onPressed: () {
                        context.read<CartBloc>().add(
                              AddToCart(product: product, quantity: _quantity),
                            );
                        context.showSnackBar(
                          '$_quantity x ${product.name} added to prescription cart.',
                          isSuccess: true,
                        );
                        context.push('/cart');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
