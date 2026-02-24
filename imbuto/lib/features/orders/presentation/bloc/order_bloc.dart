import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';

// Events
abstract class OrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderEvent {}

class CreateOrder extends OrderEvent {
  final Map<String, dynamic> orderData;
  CreateOrder(this.orderData);
  @override
  List<Object?> get props => [orderData];
}

class MarkOrderDelivered extends OrderEvent {
  final int orderId;
  MarkOrderDelivered(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class UpdatePayment extends OrderEvent {
  final int orderId;
  final int amount;
  UpdatePayment(this.orderId, this.amount);
  @override
  List<Object?> get props => [orderId, amount];
}

// States
abstract class OrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}
class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<Order> orders;
  OrderLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
  @override
  List<Object?> get props => [message];
}

class OrderOperationSuccess extends OrderState {
  final String message;
  OrderOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<CreateOrder>(_onCreateOrder);
    on<MarkOrderDelivered>(_onMarkOrderDelivered);
    on<UpdatePayment>(_onUpdatePayment);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      // TODO: Implement API call
      final orders = <Order>[];
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onCreateOrder(CreateOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      // TODO: Implement API call
      emit(OrderOperationSuccess('Commande créée avec succès'));
      add(LoadOrders());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onMarkOrderDelivered(MarkOrderDelivered event, Emitter<OrderState> emit) async {
    try {
      // TODO: Implement API call
      emit(OrderOperationSuccess('Commande marquée comme livrée'));
      add(LoadOrders());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onUpdatePayment(UpdatePayment event, Emitter<OrderState> emit) async {
    try {
      // TODO: Implement API call
      emit(OrderOperationSuccess('Paiement mis à jour'));
      add(LoadOrders());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
