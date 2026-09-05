import 'package:equatable/equatable.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersEvent {}

class SelectDispatchSpeedEvent extends OrdersEvent {
  final DispatchSpeed speed;
  final double fee;

  const SelectDispatchSpeedEvent(this.speed, this.fee);

  @override
  List<Object?> get props => [speed, fee];
}

class SelectDestinationAddressEvent extends OrdersEvent {
  final String address;
  final String contactName;
  final String contactPhone;

  const SelectDestinationAddressEvent({
    required this.address,
    required this.contactName,
    required this.contactPhone,
  });

  @override
  List<Object?> get props => [address, contactName, contactPhone];
}

class PlaceOrderEvent extends OrdersEvent {
  final List<CartItemEntity> items;
  final double totalAmount;

  const PlaceOrderEvent({required this.items, required this.totalAmount});

  @override
  List<Object?> get props => [items, totalAmount];
}

class TrackOrderEvent extends OrdersEvent {
  final String orderId;

  const TrackOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
