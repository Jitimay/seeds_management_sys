import '../../../../core/network/api_client.dart';
import '../../domain/entities/order.dart';

class OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSource({required this.apiClient});

  Future<List<Order>> getOrders() async {
    final response = await apiClient.dio.get('/commande/');
    final List<dynamic> results = response.data['results'];
    return results.map((json) => Order.fromJson(json)).toList();
  }

  Future<Order> createOrder(Map<String, dynamic> orderData) async {
    final response = await apiClient.dio.post('/commande/', data: orderData);
    return Order.fromJson(response.data);
  }

  Future<Order> deliverOrder(int id) async {
    final response = await apiClient.dio.get('/commande/$id/delivered/');
    return Order.fromJson(response.data);
  }

  Future<Order> updateOrder(int id, Map<String, dynamic> data) async {
    final response = await apiClient.dio.patch('/commande/$id/', data: data);
    return Order.fromJson(response.data);
  }

  Future<void> cancelOrder(int id) async {
    await apiClient.dio.delete('/commande/$id/');
  }
}
