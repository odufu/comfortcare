import 'package:equatable/equatable.dart';
import '../../../cart/domain/entities/cart_item.dart';

enum OrderStatus {
  placed,
  triageApproved,
  dispensing,
  inTransit,
  delivered,
  cancelled,
}

enum DispatchSpeed {
  express, // 25-35 mins
  scheduled, // Same day 3-4 hours
  depotPickup, // Free
}

class OrderEntity extends Equatable {
  final String id;
  final List<CartItemEntity> items;
  final double totalAmount;
  final String destinationAddress;
  final String recipientName;
  final String recipientPhone;
  final String recipientWhatsapp;
  final String? paymentReceipt;
  final String novaExpressTrackingNumber;
  final double flatRateDeliveryFee;
  final DispatchSpeed dispatchSpeed;
  final OrderStatus status;
  final String riderName;
  final String riderPhone;
  final String eta;
  final String coldChainTemp;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.destinationAddress,
    required this.recipientName,
    required this.recipientPhone,
    this.recipientWhatsapp = '+234 803 265 1505',
    this.paymentReceipt,
    this.novaExpressTrackingNumber = 'NOV-2026-8492',
    this.flatRateDeliveryFee = 3500.0,
    required this.dispatchSpeed,
    this.status = OrderStatus.placed,
    this.riderName = 'Rider Ibrahim',
    this.riderPhone = '+234 812 345 6789',
    this.eta = '18 mins • Arriving ~3:45 PM',
    this.coldChainTemp = 'Cold-Chain 3.8°C Normal',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        items,
        totalAmount,
        destinationAddress,
        recipientName,
        recipientPhone,
        recipientWhatsapp,
        paymentReceipt,
        novaExpressTrackingNumber,
        flatRateDeliveryFee,
        dispatchSpeed,
        status,
        riderName,
        riderPhone,
        eta,
        coldChainTemp,
        createdAt,
      ];
}
