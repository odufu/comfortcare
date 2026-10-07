import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProductsUseCase {
  final ProductsRepository _repository;

  GetProductsUseCase(this._repository);

  Future<List<ProductEntity>> call({
    String? category,
    String? query,
    bool isWholesale = false,
  }) {
    return _repository.getProducts(
      category: category,
      query: query,
      isWholesale: isWholesale,
    );
  }

  Future<ProductEntity?> getById(String id) {
    return _repository.getProductById(id);
  }

  Future<ProductEntity> createProduct(ProductEntity product) {
    return _repository.createProduct(product);
  }

  Future<ProductEntity> updateProduct(ProductEntity product) {
    return _repository.updateProduct(product);
  }

  Future<void> deleteProduct(String id) {
    return _repository.deleteProduct(id);
  }

  Future<void> updateStock(String id, int stock) {
    return _repository.updateStock(id, stock);
  }
}
