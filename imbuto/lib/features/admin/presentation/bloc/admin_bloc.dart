import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/services/service_locator.dart';

class PendingValidation extends Equatable {
  final int id;
  final String type; // 'multiplicator', 'stock', 'role'
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  const PendingValidation({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.data,
  });

  @override
  List<Object?> get props => [id, type, title, subtitle, createdAt, data];
}

abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPendingValidations extends AdminEvent {}

abstract class AdminState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}
class AdminLoading extends AdminState {}
class AdminLoaded extends AdminState {
  final List<PendingValidation> pendingMultiplicators;
  final List<PendingValidation> pendingStocks;
  final List<PendingValidation> pendingRoles;
  
  AdminLoaded({
    required this.pendingMultiplicators,
    required this.pendingStocks,
    required this.pendingRoles,
  });
  
  @override
  List<Object?> get props => [pendingMultiplicators, pendingStocks, pendingRoles];
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final ApiClient _apiClient = ServiceLocator.get<ApiClient>();

  AdminBloc() : super(AdminInitial()) {
    on<LoadPendingValidations>(_onLoadPendingValidations);
  }

  Future<void> _onLoadPendingValidations(
    LoadPendingValidations event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      // Get pending multiplicators (not validated)
      final multiplicatorsResponse = await _apiClient.dio.get(
        'Multiplicator/?is_validated=false'
      );
      
      // Get pending stocks (not validated)
      final stocksResponse = await _apiClient.dio.get(
        'stock/?validated_at__isnull=true'
      );
      
      // Get pending roles (not validated)
      final rolesResponse = await _apiClient.dio.get(
        'Multiplicator_Roles/?is_validated=false'
      );
      
      // Parse multiplicators
      final pendingMultiplicators = (multiplicatorsResponse.data['results'] as List)
          .map((item) => PendingValidation(
                id: item['id'],
                type: 'multiplicator',
                title: '${item['user']['first_name']} ${item['user']['last_name']}',
                subtitle: '${item['commune']}, ${item['province']} - ${item['type_multiplicator']}',
                createdAt: DateTime.parse(item['created_at']),
                data: item,
              ))
          .toList();
      
      // Parse stocks
      final pendingStocks = (stocksResponse.data['results'] as List)
          .where((item) => item['validated_at'] == null)
          .map((item) => PendingValidation(
                id: item['id'],
                type: 'stock',
                title: item['category'] ?? 'Stock',
                subtitle: '${item['qte_totale']} unités - ${item['prix_vente_unitaire']} BIF',
                createdAt: DateTime.parse(item['created_at']),
                data: item,
              ))
          .toList();
      
      // Parse roles
      final pendingRoles = (rolesResponse.data['results'] as List)
          .map((item) => PendingValidation(
                id: item['id'],
                type: 'role',
                title: item['type_multiplicator'] ?? 'Rôle',
                subtitle: 'Demande de rôle',
                createdAt: DateTime.parse(item['created_at']),
                data: item,
              ))
          .toList();
      
      emit(AdminLoaded(
        pendingMultiplicators: pendingMultiplicators,
        pendingStocks: pendingStocks,
        pendingRoles: pendingRoles,
      ));
    } catch (e) {
      emit(AdminError('Erreur lors du chargement: ${e.toString()}'));
    }
  }
}
