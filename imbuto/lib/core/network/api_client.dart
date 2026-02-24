import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

class ApiClient {
  late Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests
          final token = await StorageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle token refresh on 401
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the request
              final options = error.requestOptions;
              final token = await StorageService.getAccessToken();
              options.headers['Authorization'] = 'Bearer $token';
              
              try {
                final response = await _dio.fetch(options);
                handler.resolve(response);
                return;
              } catch (e) {
                handler.next(error);
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await _dio.post(
        AppConstants.refreshEndpoint,
        data: {'refresh': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];
        await StorageService.saveAccessToken(newAccessToken);
        return true;
      }
    } catch (e) {
      // Refresh failed, clear tokens
      await StorageService.clearTokens();
    }
    return false;
  }
  
  Dio get dio => _dio;
}
