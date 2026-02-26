import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imbuto/core/constants/app_constants.dart';
import 'package:imbuto/core/storage/storage_service.dart';
import 'package:imbuto/core/network/api_client.dart';
import 'package:imbuto/core/services/token_manager.dart';
import 'package:imbuto/shared/services/service_locator.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final TokenManager tokenManager;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.tokenManager,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<TokenRefreshRequested>(_onTokenRefreshRequested);
    on<TokenValidationRequested>(_onTokenValidationRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Check if tokens exist
      final hasTokens = await tokenManager.hasValidTokens();
      
      if (!hasTokens) {
        emit(AuthUnauthenticated());
        return;
      }

      // Get tokens
      final token = await tokenManager.getAccessToken();
      final userDataStr = StorageService.getString(AppConstants.userKey);

      if (token == null || userDataStr == null) {
        emit(AuthUnauthenticated());
        return;
      }

      // Validate token
      final isValid = await tokenManager.validateAccessToken();
      
      if (!isValid) {
        // Try to refresh token
        final newToken = await tokenManager.refreshAccessToken();
        
        if (newToken != null) {
          // Update API client with new token
          ServiceLocator.get<ApiClient>().setAuthToken(newToken);
          
          try {
            final userData = jsonDecode(userDataStr);
            emit(AuthAuthenticated(user: userData, token: newToken));
          } catch (e) {
            emit(AuthUnauthenticated());
          }
        } else {
          // Refresh failed, logout
          await tokenManager.clearTokens();
          await StorageService.clear();
          emit(AuthUnauthenticated());
        }
      } else {
        // Token is valid, set it in API client
        ServiceLocator.get<ApiClient>().setAuthToken(token);
        
        try {
          final userData = jsonDecode(userDataStr);
          emit(AuthAuthenticated(user: userData, token: token));
        } catch (e) {
          emit(AuthUnauthenticated());
        }
      }
    } catch (e) {
      emit(AuthError(
        message: 'Authentication check failed',
        type: AuthErrorType.unknown,
      ));
    }
  }

  Future<void> _onTokenValidationRequested(
    TokenValidationRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isValid = await tokenManager.validateAccessToken();
      
      if (!isValid) {
        add(TokenRefreshRequested());
      }
    } catch (e) {
      emit(AuthError(
        message: 'Token validation failed',
        type: AuthErrorType.tokenExpired,
      ));
    }
  }

  Future<void> _onTokenRefreshRequested(
    TokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthTokenRefreshing());

    try {
      final newToken = await tokenManager.refreshAccessToken();
      
      if (newToken != null) {
        ServiceLocator.get<ApiClient>().setAuthToken(newToken);
        
        final userDataStr = StorageService.getString(AppConstants.userKey);
        if (userDataStr != null) {
          final userData = jsonDecode(userDataStr);
          emit(AuthAuthenticated(user: userData, token: newToken));
        }
      } else {
        emit(AuthTokenExpired(message: 'Session expired. Please login again.'));
        add(LogoutRequested());
      }
    } catch (e) {
      emit(AuthError(
        message: 'Token refresh failed',
        type: AuthErrorType.tokenRefreshFailed,
      ));
      add(LogoutRequested());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await loginUseCase(event.username, event.password);
      final token = result['access'] ?? '';
      final refreshToken = result['refresh'] ?? '';

      // Store tokens using TokenManager
      await tokenManager.saveTokens(token, refreshToken);
      await StorageService.setString(AppConstants.userKey, jsonEncode(result));

      // Set token in API client
      ServiceLocator.get<ApiClient>().setAuthToken(token);

      emit(AuthAuthenticated(user: result, token: token));
    } catch (e) {
      emit(AuthError(
        message: e.toString(),
        type: AuthErrorType.invalidCredentials,
        canRetry: true,
      ));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await registerUseCase(event.userData);
      emit(AuthRegistrationSuccess(user: user.toJson()));
    } catch (e) {
      emit(AuthError(
        message: e.toString(),
        type: AuthErrorType.unknown,
      ));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Clear token from API client
    ServiceLocator.get<ApiClient>().clearAuthToken();

    // Clear tokens using TokenManager
    await tokenManager.clearTokens();
    await StorageService.clear();
    
    emit(AuthUnauthenticated());
  }
}
