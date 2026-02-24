import 'package:equatable/equatable.dart';

class UserRole extends Equatable {
  final int id;
  final int multiplicatorId;
  final String typeMultiplicator;
  final String? documentUrl;
  final bool isValidated;
  final DateTime? validatedAt;
  final String? validatedBy;
  final String? validationReason;
  final DateTime createdAt;

  const UserRole({
    required this.id,
    required this.multiplicatorId,
    required this.typeMultiplicator,
    this.documentUrl,
    required this.isValidated,
    this.validatedAt,
    this.validatedBy,
    this.validationReason,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, multiplicatorId, typeMultiplicator, documentUrl, isValidated,
    validatedAt, validatedBy, validationReason, createdAt,
  ];
}
