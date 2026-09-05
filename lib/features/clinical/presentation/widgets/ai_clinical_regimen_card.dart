import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/pages/product_details_page.dart';

class RegimenItemData {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final bool isCheckedByDefault;
  final String? imageUrl;
  final IconData? icon;
  final String? badgeText;
  final List<RegimenTagData> tags;

  const RegimenItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    this.isCheckedByDefault = true,
    this.imageUrl,
    this.icon,
    this.badgeText,
    required this.tags,
  });
}

class RegimenTagData {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final bool isBold;

  const RegimenTagData({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.isBold = false,
  });
}

class AiClinicalRegimenCard extends StatefulWidget {
  final List<ProductEntity>? products;
  final void Function(int count, double total, double original, double savings, List<String> selectedIds)? onTotalsChanged;

  const AiClinicalRegimenCard({
    super.key,
    this.products,
    this.onTotalsChanged,
  });

  @override
  State<AiClinicalRegimenCard> createState() => _AiClinicalRegimenCardState();
}

class _AiClinicalRegimenCardState extends State<AiClinicalRegimenCard> {
  late final List<RegimenItemData> _items;
  final Set<String> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    _initItems();
    // Default checked: first 3 items (Coartem, Paracetamol, CareStart)
    for (final item in _items) {
      if (item.isCheckedByDefault) {
        _selectedItemIds.add(item.id);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyTotals());
  }

  void _initItems() {
    _items = [
      // Item 1: Coartem
      const RegimenItemData(
        id: 'prod-coartem-80-480',
        title: 'Coartem 80/480mg',
        subtitle: 'Novartis • 6 Film-Coated...',
        price: 4200.0,
        isCheckedByDefault: true,
        badgeText: 'ACT',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCYoLw9r-RmsXTnOXgJM3rXNLOWTp4aNanpbJT4yg1dHRH5bh8wBJw_eZkLeWPOHuZZ_kVoP-UXzPUtD-sfGLck1C3w9gjm4SZ56JuI0g4F_HK7Ob0BQbZ3Bi0BW4x66DmgyxUZGJx_OLz-TnFNPyQg49zsaiNsncvjT35QqHDYEHcDPjQ54vxtV0J_wBbh5rV6n2cXy_EKqVhLe6jV77o16zZPiZGVmHho2akb6gLVW1oRjZXo8o5CaNgYsVNmVvK3mQ',
        tags: [
          RegimenTagData(
            text: '1st Line Malaria Therapy',
            backgroundColor: Color(0xFFA3F69C),
            textColor: Color(0xFF002204),
            isBold: true,
          ),
          RegimenTagData(
            text: 'Take with meals',
            backgroundColor: Color(0xFFDAE2FD),
            textColor: Color(0xFF3F4850),
          ),
        ],
      ),
      // Item 2: Emzor Paracetamol
      const RegimenItemData(
        id: 'prod-emzor-paracetamol',
        title: 'Emzor Paraceta...',
        subtitle: '20 Caplets • Fever & Chills...',
        price: 1200.0,
        isCheckedByDefault: true,
        icon: Icons.vaccines,
        tags: [
          RegimenTagData(
            text: '2 tabs every 8 hrs',
            backgroundColor: Color(0xFFDAE2FD),
            textColor: Color(0xFF3F4850),
          ),
          RegimenTagData(
            text: 'Fast Dissolve',
            backgroundColor: Color(0xFFCCE5FF),
            textColor: Color(0xFF001D31),
          ),
        ],
      ),
      // Item 3: CareStart Malaria RDT
      const RegimenItemData(
        id: 'prod-carestart-rdt',
        title: 'CareStart Mala...',
        subtitle: 'Single Antigen Cassette Test',
        price: 1800.0,
        isCheckedByDefault: true,
        icon: Icons.biotech,
        tags: [
          RegimenTagData(
            text: '15-Min Results',
            backgroundColor: Color(0xFFDAE2FD),
            textColor: Color(0xFF3F4850),
          ),
          RegimenTagData(
            text: 'Recommended',
            backgroundColor: Color(0xFFA3F69C),
            textColor: Color(0xFF002204),
            isBold: true,
          ),
        ],
      ),
      // Item 4: ORS Hydration + Zinc (Unchecked by default)
      const RegimenItemData(
        id: 'prod-ors-zinc',
        title: 'ORS Hydration ...',
        subtitle: '5 Sachets • Electrolyte...',
        price: 1400.0,
        isCheckedByDefault: false,
        icon: Icons.local_drink_outlined,
        tags: [
          RegimenTagData(
            text: 'Optional Add-on',
            backgroundColor: Color(0xFFEAEDFF),
            textColor: Color(0xFF3F4850),
          ),
          RegimenTagData(
            text: 'Anti-Fatigue',
            backgroundColor: Color(0xFFDAE2FD),
            textColor: Color(0xFF3F4850),
          ),
        ],
      ),
    ];
  }

