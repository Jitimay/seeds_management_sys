import 'package:equatable/equatable.dart';

class Plant extends Equatable {
  final int id;
  final String name;
  final DateTime createdAt;

  const Plant({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, createdAt];
}
