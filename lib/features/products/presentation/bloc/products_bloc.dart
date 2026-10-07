import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProductsUseCase _getProductsUseCase;

  ProductsBloc({
    required GetProductsUseCase getProductsUseCase,
  })  : _getProductsUseCase = getProductsUseCase,
        super(const ProductsState()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<SelectCategoryFilter>(_onSelectCategoryFilter);
    on<LoadProductDetails>(_onLoadProductDetails);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<UpdateProductStockEvent>(_onUpdateProductStock);
  }

  Future<void> _onCreateProduct(
      CreateProductEvent event, Emitter<ProductsState> emit) async {
    try {
      await _getProductsUseCase.createProduct(event.product);
      add(LoadProducts(
        category: state.selectedCategory,
        query: state.searchQuery,
        isWholesale: state.isWholesale,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: 'Failed to create product: $e',
      ));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProductEvent event, Emitter<ProductsState> emit) async {
    try {
      await _getProductsUseCase.updateProduct(event.product);
      add(LoadProducts(
        category: state.selectedCategory,
        query: state.searchQuery,
        isWholesale: state.isWholesale,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: 'Failed to update product: $e',
      ));
    }
  }

  Future<void> _onDeleteProduct(
      DeleteProductEvent event, Emitter<ProductsState> emit) async {
    try {
      await _getProductsUseCase.deleteProduct(event.productId);
      add(LoadProducts(
        category: state.selectedCategory,
        query: state.searchQuery,
        isWholesale: state.isWholesale,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: 'Failed to delete product: $e',
      ));
    }
  }

  Future<void> _onUpdateProductStock(
      UpdateProductStockEvent event, Emitter<ProductsState> emit) async {
    try {
      await _getProductsUseCase.updateStock(event.productId, event.newStock);
      add(LoadProducts(
        category: state.selectedCategory,
        query: state.searchQuery,
        isWholesale: state.isWholesale,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: 'Failed to update stock: $e',
      ));
    }
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ProductsState> emit) async {
    emit(state.copyWith(
      status: ProductsStatus.loading,
      selectedCategory: event.category ?? state.selectedCategory,
      searchQuery: event.query ?? state.searchQuery,
      isWholesale: event.isWholesale,
    ));

    try {
      final products = await _getProductsUseCase(
        category: event.category ?? state.selectedCategory,
        query: event.query ?? state.searchQuery,
        isWholesale: event.isWholesale,
      );
      emit(state.copyWith(
        status: ProductsStatus.loaded,
        products: products,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchProducts(
      SearchProducts event, Emitter<ProductsState> emit) async {
    emit(state.copyWith(searchQuery: event.query, status: ProductsStatus.loading));
    try {
      final products = await _getProductsUseCase(
        category: state.selectedCategory,
        query: event.query,
        isWholesale: state.isWholesale,
      );
      emit(state.copyWith(
        status: ProductsStatus.loaded,
        products: products,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSelectCategoryFilter(
      SelectCategoryFilter event, Emitter<ProductsState> emit) async {
    emit(state.copyWith(selectedCategory: event.category, status: ProductsStatus.loading));
    try {
      final products = await _getProductsUseCase(
        category: event.category,
        query: state.searchQuery,
        isWholesale: state.isWholesale,
      );
      emit(state.copyWith(
        status: ProductsStatus.loaded,
        products: products,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadProductDetails(
      LoadProductDetails event, Emitter<ProductsState> emit) async {
    try {
      final product = await _getProductsUseCase.getById(event.productId);
      emit(state.copyWith(selectedProduct: product));
    } catch (_) {}
  }
}
