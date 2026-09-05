import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/cc_app_bar.dart';
import '../../../../core/widgets/cc_chip.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_event.dart';
import '../bloc/products_state.dart';
import '../widgets/product_card.dart';

class ProductsCatalogPage extends StatefulWidget {
  const ProductsCatalogPage({super.key});

  @override
  State<ProductsCatalogPage> createState() => _ProductsCatalogPageState();
}

class _ProductsCatalogPageState extends State<ProductsCatalogPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Malaria Meds',
    'Antibiotics',
    'Cold Chain Insulin',
    'BP Monitors',
    'Vitamins & Zinc',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(const LoadProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: CCAppBar(
            title: 'Medicines & Formulary',
            subtitle: state.isWholesale ? 'Wholesale Pricing Active' : 'NAFDAC Certified Dispensary',
            cartItemCount: context.watch<CartBloc>().state.totalItems,
          ),
          body: Column(
            children: [
              // Search and Wholesale Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.surfaceContainerHigh),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search generic, brand, or NAFDAC code...',
                          hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                          prefixIcon: Icon(Icons.search, color: colorScheme.outline),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<ProductsBloc>().add(const SearchProducts(''));
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (val) {
                          context.read<ProductsBloc>().add(SearchProducts(val));
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Categories horizontal scroll
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = _categories[i];
                          final isSelected = state.selectedCategory == cat;
                          return CCChip(
                            label: cat,
                            isSelected: isSelected,
                            onTap: () {
                              context.read<ProductsBloc>().add(SelectCategoryFilter(cat));
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Product Count & Mode Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${state.products.length} Products',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.read<ProductsBloc>().add(
                              LoadProducts(
                                category: state.selectedCategory,
                                query: state.searchQuery,
                                isWholesale: !state.isWholesale,
                              ),
                            );
                      },
                      child: Row(
                        children: [
                          Icon(
                            state.isWholesale ? Icons.check_box : Icons.check_box_outline_blank,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Wholesale Rates',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Product Grid
              Expanded(
                child: state.status == ProductsStatus.loading
                    ? Center(
                        child: CircularProgressIndicator(color: colorScheme.primary),
                      )
                    : state.products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 56, color: colorScheme.outline),
                                const SizedBox(height: 12),
                                Text(
                                  'No medications match your query',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Try a different drug name, active ingredient, or category.',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.68,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: state.products.length,
                            itemBuilder: (context, i) {
                              final product = state.products[i];
                              return ProductCard(
                                product: product,
                                isWholesale: state.isWholesale,
                                onAddToCart: () {
                                  context.read<CartBloc>().add(AddToCart(product: product));
                                  context.showSnackBar(
                                    '${product.name} added to prescription cart.',
                                    isSuccess: true,
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
