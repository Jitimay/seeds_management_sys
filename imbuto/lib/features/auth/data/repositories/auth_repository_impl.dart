import 'dart:io';
import 'package:dio/dio.dart';
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
    final file = userData.remove('document_justificatif');
    final Map<String, dynamic> userMap = userData.remove('user');

    final formData = FormData.fromMap({
      ...userData,
      'user.username': userMap['username'],
      'user.email': userMap['email'],
      'user.password': userMap['password'],
      'user.first_name': userMap['first_name'],
      'user.last_name': userMap['last_name'],
    });

    if (file != null && file is File) {
      formData.files.add(MapEntry(
        'document_justificatif',
        await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      ));
    }

    final response =
        await apiClient.dio.post('/Multiplicator/', data: formData);
    return User.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    await StorageService.clear();
    await StorageService.clearSecure();
  }
}
