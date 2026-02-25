import '../../../../core/network/api_client.dart';

class AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSource({required this.apiClient});

  // User Validation
  Future<List<Map<String, dynamic>>> getPendingUsers() async {
    final response = await apiClient.dio
        .get('Multiplicator/', queryParameters: {'is_validated': false});

    dynamic data = response.data;
    if (data is Map && data.containsKey('results')) {
      return List<Map<String, dynamic>>.from(data['results']);
    } else if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  Future<void> validateUser(int id) async {
    await apiClient.dio
        .patch('Multiplicator/$id/', data: {'is_validated': true});
  }

  // Stock Validation
  Future<List<Map<String, dynamic>>> getPendingStocks() async {
    final response = await apiClient.dio
        .get('stock/', queryParameters: {'is_validated': false});

    dynamic data = response.data;
    if (data is Map && data.containsKey('results')) {
      return List<Map<String, dynamic>>.from(data['results']);
    } else if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  Future<void> validateStock(int id) async {
    await apiClient.dio.get('/stock/$id/validate/');
  }

  // Role Validation
  Future<List<Map<String, dynamic>>> getPendingRoles() async {
    final response = await apiClient.dio
        .get('Multiplicator_Roles/', queryParameters: {'is_validated': false});

    dynamic data = response.data;
    if (data is Map && data.containsKey('results')) {
      return List<Map<String, dynamic>>.from(data['results']);
    } else if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  Future<void> validateRole(int id) async {
    await apiClient.dio
        .patch('Multiplicator_Roles/$id/', data: {'is_validated': true});
  }
}
