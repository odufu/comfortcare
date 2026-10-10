import 'package:equatable/equatable.dart';
import '../../../pharmacy_portal/domain/services/pharmacy_sourcing_engine.dart';
import '../../domain/entities/order.dart';

enum OrdersStatus { initial, loading, loaded, orderPlaced, error }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<OrderEntity> orders;
  final OrderEntity? activeOrder;
  final DispatchSpeed selectedDispatchSpeed;
  final double dispatchFee;
  final String destinationAddress;
  final double destinationLat;
  final double destinationLng;
  final String recipientName;
  final String recipientPhone;
  final String recipientWhatsapp;
  final PharmacySourcingResult? sourcingResult;
  final String? paymentReceipt;
  final String? errorMessage;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.activeOrder,
    this.selectedDispatchSpeed = DispatchSpeed.express,
    this.dispatchFee = 3500.0,
    this.destinationAddress = 'Plot 1044, Adetokunbo Ademola Crescent, Wuse 2, Abuja',
    this.destinationLat = 9.0765,
    this.destinationLng = 7.4720,
    this.recipientName = 'Dr. Farouk Al-Mansur',
    this.recipientPhone = '+234 803 265 1505',
    this.recipientWhatsapp = '+234 803 265 1505',
    this.sourcingResult,
    this.paymentReceipt,
    this.errorMessage,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderEntity>? orders,
    OrderEntity? activeOrder,
    DispatchSpeed? selectedDispatchSpeed,
    double? dispatchFee,
    String? destinationAddress,
    double? destinationLat,
    double? destinationLng,
    String? recipientName,
    String? recipientPhone,
    String? recipientWhatsapp,
    PharmacySourcingResult? sourcingResult,
    String? paymentReceipt,
    String? errorMessage,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      activeOrder: activeOrder ?? this.activeOrder,
      selectedDispatchSpeed: selectedDispatchSpeed ?? this.selectedDispatchSpeed,
      dispatchFee: dispatchFee ?? this.dispatchFee,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientWhatsapp: recipientWhatsapp ?? this.recipientWhatsapp,
      sourcingResult: sourcingResult ?? this.sourcingResult,
      paymentReceipt: paymentReceipt ?? this.paymentReceipt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        orders,
        activeOrder,
        selectedDispatchSpeed,
        dispatchFee,
        destinationAddress,
        destinationLat,
        destinationLng,
        recipientName,
        recipientPhone,
        recipientWhatsapp,
        sourcingResult,
        paymentReceipt,
        errorMessage,
      ];
}
