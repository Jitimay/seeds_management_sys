import '../entities/stock.dart';

abstract class StockRepository {
  Future<List<Stock>> getStocks();
  Future<Stock> createStock(Map<String, dynamic> stockData);
  Future<Stock> updateStock(int id, Map<String, dynamic> stockData);
  Future<void> deleteStock(int id);
}
