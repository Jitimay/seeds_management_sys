import 'package:equatable/equatable.dart';

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

class LogoutRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final Map<String, dynamic> userData;
  
  RegisterRequested({required this.userData});
  
  @override
  List<Object?> get props => [userData];
}
