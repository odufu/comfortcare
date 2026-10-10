import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_event.dart';
import '../bloc/products_state.dart';
import '../widgets/product_card.dart';
import '../widgets/product_card_skeleton.dart';

class ProductsCatalogPage extends StatefulWidget {
  const ProductsCatalogPage({super.key});

  @override
  State<ProductsCatalogPage> createState() => _ProductsCatalogPageState();
}

class _ProductsCatalogPageState extends State<ProductsCatalogPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Antimalarials',
    'Antibiotics',
    'Cardiovascular & BP',
    'Health Devices',
    'Hospital Consumables',
    'Vitamins & Immunity',
  ];

  String? _activeMicroFilter;

  @override
  void initState() {
    super.initState();
    final currentProducts = context.read<ProductsBloc>().state.products;
    if (currentProducts.isEmpty) {
      context.read<ProductsBloc>().add(const LoadProducts());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showScannerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ctx.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.document_scanner, color: ctx.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            const Text('Smart Medical Scanner'),
          ],
        ),
        content: const Text(
          'Point your camera at a prescription sheet or pharmaceutical barcode to instantly lookup medication records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.showSnackBar('Camera scanning active. Point at barcode.', isSuccess: true);
            },
            child: const Text('Start Camera'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Catalog Filters',
                      style: ctx.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _activeMicroFilter = null);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.receipt_long, color: Color(0xFFB7131A)),
                  title: const Text('Prescription Required Only'),
                  trailing: Switch(
                    value: _activeMicroFilter == 'Rx Required',
                    onChanged: (val) {
                      setState(() => _activeMicroFilter = val ? 'Rx Required' : null);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.ac_unit, color: Color(0xFF006194)),
                  title: const Text('Cold-Chain Certified'),
                  trailing: Switch(
                    value: _activeMicroFilter == 'Cold-Chain',
                    onChanged: (val) {
                      setState(() => _activeMicroFilter = val ? 'Cold-Chain' : null);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.warehouse, color: Color(0xFF1B6D24)),
                  title: const Text('In Stock (Abuja Hub)'),
                  trailing: Switch(
                    value: _activeMicroFilter == 'In Stock',
                    onChanged: (val) {
                      setState(() => _activeMicroFilter = val ? 'In Stock' : null);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        final filteredProducts = _activeMicroFilter == null
            ? state.products
            : state.products.where((p) {
                if (_activeMicroFilter == 'Rx Required') {
                  return p.requiresPrescription || (p.badge1 == 'Rx Required');
                }
                if (_activeMicroFilter == 'Cold-Chain') {
                  return p.isColdChain || (p.badge1 == 'Cold-Chain');
                }
                if (_activeMicroFilter == 'In Stock') {
                  return p.stock > 0;
                }
                return true;
              }).toList();

        final cartState = context.watch<CartBloc>().state;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Stack(
                  children: [
                    CustomScrollView(
                  slivers: [
                    // 1. Sleek Top Bar Header with Embedded Search & Cart
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.95),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Brand Logo
                            InkWell(
                              onTap: () => context.go('/dashboard'),
                              borderRadius: BorderRadius.circular(20),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/logo.png',
                                    height: 32,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.local_pharmacy, color: colorScheme.primary, size: 28),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Embedded Search Bar in Header
                            Expanded(
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  children: [
                                    Icon(Icons.search, color: colorScheme.primary, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface,
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Search medications...',
                                          hintStyle: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.outline,
                                            fontSize: 13,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (val) {
                                          context.read<ProductsBloc>().add(SearchProducts(val));
                                        },
                                      ),
                                    ),
                                    if (_searchController.text.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 16),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          _searchController.clear();
                                          context
                                              .read<ProductsBloc>()
                                              .add(const SearchProducts(''));
                                        },
                                      )
                                    else
                                      IconButton(
                                        icon: const Icon(Icons.document_scanner_outlined, size: 18),
                                        color: colorScheme.primary,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: _showScannerDialog,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Cart icon button with badge
                            InkWell(
                              onTap: () => context.push('/cart'),
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  shape: BoxShape.circle,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 20,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    if (cartState.totalItems > 0)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: colorScheme.surfaceContainerLowest,
                                              width: 1.5,
                                            ),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            '${cartState.totalItems}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Single Unified Filter Row: Tune filter button + Category pills
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 8),
                        child: SizedBox(
                          height: 38,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              // Tune filter button
                              InkWell(
                                onTap: () => _showFilterBottomSheet(context),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _activeMicroFilter != null
                                        ? colorScheme.primary
                                        : colorScheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _activeMicroFilter != null
                                          ? colorScheme.primary
                                          : colorScheme.surfaceContainerHigh,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.tune,
                                        size: 15,
                                        color: _activeMicroFilter != null
                                            ? Colors.white
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        _activeMicroFilter ?? 'Filter',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _activeMicroFilter != null
                                              ? Colors.white
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Category Pills
                              ..._categories.map((cat) {
                                final isSelected = state.selectedCategory == cat;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () {
                                      context.read<ProductsBloc>().add(SelectCategoryFilter(cat));
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.surfaceContainer,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: colorScheme.primary.withValues(alpha: 0.25),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        cat,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 6. Medication & Supplies List / Grid
                    if (state.status == ProductsStatus.loading && filteredProducts.isEmpty)
                      const ProductSkeletonGrid(itemCount: 6)
                    else if (filteredProducts.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 56, color: colorScheme.outline),
                              const SizedBox(height: 12),
                              Text(
                                'No medications match your selection',
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try clearing your search query or smart micro-filters.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Builder(
                        builder: (context) {
                          final screenWidth = MediaQuery.sizeOf(context).width;
                          final crossAxisCount = screenWidth >= 1024 ? 4 : (screenWidth >= 720 ? 3 : 2);
                          final childAspectRatio = screenWidth >= 720 ? 0.72 : 0.66;

                          return SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            sliver: SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: childAspectRatio,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final product = filteredProducts[index];
                                  return ProductCard(
                                    product: product,
                                    isWholesale: state.isWholesale,
                                    onAddToCart: () {
                                      context.showSnackBar(
                                        '${product.name} added to cart',
                                        isSuccess: true,
                                      );
                                    },
                                  );
                                },
                                childCount: filteredProducts.length,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}
