import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';
import '../models/order_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource _remoteDataSource;

  OrdersRepositoryImpl(this._remoteDataSource);

  @override
  Future<OrderEntity> createOrder(OrderEntity order) async {
    final model = order is OrderModel
        ? order
        : OrderModel(
            id: order.id,
            items: order.items,
            totalAmount: order.totalAmount,
            destinationAddress: order.destinationAddress,
            recipientName: order.recipientName,
            recipientPhone: order.recipientPhone,
            dispatchSpeed: order.dispatchSpeed,
            status: order.status,
            riderName: order.riderName,
            riderPhone: order.riderPhone,
            eta: order.eta,
            coldChainTemp: order.coldChainTemp,
            createdAt: order.createdAt,
          );

    return _remoteDataSource.createOrder(model);
  }

  @override
  Future<List<OrderEntity>> getOrders() async {
    return _remoteDataSource.getOrders();
  }

  @override
  Future<OrderEntity?> getOrderById(String orderId) async {
    return _remoteDataSource.getOrderById(orderId);
  }
}
