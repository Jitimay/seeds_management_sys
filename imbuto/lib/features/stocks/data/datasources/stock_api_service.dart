import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class StockApiService {
  final ApiClient _apiClient;

  StockApiService(this._apiClient);

  Future<List<Map<String, dynamic>>> getStocks() async {
    final response = await _apiClient.dio.get('stock/');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createStock(Map<String, dynamic> stockData) async {
    print('API: Creating stock with data: $stockData');
    try {
      final response = await _apiClient.dio.post('stock/', data: stockData);
      print('API: Stock creation response: ${response.data}');
      return response.data;
    } catch (e) {
      print('API: Stock creation error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateStock(int id, Map<String, dynamic> stockData) async {
    final response = await _apiClient.dio.put('stock/$id/', data: stockData);
    return response.data;
  }

  Future<void> deleteStock(int id) async {
    await _apiClient.dio.delete('stock/$id/');
  }
}
