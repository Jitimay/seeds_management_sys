import 'package:equatable/equatable.dart';

enum AuthErrorType {
  network,
  invalidCredentials,
  tokenExpired,
  tokenRefreshFailed,
  storageError,
  unknown,
}

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> user;
  final String token;
  
  AuthAuthenticated({required this.user, required this.token});
  
  @override
  List<Object?> get props => [user, token];
}

class AuthUnauthenticated extends AuthState {}

class AuthTokenRefreshing extends AuthState {}

class AuthTokenExpired extends AuthState {
  final String message;
  
  AuthTokenExpired({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;
  final AuthErrorType type;
  final bool canRetry;
  
  AuthError({
    required this.message,
    this.type = AuthErrorType.unknown,
    this.canRetry = false,
  });
  
  @override
  List<Object?> get props => [message, type, canRetry];
}

class AuthRegistrationSuccess extends AuthState {
  final Map<String, dynamic> user;
  
  AuthRegistrationSuccess({required this.user});
  
  @override
  List<Object?> get props => [user];
}
