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
  final String? badge1;
  final String? badge1Icon;
  final String? badge2;
  final String? badge2Icon;
  final String? packLabel;
  final String? cartonText;
  final bool isCartonHighlight;

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
    this.badge1,
    this.badge1Icon,
    this.badge2,
    this.badge2Icon,
    this.packLabel,
    this.cartonText,
    this.isCartonHighlight = false,
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
        badge1,
        badge1Icon,
        badge2,
        badge2Icon,
        packLabel,
        cartonText,
        isCartonHighlight,
      ];
}
