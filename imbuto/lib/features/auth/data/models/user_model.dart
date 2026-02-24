import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.role,
    required super.isValidated,
    super.typeMultiplicator,
    super.province,
    super.commune,
    super.colline,
    super.phoneNumber,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'],
      isValidated: json['is_validated'] ?? false,
      typeMultiplicator: json['type_multiplicator'],
      province: json['province'],
      commune: json['commune'],
      colline: json['colline'],
      phoneNumber: json['phone_number'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'is_validated': isValidated,
      'type_multiplicator': typeMultiplicator,
      'province': province,
      'commune': commune,
      'colline': colline,
      'phone_number': phoneNumber,
    };
  }
}