  void _toggleItem(String id) {
    setState(() {
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
      } else {
        _selectedItemIds.add(id);
      }
    });
    _notifyTotals();
  }

  void _showDrugDetailsModal(BuildContext context, String productId) {
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

  void _notifyTotals() {
    final count = _selectedItemIds.length;
    double currentTotal = 0;
    for (final item in _items) {
      if (_selectedItemIds.contains(item.id)) {
        currentTotal += item.price;
      }
    }

    final double originalTotal;
    final double savings;
    if (count >= 2) {
      originalTotal = (currentTotal / 0.9).roundToDouble();
      savings = originalTotal - currentTotal;
    } else {
      originalTotal = currentTotal;
      savings = 0;
    }

    widget.onTotalsChanged?.call(
      count,
      currentTotal,
      originalTotal,
      savings,
      _selectedItemIds.toList(),
    );
  }

  ProductEntity _createProductEntity(RegimenItemData item) {
    switch (item.id) {
      case 'prod-coartem-80-480':
        return const ProductModel(
          id: 'prod-coartem-80-480',
          name: 'Coartem 80/480mg',
          brand: 'Novartis',
          genericName: 'Artemether 80mg + Lumefantrine 480mg',
          packSize: '6 Film-Coated Tablets',
          price: 4200.0,
          wholesalePrice: 3500.0,
          category: 'Malaria Meds',
          description: 'Primary ACT anti-malarial treatment.',
          dosageInstructions: 'Take 1 tablet twice daily with meals for 3 days.',
          activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
          nafdacNumber: 'NAFDAC Reg. A4-0245',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCYoLw9r-RmsXTnOXgJM3rXNLOWTp4aNanpbJT4yg1dHRH5bh8wBJw_eZkLeWPOHuZZ_kVoP-UXzPUtD-sfGLck1C3w9gjm4SZ56JuI0g4F_HK7Ob0BQbZ3Bi0BW4x66DmgyxUZGJx_OLz-TnFNPyQg49zsaiNsncvjT35QqHDYEHcDPjQ54vxtV0J_wBbh5rV6n2cXy_EKqVhLe6jV77o16zZPiZGVmHho2akb6gLVW1oRjZXo8o5CaNgYsVNmVvK3mQ',
        );
      case 'prod-emzor-paracetamol':
        return const ProductModel(
          id: 'prod-emzor-paracetamol',
          name: 'Emzor Paracetamol 500mg',
          brand: 'Emzor Pharmaceuticals',
          genericName: 'Paracetamol BP 500mg',
          packSize: '20 Caplets',
          price: 1200.0,
          wholesalePrice: 950.0,
          category: 'Vitamins & Zinc',
          description: 'Antipyretic and analgesic for fever and chills relief.',
          dosageInstructions: '2 tabs every 8 hrs. Fast Dissolve.',
          activeIngredients: 'Paracetamol 500mg',
          nafdacNumber: 'NAFDAC Reg. 04-0312',
          imageUrl:
              'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
        );
      case 'prod-carestart-rdt':
        return const ProductModel(
          id: 'prod-carestart-rdt',
          name: 'CareStart Malaria RDT Kit',
          brand: 'Access Bio',
          genericName: 'Single Antigen Cassette Test',
          packSize: '1 Test Cassette + Lancet',
          price: 1800.0,
          wholesalePrice: 1400.0,
          category: 'Medical Devices',
          description: '15-Min rapid diagnostic test for Malaria antigen.',
          dosageInstructions: 'Single use diagnostic test.',
          activeIngredients: 'HRP2 Antigen Strip',
          nafdacNumber: 'NAFDAC Reg. 03-8821',
          imageUrl:
              'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=500&auto=format&fit=crop&q=60',
        );
      case 'prod-ors-zinc':
      default:
        return const ProductModel(
          id: 'prod-ors-zinc',
          name: 'ORS Hydration + Zinc',
          brand: 'Chi Pharmaceuticals',
          genericName: 'Oral Rehydration Salts with Zinc Sulfate',
          packSize: '5 Sachets',
          price: 1400.0,
          wholesalePrice: 1100.0,
          category: 'Vitamins & Zinc',
          description: 'Electrolyte restoration and anti-fatigue hydration therapy.',
          dosageInstructions: 'Dissolve 1 sachet in 1 liter of drinking water.',
          activeIngredients: 'Oral Rehydration Salts, Zinc Sulfate',
          nafdacNumber: 'NAFDAC Reg. 04-5512',
          imageUrl:
              'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=500&auto=format&fit=crop&q=60',
        );
    }
  }

  void _addSelectedToCart(BuildContext context) {
    final selectedItems = _items.where((i) => _selectedItemIds.contains(i.id)).toList();
    if (selectedItems.isEmpty) {
      context.showSnackBar('Please select at least one drug to add.', isError: true);
      return;
    }

    for (final item in selectedItems) {
      final product = _createProductEntity(item);
      context.read<CartBloc>().add(AddToCart(product: product));
    }

    context.showSnackBar(
      'Added ${selectedItems.length} medication${selectedItems.length == 1 ? '' : 's'} to cart!',
      isSuccess: true,
    );
  }

  void _addAllRecommendedToCart(BuildContext context) {
    for (final item in _items) {
      final product = _createProductEntity(item);
      context.read<CartBloc>().add(AddToCart(product: product));
    }

    setState(() {
      for (final item in _items) {
        _selectedItemIds.add(item.id);
      }
    });
    _notifyTotals();

    context.showSnackBar(
      'Added all 4 recommended medications to cart!',
      isSuccess: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedItemIds.length;
    double currentTotal = 0;
    for (final item in _items) {
      if (_selectedItemIds.contains(item.id)) {
        currentTotal += item.price;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE2E7FF),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF006194).withValues(alpha: 0.08),
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: "Recommended Drugs"
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Recommended Drugs',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF131B2E),
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Tap any medication to view full clinical details',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF3F4850),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA0F399),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.medication,
                          size: 13,
                          color: Color(0xFF217128),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Rx Ready',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF217128),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 4 Regimen Drug Items (tapping pops up details, checkbox toggles selection)
              ..._items.map((item) => _buildRegimenItem(item)),

              const SizedBox(height: 14),

              // Action Buttons at the Tail End of the Card to add to cart
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006194),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: const Color(0xFF006194).withValues(alpha: 0.3),
                        minimumSize: const Size(0, 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      ),
                      onPressed: () => _addSelectedToCart(context),
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: Text(
                        selectedCount > 0
                            ? 'Add Selected ($selectedCount) • ${currentTotal.toNaira()}'
                            : 'Add to Cart',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF006194),
                      side: const BorderSide(color: Color(0xFF006194), width: 1.2),
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                    onPressed: () => _addAllRecommendedToCart(context),
                    icon: const Icon(Icons.checklist, size: 18),
                    label: const Text(
                      'Add All',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegimenItem(RegimenItemData item) {
    final isChecked = _selectedItemIds.contains(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: const Color(0xFFF2F3FF),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          // Tapping item pops up the product details screen!
          onTap: () => _showDrugDetailsModal(context, item.id),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: isChecked ? 1.0 : 0.85,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox Visual - tapping toggles selection
                  GestureDetector(
                    onTap: () => _toggleItem(item.id),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, right: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isChecked
                              ? const Color(0xFF006194)
                              : const Color(0xFFDAE2FD),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isChecked
                                ? const Color(0xFF006194)
                                : const Color(0xFFBFC7D2),
                            width: 1.2,
                          ),
                          boxShadow: isChecked
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF006194).withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: isChecked
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Image Thumbnail or Icon Container (w-14 h-16 / 54x62)
                  _buildThumbnail(item),

                  const SizedBox(width: 10),

                  // Details Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Price Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isChecked
                                      ? const Color(0xFF131B2E)
                                      : const Color(0xFF3F4850),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.price.toNaira(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF006194),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),

                        // Subtitle & "Tap for details" hint
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.subtitle,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF3F4850),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: Color(0xFF006194),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Tags
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: item.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: tag.backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag.text,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: tag.isBold
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: tag.textColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(RegimenItemData item) {
    const double width = 54;
    const double height = 62;

    if (item.imageUrl != null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              item.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFDAE2FD),
                  child: const Icon(
                    Icons.medical_services,
                    color: Color(0xFF006194),
                    size: 24,
                  ),
                );
              },
            ),
            if (item.badgeText != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: const Color(0xFF006194).withValues(alpha: 0.9),
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: Text(
                    item.badgeText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFDAE2FD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          item.icon ?? Icons.medication,
          color: const Color(0xFF006194),
          size: 26,
        ),
      ),
    );
  }
}
