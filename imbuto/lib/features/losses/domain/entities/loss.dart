class Loss {
  final int id;
  final int stockId;
  final int quantite;
  final double montantPerdu;
  final String? details;
  final DateTime createdAt;
  final String? stockVariety;
  
  Loss({
    required this.id,
    required this.stockId,
    required this.quantite,
    required this.montantPerdu,
    this.details,
    required this.createdAt,
    this.stockVariety,
  });
  
  factory Loss.fromJson(Map<String, dynamic> json) {
    return Loss(
      id: json['id'],
      stockId: json['stock'],
      quantite: json['quantite'],
      montantPerdu: json['montant_perdu'].toDouble(),
      details: json['details'],
      createdAt: DateTime.parse(json['created_at']),
      stockVariety: json['stock_variety'],
    );
  }
}
