import 'package:dio/dio.dart';
import '../services/token_manager.dart';

class ApiClient {
  late final Dio _dio;
  final TokenManager tokenManager;
  bool _isRefreshing = false;
  final List<_QueuedRequest> _requestQueue = [];

  ApiClient({String? baseUrl, required this.tokenManager}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'https://assma.amidev.bi/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenManager.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          if (_isRefreshing) {
            return _queueRequest(e, handler);
          }
          return _handleTokenRefresh(e, handler);
        }
        return handler.next(e);
      },
    ));
  }

  Future<void> _handleTokenRefresh(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    _isRefreshing = true;

    try {
      final newToken = await tokenManager.refreshAccessToken();

      if (newToken != null && newToken.isNotEmpty) {
        _isRefreshing = false;
        await _retryQueuedRequests(newToken);

        // Retry the original request
        error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(error.requestOptions);
        return handler.resolve(response);
      } else {
        _isRefreshing = false;
        await _failQueuedRequests();
        return handler.next(error);
      }
    } catch (e) {
      _isRefreshing = false;
      await _failQueuedRequests();
      return handler.next(error);
    }
  }

  Future<void> _queueRequest(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final queuedRequest = _QueuedRequest(
      requestOptions: error.requestOptions,
      handler: handler,
    );
    _requestQueue.add(queuedRequest);

    // Wait for refresh to complete
    while (_isRefreshing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _retryQueuedRequests(String newToken) async {
    final requests = List<_QueuedRequest>.from(_requestQueue);
    _requestQueue.clear();

    for (final request in requests) {
      try {
        request.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(request.requestOptions);
        request.handler.resolve(response);
      } catch (e) {
        request.handler.next(
          DioException(
            requestOptions: request.requestOptions,
            error: e,
          ),
        );
      }
    }
  }

  Future<void> _failQueuedRequests() async {
    final requests = List<_QueuedRequest>.from(_requestQueue);
    _requestQueue.clear();

    for (final request in requests) {
      request.handler.next(
        DioException(
          requestOptions: request.requestOptions,
          response: Response(
            requestOptions: request.requestOptions,
            statusCode: 401,
          ),
        ),
      );
    }
  }

  Dio get dio => _dio;

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

class _QueuedRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _QueuedRequest({
    required this.requestOptions,
    required this.handler,
  });
}
