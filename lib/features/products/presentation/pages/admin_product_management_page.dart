import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../domain/entities/product.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_event.dart';
import '../bloc/products_state.dart';

class AdminProductManagementPage extends StatefulWidget {
  const AdminProductManagementPage({super.key});

  @override
  State<AdminProductManagementPage> createState() =>
      _AdminProductManagementPageState();
}

class _AdminProductManagementPageState
    extends State<AdminProductManagementPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _categories = [
    'All',
    'Antimalarials',
    'Antibiotics',
    'Cardiovascular & BP',
    'Vitamins & Immunity',
    'Health Devices',
    'Hospital Consumables',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(const LoadProducts());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ComfortCare Inventory Hub',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Connected to Supabase (${ApiConstants.productsTable})',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Products',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProductsBloc>().add(LoadProducts(
                    category: _selectedCategory == 'All' ? null : _selectedCategory,
                    query: _searchQuery,
                  ));
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Add Product'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _openProductFormDialog(context),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final products = state.products.where((p) {
            final matchesCat = _selectedCategory == 'All' ||
                p.category.toLowerCase().contains(_selectedCategory.toLowerCase());
            final matchesQuery = _searchQuery.isEmpty ||
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.genericName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.nafdacNumber.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesCat && matchesQuery;
          }).toList();

          final totalValuation = products.fold<double>(
            0.0,
            (acc, p) => acc + (p.price * p.stock),
          );
          final lowStockCount = products.where((p) => p.stock < 50).length;

          return Column(
            children: [
              // Metric Ribbon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                child: Row(
                  children: [
                    _buildMetricPill(
                      context,
                      label: 'Total SKUs',
                      value: '${products.length}',
                      icon: Icons.inventory_2_outlined,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _buildMetricPill(
                      context,
                      label: 'Stock Value',
                      value: totalValuation.toNaira(),
                      icon: Icons.monetization_on_outlined,
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 12),
                    _buildMetricPill(
                      context,
                      label: 'Low Stock (<50)',
                      value: '$lowStockCount',
                      icon: Icons.warning_amber_rounded,
                      color: lowStockCount > 0
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF10B981),
                    ),
                  ],
                ),
              ),

              // Search & Filter Controls
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search medication by brand, generic, or NAFDAC...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onChanged: (val) {
                        setState(() => _searchQuery = val.trim());
                      },
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() => _selectedCategory = cat);
                              },
                              selectedColor:
                                  colorScheme.primary.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Product List
              Expanded(
                child: state.status == ProductsStatus.loading && products.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inventory,
                                    size: 48,
                                    color: colorScheme.outline.withValues(alpha: 0.5)),
                                const SizedBox(height: 12),
                                Text(
                                  'No medications found',
                                  style: textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                FilledButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add First Product'),
                                  onPressed: () => _openProductFormDialog(context),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: products.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = products[index];
                              return _buildProductAdminCard(context, item);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricPill(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final textTheme = context.textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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

  Widget _buildProductAdminCard(BuildContext context, ProductEntity item) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 64,
                height: 64,
                color: colorScheme.surfaceContainerHighest,
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.medication_outlined,
                          color: colorScheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.medication_outlined,
                        color: colorScheme.primary,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.requiresPrescription) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Rx',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (item.isColdChain) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '❄️ Cold-Chain',
                            style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.brand} • ${item.category} • ${item.packSize}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        item.price.toNaira(),
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Wholesale: ${item.wholesalePrice.toNaira()}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Stock Stepper & Quick Action Buttons
                  Row(
                    children: [
                      Text(
                        'Stock:',
                        style: textTheme.labelSmall?.copyWith(fontSize: 11),
                      ),
                      const SizedBox(width: 6),
                      // Decrement
                      IconButton.filledTonal(
                        icon: const Icon(Icons.remove, size: 14),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 26, minHeight: 26),
                        onPressed: item.stock > 0
                            ? () {
                                context.read<ProductsBloc>().add(
                                      UpdateProductStockEvent(
                                          item.id, item.stock - 1),
                                    );
                              }
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.stock < 20
                              ? Colors.red.withValues(alpha: 0.1)
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.stock}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: item.stock < 20 ? Colors.red : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Increment
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add, size: 14),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 26, minHeight: 26),
                        onPressed: () {
                          context.read<ProductsBloc>().add(
                                UpdateProductStockEvent(item.id, item.stock + 1),
                              );
                        },
                      ),
                      const Spacer(),

                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: 'Edit details',
                        onPressed: () => _openProductFormDialog(context, item),
                      ),

                      // Delete button
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            size: 18, color: colorScheme.error),
                        tooltip: 'Delete product',
                        onPressed: () => _confirmDelete(context, item),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductEntity item) {
    final colorScheme = context.colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Medication?'),
        content: Text(
            'Are you sure you want to delete "${item.name}" from Supabase (${ApiConstants.productsTable})? This action will remove it from the catalog.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProductsBloc>().add(DeleteProductEvent(item.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted "${item.name}" from catalog')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openProductFormDialog(BuildContext context, [ProductEntity? existing]) {
    final colorScheme = context.colorScheme;
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final brandCtrl = TextEditingController(text: existing?.brand ?? '');
    final genericCtrl = TextEditingController(text: existing?.genericName ?? '');
    final packCtrl = TextEditingController(text: existing?.packSize ?? 'Retail Pack');
    final priceCtrl =
        TextEditingController(text: existing != null ? '${existing.price.toInt()}' : '2500');
    final wholesaleCtrl = TextEditingController(
        text: existing != null ? '${existing.wholesalePrice.toInt()}' : '2000');
    final stockCtrl =
        TextEditingController(text: existing != null ? '${existing.stock}' : '50');
    final nafdacCtrl = TextEditingController(
        text: existing?.nafdacNumber ?? 'NAFDAC Reg. 04-2026');
    final descCtrl = TextEditingController(
        text: existing?.description ?? 'Verified clinical medication.');
    final dosageCtrl = TextEditingController(
        text: existing?.dosageInstructions ?? 'Take according to physician prescription.');
    final ingredientsCtrl =
        TextEditingController(text: existing?.activeIngredients ?? 'Active Pharmaceutical Ingredient');
    final imageCtrl = TextEditingController(text: existing?.imageUrl ?? '');

    String category = existing?.category ?? 'Antimalarials';
    bool requiresRx = existing?.requiresPrescription ?? false;
    bool isColdChain = existing?.isColdChain ?? false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 580,
              height: 620,
              padding: const EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Edit Medication' : 'Add New Medication',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: nameCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Product Name *',
                                      hintText: 'e.g. Lonart Forte Tablets',
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: brandCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Brand / Manufacturer *',
                                      hintText: 'e.g. Bliss GVS',
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: genericCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Generic Name / Strength',
                                      hintText: 'e.g. Artemether 80mg + Lumefantrine 480mg',
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: category,
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                      isDense: true,
                                    ),
                                    items: _categories
                                        .where((c) => c != 'All')
                                        .map((c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(
                                                c,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setDialogState(() => category = val);
                                      }
                                    },
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: priceCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Retail Price (₦) *',
                                    prefixText: '₦ ',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: wholesaleCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Wholesale Price (₦) *',
                                    prefixText: '₦ ',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: stockCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Initial Stock *',
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: packCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Pack Size',
                                    hintText: 'e.g. 6 Film-Coated Tablets',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: nafdacCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'NAFDAC Number',
                                    hintText: 'e.g. NAFDAC Reg. 04-2026',
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: imageCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Image URL (Direct HTTPS)',
                              hintText: 'https://...',
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: descCtrl,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Clinical Description',
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: dosageCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Dosage & Administration Instructions',
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => setDialogState(() => requiresRx = !requiresRx),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: requiresRx,
                                          onChanged: (val) {
                                            setDialogState(() => requiresRx = val ?? false);
                                          },
                                        ),
                                        const Expanded(
                                          child: Text('Requires Rx',
                                              style: TextStyle(fontSize: 13)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => setDialogState(() => isColdChain = !isColdChain),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isColdChain,
                                          onChanged: (val) {
                                            setDialogState(() => isColdChain = val ?? false);
                                          },
                                        ),
                                        const Expanded(
                                          child: Text('Cold-Chain (2°-8°C)',
                                              style: TextStyle(fontSize: 13)),
                                        ),
                                      ],
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty) return;
                          final price = double.tryParse(priceCtrl.text) ?? 0.0;
                          final wholesale = double.tryParse(wholesaleCtrl.text) ?? (price * 0.85);
                          final stock = int.tryParse(stockCtrl.text) ?? 50;

                          final id = existing?.id ??
                              'prod-${DateTime.now().millisecondsSinceEpoch}';

                          final newProduct = ProductEntity(
                            id: id,
                            name: nameCtrl.text.trim(),
                            brand: brandCtrl.text.trim(),
                            genericName: genericCtrl.text.trim(),
                            packSize: packCtrl.text.trim(),
                            price: price,
                            wholesalePrice: wholesale,
                            category: category,
                            description: descCtrl.text.trim(),
                            dosageInstructions: dosageCtrl.text.trim(),
                            activeIngredients: ingredientsCtrl.text.trim(),
                            nafdacNumber: nafdacCtrl.text.trim(),
                            requiresPrescription: requiresRx,
                            isColdChain: isColdChain,
                            storageTemp: isColdChain
                                ? 'Strict Cold-Chain 2°C to 8°C'
                                : 'Store below 30°C',
                            stock: stock,
                            imageUrl: imageCtrl.text.trim().isNotEmpty
                                ? imageCtrl.text.trim()
                                : 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
                            badge1: requiresRx ? 'Rx Required' : 'In Stock',
                            badge1Icon: requiresRx ? 'prescriptions' : 'verified',
                            badge2: isColdChain ? 'Cold-Chain' : 'ComfortCare Certified',
                            badge2Icon: isColdChain ? 'ac_unit' : 'done_all',
                            packLabel: packCtrl.text.trim(),
                            cartonText: 'Wholesale carton available',
                            isCartonHighlight: true,
                          );

                          if (isEditing) {
                            context
                                .read<ProductsBloc>()
                                .add(UpdateProductEvent(newProduct));
                          } else {
                            context
                                .read<ProductsBloc>()
                                .add(CreateProductEvent(newProduct));
                          }

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Updated "${newProduct.name}" in Supabase'
                                    : 'Added "${newProduct.name}" to Supabase (${ApiConstants.productsTable})',
                              ),
                              backgroundColor: colorScheme.primary,
                            ),
                          );
                        },
                        child: Text(isEditing ? 'Save Changes' : 'Create Product'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
