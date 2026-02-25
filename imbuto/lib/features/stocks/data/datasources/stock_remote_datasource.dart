import '../../../../core/network/api_client.dart';
import '../../domain/entities/stock.dart';

class StockRemoteDataSource {
  final ApiClient apiClient;

  StockRemoteDataSource({required this.apiClient});

  Future<List<Stock>> getStocks() async {
    final response = await apiClient.dio.get('/stock/');
    final List<dynamic> results = response.data['results'];
    return results.map((json) => Stock.fromJson(json)).toList();
  }

  Future<Stock> createStock(Map<String, dynamic> stockData) async {
    final response = await apiClient.dio.post('/stock/', data: stockData);
    return Stock.fromJson(response.data);
  }

  Future<Stock> updateStock(int id, Map<String, dynamic> stockData) async {
    final response = await apiClient.dio.put('/stock/$id/', data: stockData);
    return Stock.fromJson(response.data);
  }

  Future<void> deleteStock(int id) async {
    await apiClient.dio.delete('/stock/$id/');
  }
}
