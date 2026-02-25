class Rating {
  final int id;
  final int stockId;
  final int commandeId;
  final int etoiles;
  final String? commentaire;
  final DateTime createdAt;
  
  Rating({
    required this.id,
    required this.stockId,
    required this.commandeId,
    required this.etoiles,
    this.commentaire,
    required this.createdAt,
  });
  
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      stockId: json['stock'],
      commandeId: json['commande'],
      etoiles: json['etoiles'],
      commentaire: json['commentaire'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
