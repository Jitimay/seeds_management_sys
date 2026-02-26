class AuthUser {
  final String username;
  final String fullname;
  final String email;
  final String? typeMultiplicator;
  final String province;
  final String commune;
  final String colline;
  final String phoneNumber;
  final String? otherPhoneNumber;
  final bool isValidated;
  final String? documentJustificatif;
  final String createdAt;

  AuthUser({
    required this.username,
    required this.fullname,
    required this.email,
    this.typeMultiplicator,
    required this.province,
    required this.commune,
    required this.colline,
    required this.phoneNumber,
    this.otherPhoneNumber,
    required this.isValidated,
    this.documentJustificatif,
    required this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      username: json['username'] as String,
      fullname: json['fullname'] as String,
      email: json['email'] as String,
      typeMultiplicator: json['type_multiplicator'] as String?,
      province: json['province'] as String,
      commune: json['commune'] as String,
      colline: json['colline'] as String,
      phoneNumber: json['phone_number'] as String,
      otherPhoneNumber: json['other_phone_number'] as String?,
      isValidated: json['is_validated'] as bool,
      documentJustificatif: json['document_justificatif'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fullname': fullname,
      'email': email,
      'type_multiplicator': typeMultiplicator,
      'province': province,
      'commune': commune,
      'colline': colline,
      'phone_number': phoneNumber,
      'other_phone_number': otherPhoneNumber,
      'is_validated': isValidated,
      'document_justificatif': documentJustificatif,
      'created_at': createdAt,
    };
  }
}
