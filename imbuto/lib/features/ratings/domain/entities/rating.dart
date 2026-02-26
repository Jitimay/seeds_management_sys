class Rating {
  final int id;
  final int stockId;
  final int commandeId;
  final int etoiles;
  final String? commentaire;
  final DateTime createdAt;
  final String? stockVariety;
  final String? createdBy;

  Rating({
    required this.id,
    required this.stockId,
    required this.commandeId,
    required this.etoiles,
    this.commentaire,
    required this.createdAt,
    this.stockVariety,
    this.createdBy,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] ?? 0,
      stockId: json['stock'] is int
          ? json['stock']
          : (int.tryParse(json['stock'].toString()) ?? 0),
      commandeId: json['commande'] is int
          ? json['commande']
          : (int.tryParse(json['commande'].toString()) ?? 0),
      etoiles: json['etoiles'] ?? 0,
      commentaire: json['commentaire'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      stockVariety: json['stock_variety']?.toString(),
      createdBy: _parseCreatedBy(json['created_by']),
    );
  }

  static String? _parseCreatedBy(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      return value['username'] ??
          value['name'] ??
          value['first_name'] ??
          value.toString();
    }
    return value.toString();
  }
}
