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
    _setupInterceptors();
  }

  bool _isRefreshing = false;

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token =
            await StorageService.getSecureString(AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          if (_isRefreshing) {
            // Wait a bit and retry the request - simple queueing
            await Future.delayed(const Duration(seconds: 2));
            final retryResponse = await _dio.request(
              e.requestOptions.path,
              data: e.requestOptions.data,
              queryParameters: e.requestOptions.queryParameters,
              options: Options(
                method: e.requestOptions.method,
                headers: e.requestOptions.headers,
              ),
            );
            return handler.resolve(retryResponse);
          }

          _isRefreshing = true;
          final refreshToken = await StorageService.getSecureString(
              AppConstants.refreshTokenKey);

          if (refreshToken != null) {
            try {
              final refreshDio =
                  Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
              final response = await refreshDio.post('token/refresh/', data: {
                'refresh': refreshToken,
              });

              final newToken = response.data['access'];
              if (newToken != null) {
                await StorageService.setSecureString(
                    AppConstants.tokenKey, newToken);
                _isRefreshing = false;

                e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                final opts = Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                );
                final retryResponse = await _dio.request(
                  e.requestOptions.path,
                  data: e.requestOptions.data,
                  queryParameters: e.requestOptions.queryParameters,
                  options: opts,
                );
                return handler.resolve(retryResponse);
              }
            } catch (refreshError) {
              _isRefreshing = false;
              print('Token refresh failed: $refreshError');
            }
          }
          _isRefreshing = false;
        }
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
