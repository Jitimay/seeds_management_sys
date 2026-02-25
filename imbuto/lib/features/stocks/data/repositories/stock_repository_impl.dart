import '../../domain/entities/stock.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_api_service.dart';

class StockRepositoryImpl implements StockRepository {
  final StockApiService apiService;

  StockRepositoryImpl(this.apiService);

  @override
  Future<List<Stock>> getStocks() async {
    final stocksData = await apiService.getStocks();
    return stocksData.map((data) => Stock.fromJson(data)).toList();
  }

  @override
  Future<Stock> createStock(Map<String, dynamic> stockData) async {
    final data = await apiService.createStock(stockData);
    return Stock.fromJson(data);
  }

  @override
  Future<Stock> updateStock(int id, Map<String, dynamic> stockData) async {
    final data = await apiService.updateStock(id, stockData);
    return Stock.fromJson(data);
  }

  @override
  Future<void> deleteStock(int id) async {
    await apiService.deleteStock(id);
  }
}
