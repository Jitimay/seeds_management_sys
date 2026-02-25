import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_api_service.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderApiService apiService;

  OrderRepositoryImpl(this.apiService);

  @override
  Future<List<Order>> getOrders() async {
    final ordersData = await apiService.getOrders();
    return ordersData.map((data) => Order.fromJson(data)).toList();
  }

  @override
  Future<Order> createOrder(Map<String, dynamic> orderData) async {
    final data = await apiService.createOrder(orderData);
    return Order.fromJson(data);
  }

  @override
  Future<Order> updateOrder(int id, Map<String, dynamic> orderData) async {
    final data = await apiService.updateOrder(id, orderData);
    return Order.fromJson(data);
  }

  @override
  Future<void> deleteOrder(int id) async {
    await apiService.deleteOrder(id);
  }
}
