import 'package:imbuto/core/constants/app_constants.dart';
import 'package:imbuto/core/network/api_client.dart';
import 'package:imbuto/core/storage/storage_service.dart';
import 'package:imbuto/features/auth/domain/entities/user.dart';
import 'package:imbuto/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;

  AuthRepositoryImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await apiClient.dio.post('/login/', data: {
      'username': username,
      'password': password,
    });

    final data = response.data;
    await StorageService.setSecureString(AppConstants.tokenKey, data['access']);
    await StorageService.setString(AppConstants.userKey, data.toString());

    return data;
  }

  @override
  Future<User> register(Map<String, dynamic> userData) async {
    final response =
        await apiClient.dio.post('/Multiplicator/', data: userData);
    return User.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    await StorageService.clear();
    await StorageService.clearSecure();
  }
}
