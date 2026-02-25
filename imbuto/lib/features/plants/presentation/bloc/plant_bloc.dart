import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/plant.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/services/service_locator.dart';

abstract class PlantEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPlants extends PlantEvent {}
class AddPlant extends PlantEvent {
  final String name;
  AddPlant(this.name);
  @override
  List<Object?> get props => [name];
}

class DeletePlant extends PlantEvent {
  final int id;
  DeletePlant(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class PlantState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlantInitial extends PlantState {}
class PlantLoading extends PlantState {}
class PlantLoaded extends PlantState {
  final List<Plant> plants;
  PlantLoaded(this.plants);
  @override
  List<Object?> get props => [plants];
}

class PlantError extends PlantState {
  final String message;
  PlantError(this.message);
  @override
  List<Object?> get props => [message];
}

class PlantOperationSuccess extends PlantState {
  final String message;
  PlantOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PlantBloc extends Bloc<PlantEvent, PlantState> {
  final ApiClient _apiClient = ServiceLocator.get<ApiClient>();

  PlantBloc() : super(PlantInitial()) {
    on<LoadPlants>(_onLoadPlants);
    on<AddPlant>(_onAddPlant);
    on<DeletePlant>(_onDeletePlant);
  }

  Future<void> _onLoadPlants(LoadPlants event, Emitter<PlantState> emit) async {
    emit(PlantLoading());
    try {
      final response = await _apiClient.dio.get('plantes/');
      final plants = (response.data['results'] as List)
          .map((json) => Plant(
                id: json['id'],
                name: json['name'],
                createdAt: DateTime.parse(json['created_at']),
              ))
          .toList();
      emit(PlantLoaded(plants));
    } catch (e) {
      emit(PlantError('Erreur lors du chargement: ${e.toString()}'));
    }
  }

  Future<void> _onAddPlant(AddPlant event, Emitter<PlantState> emit) async {
    emit(PlantLoading());
    try {
      await _apiClient.dio.post('plantes/', data: {'name': event.name});
      emit(PlantOperationSuccess('Plante ajoutée avec succès'));
      add(LoadPlants());
    } catch (e) {
      emit(PlantError('Erreur lors de l\'ajout: ${e.toString()}'));
    }
  }

  Future<void> _onDeletePlant(DeletePlant event, Emitter<PlantState> emit) async {
    try {
      await _apiClient.dio.delete('plantes/${event.id}/');
      emit(PlantOperationSuccess('Plante supprimée avec succès'));
      add(LoadPlants());
    } catch (e) {
      emit(PlantError('Erreur lors de la suppression: ${e.toString()}'));
    }
  }
}
