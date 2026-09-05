import 'package:equatable/equatable.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductsEvent {
  final String? category;
  final String? query;
  final bool isWholesale;

  const LoadProducts({this.category, this.query, this.isWholesale = false});

  @override
  List<Object?> get props => [category, query, isWholesale];
}

class SearchProducts extends ProductsEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectCategoryFilter extends ProductsEvent {
  final String category;

  const SelectCategoryFilter(this.category);

  @override
  List<Object?> get props => [category];
}

class LoadProductDetails extends ProductsEvent {
  final String productId;

  const LoadProductDetails(this.productId);

  @override
  List<Object?> get props => [productId];
}
