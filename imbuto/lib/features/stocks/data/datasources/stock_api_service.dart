import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class StockApiService {
  final ApiClient _apiClient;

  StockApiService(this._apiClient);

  Future<List<Map<String, dynamic>>> getStocks() async {
    try {
      print('🔍 Fetching stocks from API...');
      final response = await _apiClient.dio.get('stock/');
      print('✅ Stocks response received: ${response.statusCode}');
      print('📦 Stocks data type: ${response.data.runtimeType}');
      final results = _parseResults(response.data);
      print('✅ Parsed ${results.length} stocks');
      if (results.isEmpty) {
        print('⚠️ No stocks available. Make sure you have created and validated stocks.');
      }
      return results;
    } catch (e) {
      print('❌ Stocks API error: $e');
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final errorData = e.response?.data;
        print('❌ Status code: $statusCode');
        print('❌ Response data: $errorData');

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
      print('🔍 Fetching varieties from API...');
      final response = await _apiClient.dio.get('variete/');
      print('✅ Varieties response received: ${response.statusCode}');
      print('📦 Varieties data type: ${response.data.runtimeType}');
      final results = _parseResults(response.data);
      print('✅ Parsed ${results.length} varieties');
      return results;
    } catch (e) {
      print('❌ Varieties API error: $e');
      if (e is DioException) {
        print('❌ Status code: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      }
      rethrow; // Propagate error instead of returning empty list
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
      print('🔍 Fetching public stocks from API...');
      final response = await _apiClient.dio.get('stock/');
      print('✅ Public stocks response received: ${response.statusCode}');
      print('📦 Public stocks data type: ${response.data.runtimeType}');
      final results = _parseResults(response.data);
      print('✅ Parsed ${results.length} public stocks');
      if (results.isEmpty) {
        print('⚠️ No stocks available. Make sure you have validated stocks in the database.');
      }
      return results;
    } catch (e) {
      print('❌ Public Stocks API error: $e');
      if (e is DioException) {
        print('❌ Status code: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      }
      rethrow; // Propagate error instead of returning empty list
    }
  }

  Future<void> deleteStock(int id) async {
    await _apiClient.dio.delete('stock/$id/');
  }
}
