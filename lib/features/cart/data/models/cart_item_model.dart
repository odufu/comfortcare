import '../../domain/entities/cart_item.dart';
import '../../../products/data/models/product_model.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.product,
    super.quantity = 1,
    super.isPrescriptionAttached = false,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      isPrescriptionAttached: json['is_prescription_attached'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': (product as ProductModel).toJson(),
      'quantity': quantity,
      'is_prescription_attached': isPrescriptionAttached,
    };
  }

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      product: entity.product is ProductModel
          ? entity.product
          : ProductModel(
              id: entity.product.id,
              name: entity.product.name,
              brand: entity.product.brand,
              genericName: entity.product.genericName,
              packSize: entity.product.packSize,
              price: entity.product.price,
              wholesalePrice: entity.product.wholesalePrice,
              category: entity.product.category,
              description: entity.product.description,
              dosageInstructions: entity.product.dosageInstructions,
              activeIngredients: entity.product.activeIngredients,
              nafdacNumber: entity.product.nafdacNumber,
              requiresPrescription: entity.product.requiresPrescription,
              isColdChain: entity.product.isColdChain,
              storageTemp: entity.product.storageTemp,
              stock: entity.product.stock,
              imageUrl: entity.product.imageUrl,
            ),
      quantity: entity.quantity,
      isPrescriptionAttached: entity.isPrescriptionAttached,
    );
  }
}
