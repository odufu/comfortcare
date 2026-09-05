import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';

enum CartStatus { initial, loading, loaded, error }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItemEntity> items;
  final double deliveryFee;
  final double clinicalVerificationFee;
  final double discount;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.deliveryFee = 1200.0,
    this.clinicalVerificationFee = 0.0,
    this.discount = 450.0,
    this.errorMessage,
  });

  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.totalPrice);

  double get grandTotal {
    final total = subtotal + deliveryFee + clinicalVerificationFee - discount;
    return total > 0 ? total : 0;
  }

  bool get hasRxItems => items.any((i) => i.product.requiresPrescription);

  bool get allRxVerified => items
      .where((i) => i.product.requiresPrescription)
      .every((i) => i.isPrescriptionAttached);

  CartState copyWith({
    CartStatus? status,
    List<CartItemEntity>? items,
    double? deliveryFee,
    double? clinicalVerificationFee,
    double? discount,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      clinicalVerificationFee: clinicalVerificationFee ?? this.clinicalVerificationFee,
      discount: discount ?? this.discount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        deliveryFee,
        clinicalVerificationFee,
        discount,
        errorMessage,
      ];
}
