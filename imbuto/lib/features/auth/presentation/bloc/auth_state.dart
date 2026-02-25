import 'package:equatable/equatable.dart';

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

class AuthError extends AuthState {
  final String message;
  
  AuthError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class AuthRegistrationSuccess extends AuthState {
  final Map<String, dynamic> user;
  
  AuthRegistrationSuccess({required this.user});
  
  @override
  List<Object?> get props => [user];
}
