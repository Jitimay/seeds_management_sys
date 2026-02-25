import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/constants/app_constants.dart';

class OrderApiService {
  final ApiClient _apiClient;

  OrderApiService(this._apiClient);

  Future<List<Map<String, dynamic>>> getOrders() async {
    print('=== ORDERS API CALL ===');
    print(
        'Token in headers: ${_apiClient.dio.options.headers['Authorization']}');
    try {
      final response = await _apiClient.dio.get('commande/');
      print('Orders API success: ${response.statusCode}');
      return _parseResults(response.data);
    } catch (e) {
      print('Orders API error: $e');
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final errorData = e.response?.data;
        print('Status code: $statusCode');
        print('Error data: $errorData');

        if (statusCode == 401) {
          print('Attempting token refresh...');
          final newToken = await _refreshToken();
          if (newToken != null) {
            _apiClient.setAuthToken(newToken);
            print('Retrying with new token...');
            final response = await _apiClient.dio.get('commande/');
            return _parseResults(response.data);
          }
        } else if (statusCode == 403) {
          throw Exception(
              'Accès refusé : votre compte multiplicateur n\'est pas encore validé.');
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

  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    print('API: Creating order with data: $orderData');
    try {
      final response = await _apiClient.dio.post('commande/', data: orderData);
      print('API: Order creation response: ${response.data}');
      return response.data;
    } catch (e) {
      print('API: Order creation error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateOrder(
      int id, Map<String, dynamic> orderData) async {
    final response = await _apiClient.dio.put('commande/$id/', data: orderData);
    return response.data;
  }

  Future<void> deleteOrder(int id) async {
    await _apiClient.dio.delete('commande/$id/');
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken =
          await StorageService.getSecureString(AppConstants.refreshTokenKey);
      if (refreshToken == null) {
        print('No refresh token found');
        return null;
      }

      print('Using refresh token: ${refreshToken.substring(0, 10)}...');
      final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
      final response =
          await dio.post('refresh/', data: {'refresh': refreshToken});

      final newToken = response.data['access'];
      await StorageService.setSecureString(AppConstants.tokenKey, newToken);

      print('Token refreshed successfully: ${newToken.substring(0, 10)}...');
      return newToken;
    } catch (e) {
      print('Token refresh failed: $e');
      // Clear expired tokens
      await StorageService.removeSecure(AppConstants.tokenKey);
      await StorageService.removeSecure(AppConstants.refreshTokenKey);
      return null;
    }
  }
}
