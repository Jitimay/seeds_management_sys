import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/rating.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/services/service_locator.dart';

abstract class RatingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRatings extends RatingEvent {
  final int? stockId;
  LoadRatings({this.stockId});
  @override
  List<Object?> get props => [stockId];
}

class AddRating extends RatingEvent {
  final int stockId;
  final int commandeId;
  final int etoiles;
  final String? commentaire;
  
  AddRating({
    required this.stockId,
    required this.commandeId,
    required this.etoiles,
    this.commentaire,
  });
  
  @override
  List<Object?> get props => [stockId, commandeId, etoiles, commentaire];
}

abstract class RatingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RatingInitial extends RatingState {}
class RatingLoading extends RatingState {}
class RatingLoaded extends RatingState {
  final List<Rating> ratings;
  final double averageRating;
  
  RatingLoaded(this.ratings, this.averageRating);
  
  @override
  List<Object?> get props => [ratings, averageRating];
}

class RatingError extends RatingState {
  final String message;
  RatingError(this.message);
  @override
  List<Object?> get props => [message];
}

class RatingOperationSuccess extends RatingState {
  final String message;
  RatingOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final ApiClient _apiClient = ServiceLocator.get<ApiClient>();

  RatingBloc() : super(RatingInitial()) {
    on<LoadRatings>(_onLoadRatings);
    on<AddRating>(_onAddRating);
  }

  Future<void> _onLoadRatings(LoadRatings event, Emitter<RatingState> emit) async {
    emit(RatingLoading());
    try {
      String url = 'note/';
      if (event.stockId != null) {
        url += '?stock=${event.stockId}';
      }
      
      final response = await _apiClient.dio.get(url);
      final ratings = (response.data['results'] as List)
          .map((json) => Rating(
                id: json['id'],
                stockId: json['stock'],
                commandeId: json['commande'],
                stockVariety: json['stock_variety'] ?? 'N/A',
                etoiles: json['etoiles'],
                commentaire: json['commentaire'],
                createdAt: DateTime.parse(json['created_at']),
                createdBy: json['created_by'] ?? 'N/A',
              ))
          .toList();
      
      final averageRating = ratings.isEmpty 
          ? 0.0 
          : ratings.fold(0.0, (sum, rating) => sum + rating.etoiles) / ratings.length;
      
      emit(RatingLoaded(ratings, averageRating));
    } catch (e) {
      emit(RatingError('Erreur lors du chargement: ${e.toString()}'));
    }
  }

  Future<void> _onAddRating(AddRating event, Emitter<RatingState> emit) async {
    emit(RatingLoading());
    try {
      await _apiClient.dio.post('note/', data: {
        'stock': event.stockId,
        'commande': event.commandeId,
        'etoiles': event.etoiles,
        'commentaire': event.commentaire,
      });
      emit(RatingOperationSuccess('Évaluation ajoutée avec succès'));
      add(LoadRatings(stockId: event.stockId));
    } catch (e) {
      emit(RatingError('Erreur lors de l\'ajout: ${e.toString()}'));
    }
  }
}
