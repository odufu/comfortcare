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
}
