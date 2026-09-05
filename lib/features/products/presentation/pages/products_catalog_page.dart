import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
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
    'Antimalarials',
    'Antibiotics',
    'Cardiovascular & BP',
    'Health Devices',
    'Hospital Consumables',
    'Vitamins & Immunity',
  ];

  String? _activeMicroFilter;
  String _currentLocation = 'Comfort Mall, Abuja';

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

  void _showLocationPicker() {
    final locations = [
      'Comfort Mall, Abuja',
      'Wuse II Medical Hub',
      'Life Camp Central, Abuja',
      'Garki Hospital Area',
      'Maitama District',
    ];

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
                      'Select Delivery Hub',
                      style: ctx.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...locations.map((loc) {
                  final isSelected = loc == _currentLocation;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.location_on,
                      color: isSelected ? const Color(0xFF1B6D24) : ctx.colorScheme.outline,
                    ),
                    title: Text(
                      loc,
                      style: ctx.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? ctx.colorScheme.primary : ctx.colorScheme.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFF1B6D24))
                        : null,
                    onTap: () {
                      setState(() => _currentLocation = loc);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
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
        // Apply micro filters locally on top of state.products
        var filteredProducts = state.products;
        if (_activeMicroFilter == 'In Stock') {
          filteredProducts = filteredProducts.where((p) => p.stock > 0).toList();
        } else if (_activeMicroFilter == 'NAFDAC Verified') {
          filteredProducts =
              filteredProducts.where((p) => p.nafdacNumber.isNotEmpty).toList();
        } else if (_activeMicroFilter == 'Rx Required') {
          filteredProducts =
              filteredProducts.where((p) => p.requiresPrescription).toList();
        } else if (_activeMicroFilter == 'Cold-Chain') {
          filteredProducts = filteredProducts.where((p) => p.isColdChain).toList();
        }

        final cartState = context.watch<CartBloc>().state;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // 1. Top Bar Header
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
                            // Logo
                            InkWell(
                              onTap: () => context.go('/dashboard'),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/logo.png',
                                    height: 30,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.local_pharmacy, color: colorScheme.primary, size: 28),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                              ),
                            ),

                            // Deliver to pill dropdown
                            Expanded(
                              child: InkWell(
                                onTap: _showLocationPicker,
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Color(0xFF1B6D24),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'DELIVER TO',
                                              style: textTheme.labelSmall?.copyWith(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                            Text(
                                              _currentLocation,
                                              style: textTheme.labelMedium?.copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: colorScheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Orders receipt icon button
                            InkWell(
                              onTap: () => context.go('/orders'),
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.receipt_long_outlined,
                                  size: 20,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),

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

                    // 2. Search & Scan Header Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Search Input Field
                                Expanded(
                                  child: Container(
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: Row(
                                      children: [
                                        Icon(Icons.search, color: colorScheme.primary, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            controller: _searchController,
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.onSurface,
                                              fontSize: 13,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Search antibiotics, malaria meds, BP...',
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
                                            icon: Icon(
                                              Icons.mic,
                                              size: 18,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              context.showSnackBar('Listening for voice search...');
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Document / Prescription scanner button
                                InkWell(
                                  onTap: _showScannerDialog,
                                  borderRadius: BorderRadius.circular(22),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHigh,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.document_scanner_outlined,
                                      color: colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Open Filters button
                                InkWell(
                                  onTap: () => _showFilterBottomSheet(context),
                                  borderRadius: BorderRadius.circular(22),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.tune,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Wholesale vs Retail Dual Segment Switch
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  // Retail Tab
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        if (state.isWholesale) {
                                          context.read<ProductsBloc>().add(
                                                LoadProducts(
                                                  category: state.selectedCategory,
                                                  query: state.searchQuery,
                                                  isWholesale: false,
                                                ),
                                              );
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: !state.isWholesale
                                              ? colorScheme.surfaceContainerLowest
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: !state.isWholesale
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.08),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person_outline,
                                              size: 16,
                                              color: !state.isWholesale
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Retail (Packs)',
                                              style: textTheme.labelMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: !state.isWholesale
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Wholesale Tab
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        if (!state.isWholesale) {
                                          context.read<ProductsBloc>().add(
                                                LoadProducts(
                                                  category: state.selectedCategory,
                                                  query: state.searchQuery,
                                                  isWholesale: true,
                                                ),
                                              );
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: state.isWholesale
                                              ? colorScheme.surfaceContainerLowest
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: state.isWholesale
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.08),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.domain_outlined,
                                              size: 16,
                                              color: state.isWholesale
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Wholesale Bulk',
                                              style: textTheme.labelMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: state.isWholesale
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFA0F399),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                'SAVE 25%',
                                                style: TextStyle(
                                                  color: Color(0xFF005312),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.2,
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
                          ],
                        ),
                      ),
                    ),

                    // 3. Category Pill Carousel
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _categories.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final cat = _categories[i];
                            final isSelected = state.selectedCategory == cat;
                            return InkWell(
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
                            );
                          },
                        ),
                      ),
                    ),

                    // 4. Smart Micro-Filter Badges
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: SizedBox(
                          height: 32,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              // In Stock (Abuja Hub)
                              _buildMicroBadge(
                                label: 'In Stock (Abuja Hub)',
                                icon: Icons.warehouse_outlined,
                                color: const Color(0xFF1B6D24),
                                isSelected: _activeMicroFilter == 'In Stock',
                                onTap: () => setState(() {
                                  _activeMicroFilter =
                                      _activeMicroFilter == 'In Stock' ? null : 'In Stock';
                                }),
                              ),
                              const SizedBox(width: 8),

                              // NAFDAC Verified
                              _buildMicroBadge(
                                label: 'NAFDAC Verified',
                                icon: Icons.verified_outlined,
                                color: colorScheme.primary,
                                isSelected: _activeMicroFilter == 'NAFDAC Verified',
                                onTap: () => setState(() {
                                  _activeMicroFilter =
                                      _activeMicroFilter == 'NAFDAC Verified'
                                          ? null
                                          : 'NAFDAC Verified';
                                }),
                              ),
                              const SizedBox(width: 8),

                              // Rx Required
                              _buildMicroBadge(
                                label: 'Rx Required',
                                icon: Icons.receipt_long,
                                color: const Color(0xFFB7131A),
                                isSelected: _activeMicroFilter == 'Rx Required',
                                onTap: () => setState(() {
                                  _activeMicroFilter =
                                      _activeMicroFilter == 'Rx Required' ? null : 'Rx Required';
                                }),
                              ),
                              const SizedBox(width: 8),

                              // Cold-Chain
                              _buildMicroBadge(
                                label: 'Cold-Chain',
                                icon: Icons.ac_unit,
                                color: colorScheme.primary,
                                isSelected: _activeMicroFilter == 'Cold-Chain',
                                onTap: () => setState(() {
                                  _activeMicroFilter =
                                      _activeMicroFilter == 'Cold-Chain' ? null : 'Cold-Chain';
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 5. Abuja Hub Fulfillment Micro-Banner
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.surfaceContainerLow,
                              colorScheme.surfaceContainer,
                              colorScheme.surfaceContainerLow,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: Color(0xFFA0F399),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.bolt,
                                color: Color(0xFF005312),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Abuja Dispatch Center Live',
                                    style: textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: colorScheme.onSurface,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Guaranteed cold-chain delivery within 20-35 mins',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFA0F399).withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Wuse II • Open',
                                style: TextStyle(
                                  color: Color(0xFF1B6D24),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 6. Medication & Supplies List / Grid
                    if (state.status == ProductsStatus.loading)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(48.0),
                          child: Center(
                            child: CircularProgressIndicator(color: colorScheme.primary),
                          ),
                        ),
                      )
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
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = filteredProducts[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ProductCard(
                                  product: product,
                                  isWholesale: state.isWholesale,
                                  onAddToCart: () {
                                    context.showSnackBar(
                                      '${product.name} added to cart',
                                      isSuccess: true,
                                    );
                                  },
                                ),
                              );
                            },
                            childCount: filteredProducts.length,
                          ),
                        ),
                      ),
                  ],
                ),

                // 7. Sticky Floating Order Bottom Bar
                if (cartState.totalItems > 0)
                  Positioned(
                    bottom: 12,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF283044),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left Icon with item count
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF006194),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shopping_bag,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B6D24),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF283044),
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
                          const SizedBox(width: 12),

                          // Text Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${cartState.totalItems} ${cartState.totalItems == 1 ? 'item' : 'items'} • ${cartState.subtotal.toNaira()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFA0F399),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'Express Abuja Dispatch',
                                      style: TextStyle(
                                        color: Color(0xFFCCE5FF),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // View Cart Button
                          InkWell(
                            onTap: () => context.push('/cart'),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF006194),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF006194).withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View Cart',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ],
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
        );
      },
    );
  }

  Widget _buildMicroBadge({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : colorScheme.surfaceContainerHigh,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : colorScheme.onSurface,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
