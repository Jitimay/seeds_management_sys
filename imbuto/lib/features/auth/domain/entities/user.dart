import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? role;
  final bool isValidated;
  final String? typeMultiplicator;
  final String? province;
  final String? commune;
  final String? colline;
  final String? phoneNumber;
  
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.role,
    required this.isValidated,
    this.typeMultiplicator,
    this.province,
    this.commune,
    this.colline,
    this.phoneNumber,
  });
  
  @override
  List<Object?> get props => [
    id,
    username,
    email,
    firstName,
    lastName,
    role,
    isValidated,
    typeMultiplicator,
    province,
    commune,
    colline,
    phoneNumber,
  ];
}
