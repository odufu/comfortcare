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
