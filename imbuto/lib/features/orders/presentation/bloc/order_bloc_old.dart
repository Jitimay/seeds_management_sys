// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import '../../domain/entities/order.dart';
// import '../../domain/usecases/order_usecases.dart';

// // Events
// abstract class OrderEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class LoadOrders extends OrderEvent {}

// class CreateOrder extends OrderEvent {
//   final Map<String, dynamic> orderData;
//   CreateOrder(this.orderData);
//   @override
//   List<Object?> get props => [orderData];
// }

// class MarkOrderDelivered extends OrderEvent {
//   final int orderId;
//   MarkOrderDelivered(this.orderId);
//   @override
//   List<Object?> get props => [orderId];
// }

// class UpdatePayment extends OrderEvent {
//   final int orderId;
//   final int amount;
//   UpdatePayment(this.orderId, this.amount);
//   @override
//   List<Object?> get props => [orderId, amount];
// }

// class CancelOrder extends OrderEvent {
//   final int orderId;
//   CancelOrder(this.orderId);
//   @override
//   List<Object?> get props => [orderId];
// }

// // States
// abstract class OrderState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class OrderInitial extends OrderState {}

// class OrderLoading extends OrderState {}

// class OrderLoaded extends OrderState {
//   final List<Order> orders;
//   OrderLoaded(this.orders);
//   @override
//   List<Object?> get props => [orders];
// }

// class OrderError extends OrderState {
//   final String message;
//   OrderError(this.message);
//   @override
//   List<Object?> get props => [message];
// }

// class OrderOperationSuccess extends OrderState {
//   final String message;
//   OrderOperationSuccess(this.message);
//   @override
//   List<Object?> get props => [message];
// }

// // BLoC
// class OrderBloc extends Bloc<OrderEvent, OrderState> {
//   final GetOrdersUseCase getOrdersUseCase;
//   final CreateOrderUseCase createOrderUseCase;
//   final DeliverOrderUseCase deliverOrderUseCase;
//   final UpdateOrderUseCase updateOrderUseCase;
//   final CancelOrderUseCase cancelOrderUseCase;

//   OrderBloc({
//     required this.getOrdersUseCase,
//     required this.createOrderUseCase,
//     required this.deliverOrderUseCase,
//     required this.updateOrderUseCase,
//     required this.cancelOrderUseCase,
//   }) : super(OrderInitial()) {
//     on<LoadOrders>(_onLoadOrders);
//     on<CreateOrder>(_onCreateOrder);
//     on<MarkOrderDelivered>(_onMarkOrderDelivered);
//     on<UpdatePayment>(_onUpdatePayment);
//     on<CancelOrder>(_onCancelOrder);
//   }

//   Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) async {
//     emit(OrderLoading());
//     try {
//       final orders = await getOrdersUseCase();
//       emit(OrderLoaded(orders));
//     } catch (e) {
//       emit(OrderError(e.toString()));
//     }
//   }

//   Future<void> _onCreateOrder(
//       CreateOrder event, Emitter<OrderState> emit) async {
//     emit(OrderLoading());
//     try {
//       await createOrderUseCase(event.orderData);
//       emit(OrderOperationSuccess('Commande créée avec succès'));
//       add(LoadOrders());
//     } catch (e) {
//       emit(OrderError(e.toString()));
//     }
//   }

//   Future<void> _onMarkOrderDelivered(
//       MarkOrderDelivered event, Emitter<OrderState> emit) async {
//     emit(OrderLoading()); // Added loading state
//     try {
//       await deliverOrderUseCase(event.orderId);
//       emit(OrderOperationSuccess('Commande marquée comme livrée'));
//       add(LoadOrders());
//     } catch (e) {
//       emit(OrderError(e.toString()));
//     }
//   }

//   Future<void> _onUpdatePayment(
//       UpdatePayment event, Emitter<OrderState> emit) async {
//     emit(OrderLoading());
//     try {
//       await updateOrderUseCase(event.orderId, {'montant_paye': event.amount});
//       emit(OrderOperationSuccess('Paiement mis à jour'));
//       add(LoadOrders());
//     } catch (e) {
//       emit(OrderError(e.toString()));
//     }
//   }

//   Future<void> _onCancelOrder(
//       CancelOrder event, Emitter<OrderState> emit) async {
//     emit(OrderLoading());
//     try {
//       await cancelOrderUseCase(event.orderId);
//       emit(OrderOperationSuccess('Commande annulée'));
//       add(LoadOrders());
//     } catch (e) {
//       emit(OrderError(e.toString()));
//     }
//   }
// }
