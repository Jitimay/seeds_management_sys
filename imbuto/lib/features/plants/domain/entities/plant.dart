class Plant {
  final int id;
  final String name;
  final DateTime createdAt;
  
  Plant({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
