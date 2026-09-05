import 'dart:async';
import '../entities/cart_item.dart';
import '../../../products/domain/entities/product.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCartItems();
  Future<void> addToCart(ProductEntity product, int quantity);
  Future<void> updateQuantity(String productId, int quantity);
  Future<void> removeFromCart(String productId);
  Future<void> attachPrescription(String productId);
  Future<void> clearCart();
}
