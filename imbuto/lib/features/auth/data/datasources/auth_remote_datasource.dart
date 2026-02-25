import 'package:imbuto/core/network/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await apiClient.dio.post('login/', data: {
      'username': username,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response =
        await apiClient.dio.post('Multiplicator/', data: userData);
    return response.data;
  }
}
