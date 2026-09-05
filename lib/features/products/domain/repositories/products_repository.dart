import '../entities/product.dart';

abstract class ProductsRepository {
  Future<List<ProductEntity>> getProducts({
    String? category,
    String? query,
    bool isWholesale = false,
  });

  Future<ProductEntity?> getProductById(String id);
}
