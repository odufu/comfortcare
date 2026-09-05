import '../../domain/entities/category.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.itemCount,
    required super.iconName,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      itemCount: json['item_count'] as String? ?? json['itemCount'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? json['iconName'] as String? ?? 'medication',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'item_count': itemCount,
      'icon_name': iconName,
    };
  }
}
