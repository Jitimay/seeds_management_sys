import 'package:equatable/equatable.dart';

enum NotificationType {
  orderUpdate,
  stockValidation,
  userValidation,
  roleValidation,
  systemAnnouncement,
  newOrder,
}

class AppNotification extends Equatable {
  final int id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  @override
  List<Object?> get props => [
    id, title, message, type, isRead, createdAt, data,
  ];
}
