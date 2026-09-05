import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String brand;
  final String genericName;
  final String packSize;
  final double price;
  final double wholesalePrice;
  final String category;
  final String description;
  final String dosageInstructions;
  final String activeIngredients;
  final String nafdacNumber;
  final bool requiresPrescription;
  final bool isColdChain;
  final String storageTemp;
  final int stock;
  final String imageUrl;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.brand,
    required this.genericName,
    required this.packSize,
    required this.price,
    required this.wholesalePrice,
    required this.category,
    required this.description,
    required this.dosageInstructions,
    required this.activeIngredients,
    required this.nafdacNumber,
    this.requiresPrescription = false,
    this.isColdChain = false,
    this.storageTemp = 'Store below 30°C',
    this.stock = 50,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        brand,
        genericName,
        packSize,
        price,
        wholesalePrice,
        category,
        description,
        dosageInstructions,
        activeIngredients,
        nafdacNumber,
        requiresPrescription,
        isColdChain,
        storageTemp,
        stock,
        imageUrl,
      ];
}
