import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  Future<List<Order>> call() async {
    return await repository.getOrders();
  }
}

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Order> call(Map<String, dynamic> orderData) async {
    return await repository.createOrder(orderData);
  }
}

class UpdateOrderUseCase {
  final OrderRepository repository;

  UpdateOrderUseCase(this.repository);

  Future<Order> call(int id, Map<String, dynamic> orderData) async {
    return await repository.updateOrder(id, orderData);
  }
}

class DeleteOrderUseCase {
  final OrderRepository repository;

  DeleteOrderUseCase(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteOrder(id);
  }
}
