import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String itemCount;
  final String iconName;

  const CategoryEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.itemCount,
    required this.iconName,
  });

  @override
  List<Object?> get props => [id, title, subtitle, itemCount, iconName];
}
