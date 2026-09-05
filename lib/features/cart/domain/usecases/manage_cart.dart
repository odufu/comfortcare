import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';
import '../../../products/domain/entities/product.dart';

class ManageCartUseCase {
  final CartRepository _repository;

  ManageCartUseCase(this._repository);

  Future<List<CartItemEntity>> getItems() => _repository.getCartItems();

  Future<void> addItem(ProductEntity product, int quantity) =>
      _repository.addToCart(product, quantity);

  Future<void> updateQuantity(String productId, int quantity) =>
      _repository.updateQuantity(productId, quantity);

  Future<void> removeItem(String productId) => _repository.removeFromCart(productId);

  Future<void> attachPrescription(String productId) =>
      _repository.attachPrescription(productId);

  Future<void> clear() => _repository.clearCart();
}
