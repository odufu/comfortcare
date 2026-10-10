import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/nova_express_logistics_service.dart';
import '../../../pharmacy_portal/domain/services/pharmacy_sourcing_engine.dart';
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
    on<UpdateRecipientContactEvent>(_onUpdateRecipientContact);
    on<OptimizePharmacySourcingEvent>(_onOptimizePharmacySourcing);
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
    final lat = event.latitude ?? state.destinationLat;
    final lng = event.longitude ?? state.destinationLng;

    PharmacySourcingResult? newSourcing = state.sourcingResult;
    double newFee = state.dispatchFee;

    if (event.cartItems != null && event.cartItems!.isNotEmpty) {
      newSourcing = PharmacySourcingEngine.optimizeSourcing(
        items: event.cartItems!,
        customerLat: lat,
        customerLng: lng,
      );
      if (state.selectedDispatchSpeed != DispatchSpeed.depotPickup) {
        newFee = newSourcing.totalLogisticsFee;
      }
    }

    emit(state.copyWith(
      destinationAddress: event.address,
      destinationLat: lat,
      destinationLng: lng,
      recipientName: event.contactName,
      recipientPhone: event.contactPhone,
      recipientWhatsapp: event.contactWhatsapp ?? event.contactPhone,
      sourcingResult: newSourcing,
      dispatchFee: newFee,
    ));
  }

  void _onUpdateRecipientContact(
      UpdateRecipientContactEvent event, Emitter<OrdersState> emit) {
    emit(state.copyWith(
      recipientName: event.contactName ?? state.recipientName,
      recipientPhone: event.contactPhone ?? state.recipientPhone,
      recipientWhatsapp: event.contactWhatsapp ?? state.recipientWhatsapp,
    ));
  }

  void _onOptimizePharmacySourcing(
      OptimizePharmacySourcingEvent event, Emitter<OrdersState> emit) {
    final lat = event.customerLat ?? state.destinationLat;
    final lng = event.customerLng ?? state.destinationLng;

    final result = PharmacySourcingEngine.optimizeSourcing(
      items: event.items,
      customerLat: lat,
      customerLng: lng,
    );

    final updatedFee = state.selectedDispatchSpeed == DispatchSpeed.depotPickup
        ? 0.0
        : result.totalLogisticsFee;

    emit(state.copyWith(
      destinationLat: lat,
      destinationLng: lng,
      sourcingResult: result,
      dispatchFee: updatedFee,
    ));
  }

  Future<void> _onPlaceOrder(
      PlaceOrderEvent event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(status: OrdersStatus.loading));
    try {
      final orderId = 'CC-${_uuid.v4().substring(0, 5).toUpperCase()}';
      final receipt = event.paymentReceipt ??
          state.paymentReceipt ??
          'CC-TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      // Sourcing optimization: Maximum Priority Arrival Time & Multi-Stop Fee
      final sourcing = state.sourcingResult ??
          PharmacySourcingEngine.optimizeSourcing(
            items: event.items,
            customerLat: state.destinationLat,
            customerLng: state.destinationLng,
            orderId: orderId,
          );

      final totalLogisticsFee = state.selectedDispatchSpeed == DispatchSpeed.depotPickup
          ? 0.0
          : sourcing.totalLogisticsFee;

      final provisionalOrder = OrderEntity(
        id: orderId,
        items: event.items,
        totalAmount: event.totalAmount,
        destinationAddress: state.destinationAddress,
        recipientName: state.recipientName,
        recipientPhone: state.recipientPhone,
        recipientWhatsapp: state.recipientWhatsapp,
        paymentReceipt: receipt,
        novaExpressTrackingNumber: 'NOV-2026-${orderId.substring(3)}',
        flatRateDeliveryFee: totalLogisticsFee,
        dispatchSpeed: state.selectedDispatchSpeed,
        status: OrderStatus.inTransit,
        riderName: 'Rider Ibrahim',
        riderPhone: '+234 812 345 6789',
        eta: '${sourcing.estimatedArrivalMinutes} mins • NovaExpress Live Hub',
        coldChainTemp: 'Cold-Chain 3.8°C Normal',
        createdAt: DateTime.now(),
      );

      // Automated NovaExpress HTTP POST Inbound Transmission with optimized pickup stops
      final novaResult = await NovaExpressLogisticsService.submitOrderToNovaExpress(
        order: provisionalOrder,
        pickupStops: sourcing.pickupStops,
        paymentReceiptRef: receipt,
        paymentGateway: 'Paystack Instant Settlement',
        deliveryInstructions: 'Deliver to front desk. Clinical parcel seal. Sourcing: ${sourcing.dispatchExplanation}',
      );

      final finalOrder = OrderEntity(
        id: orderId,
        items: event.items,
        totalAmount: event.totalAmount,
        destinationAddress: state.destinationAddress,
        recipientName: state.recipientName,
        recipientPhone: state.recipientPhone,
        recipientWhatsapp: state.recipientWhatsapp,
        paymentReceipt: receipt,
        novaExpressTrackingNumber: novaResult.trackingNumber,
        flatRateDeliveryFee: novaResult.flatDeliveryFee,
        dispatchSpeed: state.selectedDispatchSpeed,
        status: OrderStatus.inTransit,
        riderName: novaResult.assignedRider,
        riderPhone: novaResult.riderPhone,
        eta: '${sourcing.estimatedArrivalMinutes} mins • ${novaResult.assignedDc}',
        coldChainTemp: 'Cold-Chain 3.8°C Normal',
        createdAt: DateTime.now(),
      );

      final created = await _manageOrdersUseCase.create(finalOrder);
      final currentList = List<OrderEntity>.from(state.orders)..insert(0, created);

      emit(state.copyWith(
        status: OrdersStatus.orderPlaced,
        activeOrder: created,
        orders: currentList,
        paymentReceipt: receipt,
        sourcingResult: sourcing,
        dispatchFee: totalLogisticsFee,
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
