import '../../../cart/data/models/cart_item_model.dart';
import '../../domain/entities/order.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.items,
    required super.totalAmount,
    required super.destinationAddress,
    required super.recipientName,
    required super.recipientPhone,
    required super.dispatchSpeed,
    super.status = OrderStatus.placed,
    super.riderName = 'Rider Ibrahim',
    super.riderPhone = '+234 812 345 6789',
    super.eta = '18 mins • Arriving ~3:45 PM',
    super.coldChainTemp = 'Cold-Chain 3.8°C Normal',
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['total_amount'] as num? ?? json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      destinationAddress: json['destination_address'] as String? ?? json['destinationAddress'] as String? ?? '',
      recipientName: json['recipient_name'] as String? ?? json['recipientName'] as String? ?? '',
      recipientPhone: json['recipient_phone'] as String? ?? json['recipientPhone'] as String? ?? '',
      dispatchSpeed: _dispatchSpeedFromString(json['dispatch_speed'] as String?),
      status: _statusFromString(json['status'] as String?),
      riderName: json['rider_name'] as String? ?? 'Rider Ibrahim',
      riderPhone: json['rider_phone'] as String? ?? '+234 812 345 6789',
      eta: json['eta'] as String? ?? '18 mins',
      coldChainTemp: json['cold_chain_temp'] as String? ?? 'Cold-Chain 3.8°C Normal',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((i) => (i is CartItemModel ? i : CartItemModel.fromEntity(i)).toJson()).toList(),
      'total_amount': totalAmount,
      'destination_address': destinationAddress,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'dispatch_speed': dispatchSpeed.name,
      'status': status.name,
      'rider_name': riderName,
      'rider_phone': riderPhone,
      'eta': eta,
      'cold_chain_temp': coldChainTemp,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static DispatchSpeed _dispatchSpeedFromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'scheduled':
        return DispatchSpeed.scheduled;
      case 'depotpickup':
        return DispatchSpeed.depotPickup;
      default:
        return DispatchSpeed.express;
    }
  }

  static OrderStatus _statusFromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'triageapproved':
        return OrderStatus.triageApproved;
      case 'dispensing':
        return OrderStatus.dispensing;
      case 'intransit':
        return OrderStatus.inTransit;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.placed;
    }
  }
}
