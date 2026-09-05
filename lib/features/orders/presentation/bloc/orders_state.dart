import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';

enum OrdersStatus { initial, loading, loaded, orderPlaced, error }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<OrderEntity> orders;
  final OrderEntity? activeOrder;
  final DispatchSpeed selectedDispatchSpeed;
  final double dispatchFee;
  final String destinationAddress;
  final String recipientName;
  final String recipientPhone;
  final String? errorMessage;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.activeOrder,
    this.selectedDispatchSpeed = DispatchSpeed.express,
    this.dispatchFee = 1200.0,
    this.destinationAddress = 'Plot 1044, Adetokunbo Ademola Crescent, Wuse 2, Abuja',
    this.recipientName = 'Dr. Farouk Al-Mansur',
    this.recipientPhone = '+234 803 265 1505',
    this.errorMessage,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderEntity>? orders,
    OrderEntity? activeOrder,
    DispatchSpeed? selectedDispatchSpeed,
    double? dispatchFee,
    String? destinationAddress,
    String? recipientName,
    String? recipientPhone,
    String? errorMessage,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      activeOrder: activeOrder ?? this.activeOrder,
      selectedDispatchSpeed: selectedDispatchSpeed ?? this.selectedDispatchSpeed,
      dispatchFee: dispatchFee ?? this.dispatchFee,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
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
        recipientName,
        recipientPhone,
        errorMessage,
      ];
}
