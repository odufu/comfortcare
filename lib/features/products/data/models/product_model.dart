import '../../domain/entities/product.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.brand,
    required super.genericName,
    required super.packSize,
    required super.price,
    required super.wholesalePrice,
    required super.category,
    required super.description,
    required super.dosageInstructions,
    required super.activeIngredients,
    required super.nafdacNumber,
    super.requiresPrescription = false,
    super.isColdChain = false,
    super.storageTemp = 'Store below 30°C',
    super.stock = 50,
    required super.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      genericName: json['generic_name'] as String? ?? json['genericName'] as String? ?? '',
      packSize: json['pack_size'] as String? ?? json['packSize'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      wholesalePrice: (json['wholesale_price'] as num? ?? json['wholesalePrice'] as num?)?.toDouble() ??
          ((json['price'] as num?)?.toDouble() ?? 0.0) * 0.82,
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      dosageInstructions: json['dosage_instructions'] as String? ?? json['dosageInstructions'] as String? ?? '',
      activeIngredients: json['active_ingredients'] as String? ?? json['activeIngredients'] as String? ?? '',
      nafdacNumber: json['nafdac_number'] as String? ?? json['nafdacNumber'] as String? ?? 'NAFDAC Reg. 04-2914',
      requiresPrescription: json['requires_prescription'] as bool? ?? json['requiresPrescription'] as bool? ?? false,
      isColdChain: json['is_cold_chain'] as bool? ?? json['isColdChain'] as bool? ?? false,
      storageTemp: json['storage_temp'] as String? ?? json['storageTemp'] as String? ?? 'Store below 30°C',
      stock: json['stock'] as int? ?? 50,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'generic_name': genericName,
      'pack_size': packSize,
      'price': price,
      'wholesale_price': wholesalePrice,
      'category': category,
      'description': description,
      'dosage_instructions': dosageInstructions,
      'active_ingredients': activeIngredients,
      'nafdac_number': nafdacNumber,
      'requires_prescription': requiresPrescription,
      'is_cold_chain': isColdChain,
      'storage_temp': storageTemp,
      'stock': stock,
      'image_url': imageUrl,
    };
  }
}
