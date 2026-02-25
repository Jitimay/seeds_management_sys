import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class OrderApiService {
  final ApiClient _apiClient;

  OrderApiService(this._apiClient);

  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await _apiClient.dio.get('commande/');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    print('API: Creating order with data: $orderData');
    try {
      final response = await _apiClient.dio.post('commande/', data: orderData);
      print('API: Order creation response: ${response.data}');
      return response.data;
    } catch (e) {
      print('API: Order creation error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateOrder(int id, Map<String, dynamic> orderData) async {
    final response = await _apiClient.dio.put('commande/$id/', data: orderData);
    return response.data;
  }

  Future<void> deleteOrder(int id) async {
    await _apiClient.dio.delete('commande/$id/');
  }
}
