import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_datasource.dart';

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
}
