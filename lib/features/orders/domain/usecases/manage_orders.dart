import '../entities/order.dart';
import '../repositories/orders_repository.dart';

class ManageOrdersUseCase {
  final OrdersRepository _repository;

  ManageOrdersUseCase(this._repository);

  Future<OrderEntity> create(OrderEntity order) => _repository.createOrder(order);

  Future<List<OrderEntity>> getAll() => _repository.getOrders();

  Future<OrderEntity?> getById(String id) => _repository.getOrderById(id);
}
