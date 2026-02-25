import 'package:equatable/equatable.dart';

class PendingValidation extends Equatable {
  final int id;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final String type; // 'user', 'stock', 'role'

  const PendingValidation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, subtitle, createdAt, type];
}
