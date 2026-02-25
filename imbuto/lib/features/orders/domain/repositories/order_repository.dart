import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<Order> createOrder(Map<String, dynamic> orderData);
  Future<Order> updateOrder(int id, Map<String, dynamic> orderData);
  Future<void> deleteOrder(int id);
}
