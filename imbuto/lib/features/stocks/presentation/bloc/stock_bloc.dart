import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/stock.dart';

// Events
abstract class StockEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStocks extends StockEvent {}

class CreateStock extends StockEvent {
  final Map<String, dynamic> stockData;
  CreateStock(this.stockData);
  @override
  List<Object?> get props => [stockData];
}

class UpdateStock extends StockEvent {
  final int id;
  final Map<String, dynamic> stockData;
  UpdateStock(this.id, this.stockData);
  @override
  List<Object?> get props => [id, stockData];
}

class DeleteStock extends StockEvent {
  final int id;
  DeleteStock(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class StockState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StockInitial extends StockState {}
class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<Stock> stocks;
  StockLoaded(this.stocks);
  @override
  List<Object?> get props => [stocks];
}

class StockError extends StockState {
  final String message;
  StockError(this.message);
  @override
  List<Object?> get props => [message];
}

class StockOperationSuccess extends StockState {
  final String message;
  StockOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class StockBloc extends Bloc<StockEvent, StockState> {
  StockBloc() : super(StockInitial()) {
    on<LoadStocks>(_onLoadStocks);
    on<CreateStock>(_onCreateStock);
    on<UpdateStock>(_onUpdateStock);
    on<DeleteStock>(_onDeleteStock);
  }

  Future<void> _onLoadStocks(LoadStocks event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      // TODO: Implement API call
      final stocks = <Stock>[];
      emit(StockLoaded(stocks));
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }

  Future<void> _onCreateStock(CreateStock event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      // TODO: Implement API call
      emit(StockOperationSuccess('Stock créé avec succès'));
      add(LoadStocks());
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }

  Future<void> _onUpdateStock(UpdateStock event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      // TODO: Implement API call
      emit(StockOperationSuccess('Stock mis à jour'));
      add(LoadStocks());
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }

  Future<void> _onDeleteStock(DeleteStock event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      // TODO: Implement API call
      emit(StockOperationSuccess('Stock supprimé'));
      add(LoadStocks());
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }
}
