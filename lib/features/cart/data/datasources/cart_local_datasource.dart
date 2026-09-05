import 'dart:convert';
import '../../../../core/storage/local_storage_service.dart';
import '../../../products/data/models/product_model.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> saveCartItems(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final LocalStorageService _storageService;

  CartLocalDataSourceImpl(this._storageService);

  static final List<CartItemModel> _initialSeedItems = [
    const CartItemModel(
      product: ProductModel(
        id: 'prod-coartem-80-480',
        name: 'Coartem 80/480mg',
        brand: 'Novartis',
        genericName: 'Artemether / Lumefantrine (6 Tabs)',
        packSize: '6 Tablets Pack',
        price: 3850.0,
        wholesalePrice: 3150.0,
        category: 'Malaria Meds',
        description: 'Complete ACT malaria treatment regimen.',
        dosageInstructions: '1 tablet twice daily for 3 days.',
        activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
        nafdacNumber: 'NAFDAC Reg. A4-0245',
        imageUrl:
            'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
      ),
      quantity: 1,
      isPrescriptionAttached: true,
    ),
    const CartItemModel(
      product: ProductModel(
        id: 'prod-augmentin-625',
        name: 'Augmentin 625mg',
        brand: 'GSK',
        genericName: 'Amoxicillin / Clavulanate Potassium',
        packSize: '14 Film-Coated Tablets',
        price: 7500.0,
        wholesalePrice: 6200.0,
        category: 'Antibiotics',
        description: 'Broad spectrum antibacterial therapy.',
        dosageInstructions: '1 tablet every 12 hours.',
        activeIngredients: 'Amoxicillin 500mg, Clavulanate 125mg',
        nafdacNumber: 'NAFDAC Reg. 04-2194',
        requiresPrescription: true,
        imageUrl:
            'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=500&auto=format&fit=crop&q=60',
      ),
      quantity: 1,
      isPrescriptionAttached: true,
    ),
    const CartItemModel(
      product: ProductModel(
        id: 'prod-panadol-extra',
        name: 'Panadol Extra Tablets',
        brand: 'GSK',
        genericName: 'Paracetamol 500mg + Caffeine 65mg',
        packSize: '10 Blister Packs (20 Tabs)',
        price: 1850.0,
        wholesalePrice: 1450.0,
        category: 'Vitamins & Zinc',
        description: 'Fast febrile and analgesic relief.',
        dosageInstructions: '1-2 tablets every 6 hours.',
        activeIngredients: 'Paracetamol 500mg, Caffeine 65mg',
        nafdacNumber: 'NAFDAC Reg. 04-0312',
        imageUrl:
            'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
      ),
      quantity: 1,
      isPrescriptionAttached: false,
    ),
  ];

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final jsonStr = _storageService.getCartJson();
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List;
        return list.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        return _initialSeedItems;
      }
    }
    return _initialSeedItems;
  }

  @override
  Future<void> saveCartItems(List<CartItemModel> items) async {
    final list = items.map((e) => e.toJson()).toList();
    await _storageService.saveCartJson(jsonEncode(list));
  }
}
