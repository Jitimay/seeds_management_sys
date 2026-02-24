import 'package:equatable/equatable.dart';

class Loss extends Equatable {
  final int id;
  final int stockId;
  final String stockVariety;
  final int quantite;
  final double montantPerdu;
  final String? details;
  final DateTime createdAt;

  const Loss({
    required this.id,
    required this.stockId,
    required this.stockVariety,
    required this.quantite,
    required this.montantPerdu,
    this.details,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, stockId, stockVariety, quantite, montantPerdu, details, createdAt,
  ];
}
