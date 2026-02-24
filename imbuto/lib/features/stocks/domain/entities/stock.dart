import 'package:equatable/equatable.dart';

class Stock extends Equatable {
  final int id;
  final String category;
  final String varietyName;
  final String plantName;
  final double qteTotal;
  final double qteRestante;
  final int prixVenteUnitaire;
  final DateTime? dateExpiration;
  final String? details;
  final DateTime createdAt;
  final DateTime? validatedAt;
  final Map<String, dynamic>? createdBy;
  final Map<String, dynamic>? validatedBy;

  const Stock({
    required this.id,
    required this.category,
    required this.varietyName,
    required this.plantName,
    required this.qteTotal,
    required this.qteRestante,
    required this.prixVenteUnitaire,
    this.dateExpiration,
    this.details,
    required this.createdAt,
    this.validatedAt,
    this.createdBy,
    this.validatedBy,
  });

  bool get isValidated => validatedAt != null;

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      category: json['category'],
      varietyName: json['variety_info']?['nom'] ?? 'N/A',
      plantName: json['variety_info']?['plant_name'] ?? 'N/A',
      qteTotal: json['qte_totale']?.toDouble() ?? 0.0,
      qteRestante: json['qte_restante']?.toDouble() ?? 0.0,
      prixVenteUnitaire: json['prix_vente_unitaire'] ?? 0,
      dateExpiration: json['date_expiration'] != null 
          ? DateTime.parse(json['date_expiration']) 
          : null,
      details: json['details'],
      createdAt: DateTime.parse(json['created_at']),
      validatedAt: json['validated_at'] != null 
          ? DateTime.parse(json['validated_at']) 
          : null,
      createdBy: json['created_by'],
      validatedBy: json['validated_by'],
    );
  }

  @override
  List<Object?> get props => [
    id, category, varietyName, plantName, qteTotal, qteRestante,
    prixVenteUnitaire, dateExpiration, details, createdAt, validatedAt,
  ];
}
