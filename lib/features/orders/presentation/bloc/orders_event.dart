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
  final String? contactWhatsapp;
  final double? latitude;
  final double? longitude;
  final List<CartItemEntity>? cartItems;

  const SelectDestinationAddressEvent({
    required this.address,
    required this.contactName,
    required this.contactPhone,
    this.contactWhatsapp,
    this.latitude,
    this.longitude,
    this.cartItems,
  });

  @override
  List<Object?> get props => [
        address,
        contactName,
        contactPhone,
        contactWhatsapp,
        latitude,
        longitude,
        cartItems,
      ];
}

class UpdateRecipientContactEvent extends OrdersEvent {
  final String? contactName;
  final String? contactPhone;
  final String? contactWhatsapp;

  const UpdateRecipientContactEvent({
    this.contactName,
    this.contactPhone,
    this.contactWhatsapp,
  });

  @override
  List<Object?> get props => [contactName, contactPhone, contactWhatsapp];
}

class OptimizePharmacySourcingEvent extends OrdersEvent {
  final List<CartItemEntity> items;
  final double? customerLat;
  final double? customerLng;

  const OptimizePharmacySourcingEvent({
    required this.items,
    this.customerLat,
    this.customerLng,
  });

  @override
  List<Object?> get props => [items, customerLat, customerLng];
}

class PlaceOrderEvent extends OrdersEvent {
  final List<CartItemEntity> items;
  final double totalAmount;
  final String? paymentReceipt;

  const PlaceOrderEvent({
    required this.items,
    required this.totalAmount,
    this.paymentReceipt,
  });

  @override
  List<Object?> get props => [items, totalAmount, paymentReceipt];
}

class TrackOrderEvent extends OrdersEvent {
  final String orderId;

  const TrackOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
