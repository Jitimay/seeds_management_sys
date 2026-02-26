import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class OrderApiService {
  final ApiClient _apiClient;

  OrderApiService(this._apiClient);

  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await _apiClient.dio.get('commande/');
      return _parseResults(response.data);
    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final errorData = e.response?.data;
        if (statusCode == 403) {
          final message = errorData is Map && errorData.containsKey('status')
              ? errorData['status']
              : 'Accès refusé : votre compte multiplicateur n\'est pas encore validé.';
          throw Exception(message);
        }
      }
      rethrow;
    }
  }

  List<Map<String, dynamic>> _parseResults(dynamic data) {
    List<dynamic> results;
    if (data is Map && data.containsKey('results')) {
      results = data['results'];
    } else if (data is List) {
      results = data;
    } else {
      print('API error: Unexpected data format: ${data.runtimeType}');
      throw Exception('Format de données inattendu de l\'API');
    }
    return List<Map<String, dynamic>>.from(results);
  }

  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    print('API: Creating order with data: $orderData');
    try {
      final response = await _apiClient.dio.post('commande/', data: orderData);
      print('API: Order creation response: ${response.data}');
      return response.data;
    } catch (e) {
      print('API: Order creation error: $e');
      if (e is DioException) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('status')) {
          throw Exception(errorData['status']);
        } else if (e.response?.statusCode == 403) {
          throw Exception(
              'Accès refusé ou conditions de commande non remplies.');
        } else if (e.response?.statusCode == 400) {
          throw Exception('Requête invalide ou stock insuffisant.');
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateOrder(
      int id, Map<String, dynamic> orderData) async {
    final response =
        await _apiClient.dio.patch('commande/$id/', data: orderData);
    return response.data;
  }

  Future<void> deleteOrder(int id) async {
    await _apiClient.dio.delete('commande/$id/');
  }
}
