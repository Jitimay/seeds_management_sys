import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../../core/storage/storage_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  
  LoginRequested({required this.username, required this.password});
  
  @override
  List<Object?> get props => [username, password];
}

class RegisterRequested extends AuthEvent {
  final Map<String, dynamic> userData;
  
  RegisterRequested({required this.userData});
  
  @override
  List<Object?> get props => [userData];
}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  
  AuthAuthenticated({required this.user});
  
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  AuthError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class AuthRegistrationSuccess extends AuthState {
  final User user;
  
  AuthRegistrationSuccess({required this.user});
  
  @override
  List<Object?> get props => [user];
}

// BLoC
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
      final token = await StorageService.getAccessToken();
      final userData = StorageService.getUserData();
      
      if (token != null && userData != null) {
        // User is logged in
        emit(AuthAuthenticated(user: User(
          id: userData['id'] ?? 0,
          username: userData['username'] ?? '',
          email: userData['email'] ?? '',
          firstName: userData['first_name'] ?? '',
          lastName: userData['last_name'] ?? '',
          role: userData['role'],
          isValidated: userData['is_validated'] ?? false,
          typeMultiplicator: userData['type_multiplicator'],
          province: userData['province'],
          commune: userData['commune'],
          colline: userData['colline'],
          phoneNumber: userData['phone_number'],
        )));
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
      
      final user = User(
        id: 0, // Will be updated from API response
        username: result['username'] ?? event.username,
        email: result['email'] ?? '',
        firstName: result['fullname']?.split(' ').first ?? '',
        lastName: result['fullname']?.split(' ').last ?? '',
        role: result['role'],
        isValidated: result['is_validated'] ?? false,
        typeMultiplicator: result['type_multiplicator'],
        province: result['province'],
        commune: result['commune'],
        colline: result['colline'],
        phoneNumber: result['phone_number'],
      );
      
      emit(AuthAuthenticated(user: user));
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
      emit(AuthRegistrationSuccess(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await StorageService.clearAll();
    emit(AuthUnauthenticated());
  }
}
