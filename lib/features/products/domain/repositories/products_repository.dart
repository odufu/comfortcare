import '../entities/product.dart';

abstract class ProductsRepository {
  Future<List<ProductEntity>> getProducts({
    String? category,
    String? query,
    bool isWholesale = false,
  });

  Future<ProductEntity?> getProductById(String id);

  Future<ProductEntity> createProduct(ProductEntity product);
  Future<ProductEntity> updateProduct(ProductEntity product);
  Future<void> deleteProduct(String id);
  Future<void> updateStock(String id, int stock);
}
