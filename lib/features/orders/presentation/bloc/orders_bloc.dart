import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/manage_orders.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final ManageOrdersUseCase _manageOrdersUseCase;
  final _uuid = const Uuid();

  OrdersBloc({required ManageOrdersUseCase manageOrdersUseCase})
      : _manageOrdersUseCase = manageOrdersUseCase,
        super(const OrdersState()) {
    on<LoadOrders>(_onLoadOrders);
    on<SelectDispatchSpeedEvent>(_onSelectDispatchSpeed);
    on<SelectDestinationAddressEvent>(_onSelectDestinationAddress);
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<TrackOrderEvent>(_onTrackOrder);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(status: OrdersStatus.loading));
    try {
      final list = await _manageOrdersUseCase.getAll();
      emit(state.copyWith(
        status: OrdersStatus.loaded,
        orders: list,
        activeOrder: list.isNotEmpty ? list.first : null,
      ));
    } catch (e) {
      emit(state.copyWith(status: OrdersStatus.error, errorMessage: e.toString()));
    }
  }

  void _onSelectDispatchSpeed(
      SelectDispatchSpeedEvent event, Emitter<OrdersState> emit) {
    emit(state.copyWith(
      selectedDispatchSpeed: event.speed,
      dispatchFee: event.fee,
    ));
  }

  void _onSelectDestinationAddress(
      SelectDestinationAddressEvent event, Emitter<OrdersState> emit) {
    emit(state.copyWith(
      destinationAddress: event.address,
      recipientName: event.contactName,
      recipientPhone: event.contactPhone,
    ));
  }

  Future<void> _onPlaceOrder(
      PlaceOrderEvent event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(status: OrdersStatus.loading));
    try {
      final orderId = 'CC-${_uuid.v4().substring(0, 5).toUpperCase()}';
      final newOrder = OrderEntity(
        id: orderId,
        items: event.items,
        totalAmount: event.totalAmount,
        destinationAddress: state.destinationAddress,
        recipientName: state.recipientName,
        recipientPhone: state.recipientPhone,
        dispatchSpeed: state.selectedDispatchSpeed,
        status: OrderStatus.inTransit,
        riderName: 'Rider Ibrahim',
        riderPhone: '+234 812 345 6789',
        eta: '25 mins • Arriving soon',
        coldChainTemp: 'Cold-Chain 3.8°C Normal',
        createdAt: DateTime.now(),
      );

      final created = await _manageOrdersUseCase.create(newOrder);
      final currentList = List<OrderEntity>.from(state.orders)..insert(0, created);

      emit(state.copyWith(
        status: OrdersStatus.orderPlaced,
        activeOrder: created,
        orders: currentList,
      ));
    } catch (e) {
      emit(state.copyWith(status: OrdersStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onTrackOrder(
      TrackOrderEvent event, Emitter<OrdersState> emit) async {
    try {
      final order = await _manageOrdersUseCase.getById(event.orderId);
      if (order != null) {
        emit(state.copyWith(activeOrder: order));
      }
    } catch (_) {}
  }
}
