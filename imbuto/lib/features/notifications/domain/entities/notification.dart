enum NotificationType {
  info,
  warning,
  error,
  success,
  order,
  stock,
  orderUpdate,
  stockValidation,
  userValidation,
  roleValidation,
  systemAnnouncement,
  newOrder,
}

class AppNotification {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final NotificationType type;
  
  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.type,
  });
  
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
      type: _parseNotificationType(json['type'] ?? 'info'),
    );
  }
  
  static NotificationType _parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'warning':
        return NotificationType.warning;
      case 'error':
        return NotificationType.error;
      case 'success':
        return NotificationType.success;
      case 'order':
        return NotificationType.order;
      case 'stock':
        return NotificationType.stock;
      case 'orderupdate':
      case 'order_update':
        return NotificationType.orderUpdate;
      case 'stockvalidation':
      case 'stock_validation':
        return NotificationType.stockValidation;
      case 'uservalidation':
      case 'user_validation':
        return NotificationType.userValidation;
      case 'rolevalidation':
      case 'role_validation':
        return NotificationType.roleValidation;
      case 'systemannouncement':
      case 'system_announcement':
        return NotificationType.systemAnnouncement;
      case 'neworder':
      case 'new_order':
        return NotificationType.newOrder;
      default:
        return NotificationType.info;
    }
  }
}
