import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final List<CategoryEntity> categories;
  final Map<String, dynamic> telemetry;
  final bool isWholesaleMode;
  final String deliveryLocation;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.categories = const [],
    this.telemetry = const {},
    this.isWholesaleMode = false,
    this.deliveryLocation = 'Comfort Mall, Life Camp, Abuja',
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    List<CategoryEntity>? categories,
    Map<String, dynamic>? telemetry,
    bool? isWholesaleMode,
    String? deliveryLocation,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      telemetry: telemetry ?? this.telemetry,
      isWholesaleMode: isWholesaleMode ?? this.isWholesaleMode,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        telemetry,
        isWholesaleMode,
        deliveryLocation,
        errorMessage,
      ];
}
