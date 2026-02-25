import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imbuto/core/constants/app_constants.dart';
import 'package:imbuto/core/storage/storage_service.dart';
import 'package:imbuto/core/network/api_client.dart';
import 'package:imbuto/shared/services/service_locator.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final token = await StorageService.getSecureString(AppConstants.tokenKey);
      final userDataStr = StorageService.getString(AppConstants.userKey);

      if (token != null && userDataStr != null) {
        // Set token in API client
        ServiceLocator.get<ApiClient>().setAuthToken(token);
        emit(AuthAuthenticated(user: {}, token: token));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
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
      
      // Set token in API client
      ServiceLocator.get<ApiClient>().setAuthToken(token);
      
      emit(AuthAuthenticated(user: result, token: token));
    } catch (e) {
      emit(AuthError(message: e.toString()));
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
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Clear token from API client
    ServiceLocator.get<ApiClient>().clearAuthToken();
    
    await StorageService.clear();
    await StorageService.clearSecure();
    emit(AuthUnauthenticated());
  }
}
