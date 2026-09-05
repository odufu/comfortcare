import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../../products/domain/entities/product.dart';
import '../datasources/cart_local_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _localDataSource;

  CartRepositoryImpl(this._localDataSource);

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    return _localDataSource.getCartItems();
  }

  @override
  Future<void> addToCart(ProductEntity product, int quantity) async {
    final current = await _localDataSource.getCartItems();
    final index = current.indexWhere((i) => i.product.id == product.id);

    if (index >= 0) {
      final existing = current[index];
      current[index] = existing.copyWith(
        quantity: existing.quantity + quantity,
      ) as CartItemModel;
    } else {
      current.add(CartItemModel(
        product: product,
        quantity: quantity,
        isPrescriptionAttached: !product.requiresPrescription,
      ));
    }

    await _localDataSource.saveCartItems(current);
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    final current = await _localDataSource.getCartItems();
    if (quantity <= 0) {
      current.removeWhere((i) => i.product.id == productId);
    } else {
      final index = current.indexWhere((i) => i.product.id == productId);
      if (index >= 0) {
        current[index] = current[index].copyWith(quantity: quantity) as CartItemModel;
      }
    }
    await _localDataSource.saveCartItems(current);
  }

  @override
  Future<void> removeFromCart(String productId) async {
    final current = await _localDataSource.getCartItems();
    current.removeWhere((i) => i.product.id == productId);
    await _localDataSource.saveCartItems(current);
  }

  @override
  Future<void> attachPrescription(String productId) async {
    final current = await _localDataSource.getCartItems();
    final index = current.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      current[index] = current[index].copyWith(isPrescriptionAttached: true) as CartItemModel;
      await _localDataSource.saveCartItems(current);
    }
  }

  @override
  Future<void> clearCart() async {
    await _localDataSource.saveCartItems([]);
  }
}
