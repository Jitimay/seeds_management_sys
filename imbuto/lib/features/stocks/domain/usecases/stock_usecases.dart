import '../entities/stock.dart';
import '../repositories/stock_repository.dart';

class GetStocksUseCase {
  final StockRepository repository;

  GetStocksUseCase(this.repository);

  Future<List<Stock>> call() async {
    return await repository.getStocks();
  }
}

class CreateStockUseCase {
  final StockRepository repository;

  CreateStockUseCase(this.repository);

  Future<Stock> call(Map<String, dynamic> stockData) async {
    return await repository.createStock(stockData);
  }
}

class UpdateStockUseCase {
  final StockRepository repository;

  UpdateStockUseCase(this.repository);

  Future<Stock> call(int id, Map<String, dynamic> stockData) async {
    return await repository.updateStock(id, stockData);
  }
}

class DeleteStockUseCase {
  final StockRepository repository;

  DeleteStockUseCase(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteStock(id);
  }
}
