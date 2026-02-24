import 'package:equatable/equatable.dart';

class Rating extends Equatable {
  final int id;
  final int stockId;
  final int commandeId;
  final String stockVariety;
  final int etoiles;
  final String? commentaire;
  final DateTime createdAt;
  final String createdBy;

  const Rating({
    required this.id,
    required this.stockId,
    required this.commandeId,
    required this.stockVariety,
    required this.etoiles,
    this.commentaire,
    required this.createdAt,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [
    id, stockId, commandeId, stockVariety, etoiles, 
    commentaire, createdAt, createdBy,
  ];
}
