import '../network/api_client.dart';

class ApiService {
  final ApiClient _apiClient;
  
  ApiService(this._apiClient);
  
  // Plants
  Future<Map<String, dynamic>> getPlants() async {
    final response = await _apiClient.dio.get('plantes/');
    return response.data;
  }
  
  Future<Map<String, dynamic>> createPlant(String name) async {
    final response = await _apiClient.dio.post('plantes/', data: {'name': name});
    return response.data;
  }
  
  // Varieties
  Future<Map<String, dynamic>> getVarieties() async {
    final response = await _apiClient.dio.get('variete/');
    return response.data;
  }
  
  // Stocks
  Future<Map<String, dynamic>> getStocks() async {
    final response = await _apiClient.dio.get('stock/');
    return response.data;
  }
  
  Future<Map<String, dynamic>> createStock(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post('stock/', data: data);
    return response.data;
  }
  
  // Orders
  Future<Map<String, dynamic>> getOrders() async {
    final response = await _apiClient.dio.get('commande/');
    return response.data;
  }
  
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post('commande/', data: data);
    return response.data;
  }
  
  // Losses
  Future<Map<String, dynamic>> getLosses() async {
    final response = await _apiClient.dio.get('perte/');
    return response.data;
  }
  
  Future<Map<String, dynamic>> createLoss(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post('perte/', data: data);
    return response.data;
  }
  
  // Ratings
  Future<Map<String, dynamic>> getRatings({int? stockId}) async {
    String url = 'note/';
    if (stockId != null) {
      url += '?stock=$stockId';
    }
    final response = await _apiClient.dio.get(url);
    return response.data;
  }
  
  Future<Map<String, dynamic>> createRating(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post('note/', data: data);
    return response.data;
  }
  
  // Multiplicators
  Future<Map<String, dynamic>> getMultiplicators({bool? isValidated}) async {
    String url = 'Multiplicator/';
    if (isValidated != null) {
      url += '?is_validated=$isValidated';
    }
    final response = await _apiClient.dio.get(url);
    return response.data;
  }
  
  // Roles
  Future<Map<String, dynamic>> getRoles({bool? isValidated}) async {
    String url = 'Multiplicator_Roles/';
    if (isValidated != null) {
      url += '?is_validated=$isValidated';
    }
    final response = await _apiClient.dio.get(url);
    return response.data;
  }
}
