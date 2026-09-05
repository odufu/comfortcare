import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/product.dart';

class CartItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;
  final bool isPrescriptionAttached;

  const CartItemEntity({
    required this.product,
    this.quantity = 1,
    this.isPrescriptionAttached = false,
  });

  double get totalPrice => product.price * quantity;
  double get totalWholesalePrice => product.wholesalePrice * quantity;

  CartItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
    bool? isPrescriptionAttached,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isPrescriptionAttached: isPrescriptionAttached ?? this.isPrescriptionAttached,
    );
  }

  @override
  List<Object?> get props => [product, quantity, isPrescriptionAttached];
}
