class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? role;
  final bool isValidated;
  final String? typeMultiplicator;
  final String? types; // multiplicateurs or cultivateurs
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
    this.types,
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
      role: json['role']?.toString(),
      isValidated: json['is_validated'] ?? false,
      typeMultiplicator: json['type_multiplicator']?.toString(),
      types: json['types']?.toString(),
      province: json['province']?.toString(),
      commune: json['commune']?.toString(),
      colline: json['colline']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
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
      'types': types,
      'province': province,
      'commune': commune,
      'colline': colline,
      'phone_number': phoneNumber,
    };
  }
}
