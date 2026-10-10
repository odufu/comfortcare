import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_datasource.dart';
import '../models/product_model.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource _remoteDataSource;

  // In-memory catalog cache with 5-minute TTL
  static const Duration _cacheTtl = Duration(minutes: 5);
  DateTime? _lastCacheTime;
  List<ProductEntity>? _cachedAllProducts;
  final Map<String, List<ProductEntity>> _queryCache = {};
  final Map<String, ProductEntity> _productByIdCache = {};

  ProductsRepositoryImpl(this._remoteDataSource);

  bool get _isCacheValid {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheTtl;
  }

  void _invalidateCache() {
    _cachedAllProducts = null;
    _queryCache.clear();
    _productByIdCache.clear();
    _lastCacheTime = null;
  }

  @override
  Future<List<ProductEntity>> getProducts({
    String? category,
    String? query,
    bool isWholesale = false,
  }) async {
    final cacheKey = '${category ?? "All"}_${query ?? ""}_$isWholesale';

    // 1. Check Query Cache
    if (_isCacheValid && _queryCache.containsKey(cacheKey)) {
      return List<ProductEntity>.from(_queryCache[cacheKey]!);
    }

    // 2. If entire catalog is cached, evaluate query/category against cache in-memory for 0ms response
    final isDefaultSearch = (query == null || query.trim().isEmpty);
    final isAllCategory = (category == null || category == 'All');

    if (_isCacheValid && _cachedAllProducts != null) {
      var results = List<ProductEntity>.from(_cachedAllProducts!);

      if (!isAllCategory) {
        results = results
            .where((p) => p.category.toLowerCase().contains(category.toLowerCase()))
            .toList();
      }

      if (!isDefaultSearch) {
        final q = query.trim().toLowerCase();
        results = results
            .where((p) =>
                p.name.toLowerCase().contains(q) ||
                p.genericName.toLowerCase().contains(q) ||
                p.brand.toLowerCase().contains(q) ||
                p.description.toLowerCase().contains(q))
            .toList();
      }

      _queryCache[cacheKey] = results;
      return results;
    }

    // 3. Fetch from Remote Data Source
    final list = await _remoteDataSource.getProducts(
      category: category,
      query: query,
      isWholesale: isWholesale,
    );

    final entities = List<ProductEntity>.from(list);

    // Cache products
    _queryCache[cacheKey] = entities;
    for (final p in entities) {
      _productByIdCache[p.id] = p;
    }

    // If fetched without specific query, cache as base catalog
    if (isDefaultSearch && isAllCategory) {
      _cachedAllProducts = entities;
      _lastCacheTime = DateTime.now();
    }

    return entities;
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    if (_productByIdCache.containsKey(id) && _isCacheValid) {
      return _productByIdCache[id];
    }

    final product = await _remoteDataSource.getProductById(id);
    if (product != null) {
      _productByIdCache[id] = product;
    }
    return product;
  }

  @override
  Future<ProductEntity> createProduct(ProductEntity product) async {
    final model = product is ProductModel
        ? product
        : ProductModel.fromEntity(product);
    final created = await _remoteDataSource.createProduct(model);
    _invalidateCache();
    return created;
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    final model = product is ProductModel
        ? product
        : ProductModel.fromEntity(product);
    final updated = await _remoteDataSource.updateProduct(model);
    _invalidateCache();
    return updated;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _remoteDataSource.deleteProduct(id);
    _invalidateCache();
  }

  @override
  Future<void> updateStock(String id, int stock) async {
    await _remoteDataSource.updateStock(id, stock);
    _invalidateCache();
  }
}
