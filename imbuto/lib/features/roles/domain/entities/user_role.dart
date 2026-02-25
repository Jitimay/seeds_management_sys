class UserRole {
  final int id;
  final int multiplicatorId;
  final String typeMultiplicator;
  final String document;
  final bool isValidated;
  final DateTime? validatedAt;
  final DateTime createdAt;
  
  UserRole({
    required this.id,
    required this.multiplicatorId,
    required this.typeMultiplicator,
    required this.document,
    required this.isValidated,
    this.validatedAt,
    required this.createdAt,
  });
  
  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'],
      multiplicatorId: json['multiplicator'],
      typeMultiplicator: json['type_multiplicator'],
      document: json['document'],
      isValidated: json['is_validated'],
      validatedAt: json['validated_at'] != null 
          ? DateTime.parse(json['validated_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
