import '../../../../core/network/api_client.dart';

class AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSource({required this.apiClient});

  // User Validation
  Future<List<Map<String, dynamic>>> getPendingUsers() async {
    final response = await apiClient.dio
        .get('/multiplicateur/', queryParameters: {'is_validated': false});
    return List<Map<String, dynamic>>.from(response.data['results']);
  }

  Future<void> validateUser(int id) async {
    await apiClient.dio
        .patch('/multiplicateur/$id/', data: {'is_validated': true});
  }

  // Stock Validation
  Future<List<Map<String, dynamic>>> getPendingStocks() async {
    final response = await apiClient.dio
        .get('/stock/', queryParameters: {'is_validated': false});
    return List<Map<String, dynamic>>.from(response.data['results']);
  }

  Future<void> validateStock(int id) async {
    await apiClient.dio.get('/stock/$id/validate/');
  }

  // Role Validation
  Future<List<Map<String, dynamic>>> getPendingRoles() async {
    final response = await apiClient.dio
        .get('/role/', queryParameters: {'is_validated': false});
    return List<Map<String, dynamic>>.from(response.data['results']);
  }

  Future<void> validateRole(int id) async {
    await apiClient.dio.patch('/role/$id/', data: {'is_validated': true});
  }
}
