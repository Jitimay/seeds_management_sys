import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/loss.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/services/service_locator.dart';

abstract class LossEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLosses extends LossEvent {}
class AddLoss extends LossEvent {
  final int stockId;
  final int quantite;
  final String? details;
  
  AddLoss({required this.stockId, required this.quantite, this.details});
  
  @override
  List<Object?> get props => [stockId, quantite, details];
}

abstract class LossState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LossInitial extends LossState {}
class LossLoading extends LossState {}
class LossLoaded extends LossState {
  final List<Loss> losses;
  final double totalLoss;
  
  LossLoaded(this.losses, this.totalLoss);
  
  @override
  List<Object?> get props => [losses, totalLoss];
}

class LossError extends LossState {
  final String message;
  LossError(this.message);
  @override
  List<Object?> get props => [message];
}

class LossOperationSuccess extends LossState {
  final String message;
  LossOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class LossBloc extends Bloc<LossEvent, LossState> {
  final ApiClient _apiClient = ServiceLocator.get<ApiClient>();

  LossBloc() : super(LossInitial()) {
    on<LoadLosses>(_onLoadLosses);
    on<AddLoss>(_onAddLoss);
  }

  Future<void> _onLoadLosses(LoadLosses event, Emitter<LossState> emit) async {
    emit(LossLoading());
    try {
      final response = await _apiClient.dio.get('perte/');
      final losses = (response.data['results'] as List)
          .map((json) => Loss(
                id: json['id'],
                stockId: json['stock'],
                stockVariety: json['stock_variety'] ?? 'N/A',
                quantite: json['quantite'],
                montantPerdu: json['montant_perdu']?.toDouble() ?? 0.0,
                details: json['details'],
                createdAt: DateTime.parse(json['created_at']),
              ))
          .toList();
      
      final totalLoss = losses.fold(0.0, (sum, loss) => sum + loss.montantPerdu);
      emit(LossLoaded(losses, totalLoss));
    } catch (e) {
      emit(LossError('Erreur lors du chargement: ${e.toString()}'));
    }
  }

  Future<void> _onAddLoss(AddLoss event, Emitter<LossState> emit) async {
    emit(LossLoading());
    try {
      await _apiClient.dio.post('perte/', data: {
        'stock': event.stockId,
        'quantite': event.quantite,
        'details': event.details,
      });
      emit(LossOperationSuccess('Perte enregistrée avec succès'));
      add(LoadLosses());
    } catch (e) {
      emit(LossError('Erreur lors de l\'enregistrement: ${e.toString()}'));
    }
  }
}
