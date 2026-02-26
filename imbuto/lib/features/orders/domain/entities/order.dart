import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final int id;
  final String buyerName;
  final String sellerName;
  final String stockVariety;
  final String stockCategory;
  final double quantity;
  final int prixUnitaire;
  final int montantTotal;
  final int montantPaye;
  final bool isDelivered;
  final DateTime? deliveredDate;
  final DateTime createdAt;
  final bool isDeleted;
  final Map<String, dynamic>? acheteur;
  final Map<String, dynamic>? stock;

  const Order({
    required this.id,
    required this.buyerName,
    required this.sellerName,
    required this.stockVariety,
    required this.stockCategory,
    required this.quantity,
    required this.prixUnitaire,
    required this.montantTotal,
    required this.montantPaye,
    required this.isDelivered,
    this.deliveredDate,
    required this.createdAt,
    required this.isDeleted,
    this.acheteur,
    this.stock,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    String seller = 'N/A';
    final stockData = json['stock'];
    if (stockData != null) {
      final createdBy = stockData['created_by'];
      if (createdBy != null) {
        if (createdBy is Map) {
          seller =
              createdBy['user']?['username'] ?? createdBy['username'] ?? 'N/A';
        } else {
          seller = createdBy.toString();
        }
      }
    }

    return Order(
      id: json['id'],
      buyerName: json['acheteur']?['user']?['username'] ?? 'N/A',
      sellerName: seller,
      stockVariety: json['stock']?['variety_info']?['nom'] ?? 'N/A',
      stockCategory: json['stock']?['category'] ?? 'N/A',
      quantity: json['quantite']?.toDouble() ?? 0.0,
      prixUnitaire: json['prix_unitaire'] ?? 0,
      montantTotal: json['montant_total'] ?? 0,
      montantPaye: json['montant_paye'] ?? 0,
      isDelivered: json['is_delivered'] ?? false,
      deliveredDate: json['delivered_date'] != null
          ? DateTime.parse(json['delivered_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      isDeleted: json['is_deleted'] ?? false,
      acheteur: json['acheteur'],
      stock: json['stock'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        buyerName,
        sellerName,
        stockVariety,
        stockCategory,
        quantity,
        prixUnitaire,
        montantTotal,
        montantPaye,
        isDelivered,
        deliveredDate,
        createdAt,
        isDeleted,
      ];
}
