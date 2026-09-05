import '../entities/order.dart';

abstract class OrdersRepository {
  Future<OrderEntity> createOrder(OrderEntity order);
  Future<List<OrderEntity>> getOrders();
  Future<OrderEntity?> getOrderById(String orderId);
}
