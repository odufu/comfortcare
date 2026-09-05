import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/product.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final ProductEntity product;
  final int quantity;

  const AddToCart({required this.product, this.quantity = 1});

  @override
  List<Object?> get props => [product, quantity];
}

class UpdateCartItemQuantity extends CartEvent {
  final String productId;
  final int quantity;

  const UpdateCartItemQuantity({required this.productId, required this.quantity});

  @override
  List<Object?> get props => [productId, quantity];
}

class RemoveCartItem extends CartEvent {
  final String productId;

  const RemoveCartItem(this.productId);

  @override
  List<Object?> get props => [productId];
}

class AttachPrescriptionEvent extends CartEvent {
  final String productId;

  const AttachPrescriptionEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearCartEvent extends CartEvent {}
