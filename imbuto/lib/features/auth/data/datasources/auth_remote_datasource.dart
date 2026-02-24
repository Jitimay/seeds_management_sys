import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String username, String password);
  Future<UserModel> register(Map<String, dynamic> userData);
  Future<void> logout();
  Future<void> requestPasswordReset(String email);
  Future<void> confirmPasswordReset(String token, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  
  AuthRemoteDataSourceImpl(this.apiClient);
  
  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await apiClient.dio.post(
      'login/',
      data: {
        'username': username,
        'password': password,
      },
    );
    
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Login failed');
    }
  }
  
  @override
  Future<UserModel> register(Map<String, dynamic> userData) async {
    final response = await apiClient.dio.post(
      'Multiplicator/',
      data: userData,
    );
    
    if (response.statusCode == 201) {
      return UserModel.fromJson(response.data['user']);
    } else {
      throw Exception('Registration failed');
    }
  }
  
  @override
  Future<void> logout() async {
    // Clear local tokens - no API call needed for JWT
  }
  
  @override
  Future<void> requestPasswordReset(String email) async {
    await apiClient.dio.post(
      'user/request-reset/',
      data: {'email': email},
    );
  }
  
  @override
  Future<void> confirmPasswordReset(String token, String newPassword) async {
    await apiClient.dio.post(
      'user/confirm-reset/$token/',
      data: {'new_password': newPassword},
    );
  }
}
