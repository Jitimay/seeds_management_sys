import 'package:dio/dio.dart';
import '../storage/storage_service.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'https://assma.amidev.bi/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // Add interceptor for automatic token injection
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token =
            await StorageService.getSecureString(AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle 401 globally here if needed (e.g., logout or refresh token)
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;

  // Keep setAuthToken for backward compatibility but interceptor is preferred
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
