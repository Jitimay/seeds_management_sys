import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class StockApiService {
  final ApiClient _apiClient;

  StockApiService(this._apiClient);

  Future<List<Map<String, dynamic>>> getStocks() async {
    try {
      final response = await _apiClient.dio.get('stock/');
      return _parseResults(response.data);
    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final errorData = e.response?.data;

        if (statusCode == 403) {
          final message = errorData is Map && errorData.containsKey('status')
              ? errorData['status']
              : 'Accès refusé. Votre compte multiplicateur doit peut-être être validé par un administrateur.';
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
      throw Exception('Unexpected data format from API');
    }
    return List<Map<String, dynamic>>.from(results);
  }

  Future<List<Map<String, dynamic>>> getVarieties() async {
    try {
      final response = await _apiClient.dio.get('variete/');
      return _parseResults(response.data);
    } catch (e) {
      print('Varieties API error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createStock(
      Map<String, dynamic> stockData) async {
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

  Future<Map<String, dynamic>> updateStock(
      int id, Map<String, dynamic> stockData) async {
    final response = await _apiClient.dio.patch('stock/$id/', data: stockData);
    return response.data;
  }

  Future<List<Map<String, dynamic>>> getStocksPublic() async {
    try {
      final response = await _apiClient.dio.get('stock/');
      // On the backend, maybe there is a 'public' or similar endpoint,
      // but for now we list all stocks and the user can pick from them.
      return _parseResults(response.data);
    } catch (e) {
      print('Public Stocks API error: $e');
      return [];
    }
  }

  Future<void> deleteStock(int id) async {
    await _apiClient.dio.delete('stock/$id/');
  }
}
