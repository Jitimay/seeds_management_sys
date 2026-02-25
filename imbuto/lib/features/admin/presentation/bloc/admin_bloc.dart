import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_validation.dart';
import '../../domain/usecases/admin_usecases.dart';

// Events
abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPendingValidations extends AdminEvent {}

class ValidateItem extends AdminEvent {
  final int id;
  final String type;
  ValidateItem(this.id, this.type);
  @override
  List<Object?> get props => [id, type];
}

// States
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
  List<Object?> get props =>
      [pendingMultiplicators, pendingStocks, pendingRoles];
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminOperationSuccess extends AdminState {
  final String message;
  AdminOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetPendingUsersUseCase getPendingUsersUseCase;
  final ValidateUserUseCase validateUserUseCase;
  final GetPendingStocksUseCase getPendingStocksUseCase;
  final ValidateStockUseCase validateStockUseCase;
  final GetPendingRolesUseCase getPendingRolesUseCase;
  final ValidateRoleUseCase validateRoleUseCase;

  AdminBloc({
    required this.getPendingUsersUseCase,
    required this.validateUserUseCase,
    required this.getPendingStocksUseCase,
    required this.validateStockUseCase,
    required this.getPendingRolesUseCase,
    required this.validateRoleUseCase,
  }) : super(AdminInitial()) {
    on<LoadPendingValidations>(_onLoadPendingValidations);
    on<ValidateItem>(_onValidateItem);
  }

  Future<void> _onLoadPendingValidations(
    LoadPendingValidations event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final usersData = await getPendingUsersUseCase();
      final stocksData = await getPendingStocksUseCase();
      final rolesData = await getPendingRolesUseCase();

      final pendingMultiplicators = usersData
          .map((item) => PendingValidation(
                id: item['id'],
                type: 'multiplicator',
                title:
                    '${item['user']['first_name']} ${item['user']['last_name']}',
                subtitle:
                    '${item['commune']}, ${item['province']} - ${item['type_multiplicator']}',
                createdAt: DateTime.parse(item['created_at']),
              ))
          .toList();

      final pendingStocks = stocksData
          .map((item) => PendingValidation(
                id: item['id'],
                type: 'stock',
                title: item['category'] ?? 'Stock',
                subtitle:
                    '${item['qte_totale']} unités - ${item['prix_vente_unitaire']} BIF',
                createdAt: DateTime.parse(item['created_at']),
              ))
          .toList();

      final pendingRoles = rolesData
          .map((item) => PendingValidation(
                id: item['id'],
                type: 'role',
                title: item['type_multiplicator'] ?? 'Rôle',
                subtitle: 'Demande de rôle',
                createdAt: DateTime.parse(item['created_at']),
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

  Future<void> _onValidateItem(
      ValidateItem event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      switch (event.type) {
        case 'multiplicator':
          await validateUserUseCase(event.id);
          break;
        case 'stock':
          await validateStockUseCase(event.id);
          break;
        case 'role':
          await validateRoleUseCase(event.id);
          break;
      }
      emit(AdminOperationSuccess('Validation réussie'));
      add(LoadPendingValidations());
    } catch (e) {
      emit(AdminError('Erreur lors de la validation: ${e.toString()}'));
    }
  }
}
