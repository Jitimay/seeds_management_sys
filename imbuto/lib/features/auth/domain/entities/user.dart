class User {
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
  
  User({
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
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
