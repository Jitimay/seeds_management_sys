import 'package:dio/dio.dart';
import '../storage/storage_service.dart';
import '../constants/app_constants.dart';

class TokenRefreshService {
  static Future<String?> refreshToken() async {
    try {
      final refreshToken = await StorageService.getSecureString(AppConstants.refreshTokenKey);
      if (refreshToken == null) return null;

      final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
      final response = await dio.post('token/refresh/', data: {'refresh': refreshToken});
      
      final newToken = response.data['access'];
      await StorageService.setSecureString(AppConstants.tokenKey, newToken);
      
      print('Token refreshed successfully');
      return newToken;
    } catch (e) {
      print('Token refresh failed: $e');
      return null;
    }
  }
}
