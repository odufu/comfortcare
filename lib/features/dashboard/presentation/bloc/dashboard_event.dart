import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {}

class ToggleRetailWholesaleMode extends DashboardEvent {
  final bool isWholesale;

  const ToggleRetailWholesaleMode(this.isWholesale);

  @override
  List<Object?> get props => [isWholesale];
}

class ChangeDeliveryLocation extends DashboardEvent {
  final String location;

  const ChangeDeliveryLocation(this.location);

  @override
  List<Object?> get props => [location];
}
