import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_datasource.dart';
import '../models/product_model.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource _remoteDataSource;

  ProductsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ProductEntity>> getProducts({
    String? category,
    String? query,
    bool isWholesale = false,
  }) async {
    final list = await _remoteDataSource.getProducts(
      category: category,
      query: query,
      isWholesale: isWholesale,
    );
    return List<ProductEntity>.from(list);
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    return _remoteDataSource.getProductById(id);
  }

  @override
  Future<ProductEntity> createProduct(ProductEntity product) async {
    final model = product is ProductModel
        ? product
        : ProductModel.fromEntity(product);
    return _remoteDataSource.createProduct(model);
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    final model = product is ProductModel
        ? product
        : ProductModel.fromEntity(product);
    return _remoteDataSource.updateProduct(model);
  }

  @override
  Future<void> deleteProduct(String id) async {
    return _remoteDataSource.deleteProduct(id);
  }

  @override
  Future<void> updateStock(String id, int stock) async {
    return _remoteDataSource.updateStock(id, stock);
  }
}
