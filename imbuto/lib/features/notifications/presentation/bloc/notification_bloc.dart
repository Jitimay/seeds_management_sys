import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../entities/notification.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}
class MarkAsRead extends NotificationEvent {
  final int id;
  MarkAsRead(this.id);
  @override
  List<Object?> get props => [id];
}

class MarkAllAsRead extends NotificationEvent {}
class ClearNotifications extends NotificationEvent {}

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}
class NotificationLoading extends NotificationState {}
class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  
  NotificationLoaded(this.notifications, this.unreadCount);
  
  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationOperationSuccess extends NotificationState {
  final String message;
  NotificationOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<ClearNotifications>(_onClearNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      // TODO: Implement API call
      await Future.delayed(Duration(seconds: 1));
      final notifications = <AppNotification>[];
      final unreadCount = notifications.where((n) => !n.isRead).length;
      emit(NotificationLoaded(notifications, unreadCount));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // TODO: Implement API call
      await Future.delayed(Duration(milliseconds: 500));
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // TODO: Implement API call
      await Future.delayed(Duration(seconds: 1));
      emit(NotificationOperationSuccess('Toutes les notifications marquées comme lues'));
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onClearNotifications(
    ClearNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // TODO: Implement API call
      await Future.delayed(Duration(seconds: 1));
      emit(NotificationOperationSuccess('Notifications supprimées'));
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
