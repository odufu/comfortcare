import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

enum ProductsStatus { initial, loading, loaded, error }

class ProductsState extends Equatable {
  final ProductsStatus status;
  final List<ProductEntity> products;
  final ProductEntity? selectedProduct;
  final String selectedCategory;
  final String searchQuery;
  final bool isWholesale;
  final String? errorMessage;

  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.selectedProduct,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.isWholesale = false,
    this.errorMessage,
  });

  ProductsState copyWith({
    ProductsStatus? status,
    List<ProductEntity>? products,
    ProductEntity? selectedProduct,
    String? selectedCategory,
    String? searchQuery,
    bool? isWholesale,
    String? errorMessage,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isWholesale: isWholesale ?? this.isWholesale,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        selectedProduct,
        selectedCategory,
        searchQuery,
        isWholesale,
        errorMessage,
      ];
}
