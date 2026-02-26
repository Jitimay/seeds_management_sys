import 'dart:convert';
import 'package:dio/dio.dart';
import '../storage/storage_service.dart';
import '../constants/app_constants.dart';

class TokenManager {
  final Dio _dio;

  TokenManager() : _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  // Token storage
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await StorageService.setSecureString(AppConstants.tokenKey, accessToken);
    await StorageService.setSecureString(AppConstants.refreshTokenKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await StorageService.getSecureString(AppConstants.tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await StorageService.getSecureString(AppConstants.refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await StorageService.removeSecure(AppConstants.tokenKey);
    await StorageService.removeSecure(AppConstants.refreshTokenKey);
  }

  // Token validation
  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    
    if (accessToken == null || refreshToken == null) {
      return false;
    }
    
    // Check if tokens are not empty
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      return false;
    }
    
    return true;
  }

  Future<bool> validateAccessToken() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      // Make a simple API call to validate the token
      final response = await _dio.get(
        'Multiplicator/',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Token refresh
  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final response = await _dio.post(
        'token/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'] as String;
        await StorageService.setSecureString(AppConstants.tokenKey, newAccessToken);
        return newAccessToken;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Token utilities
  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        return DateTime.now().isAfter(expirationDate);
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  DateTime? getTokenExpirationTime(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String maskToken(String token) {
    if (token.length <= 14) {
      return '***';
    }
    final start = token.substring(0, 10);
    final end = token.substring(token.length - 4);
    return '$start...${end}';
  }
}
