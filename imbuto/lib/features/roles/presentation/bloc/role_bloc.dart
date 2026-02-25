import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_role.dart';

abstract class RoleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserRoles extends RoleEvent {}
class RequestNewRole extends RoleEvent {
  final String typeMultiplicator;
  final String documentPath;
  
  RequestNewRole({
    required this.typeMultiplicator,
    required this.documentPath,
  });
  
  @override
  List<Object?> get props => [typeMultiplicator, documentPath];
}

abstract class RoleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoleInitial extends RoleState {}
class RoleLoading extends RoleState {}
class RoleLoaded extends RoleState {
  final List<UserRole> roles;
  
  RoleLoaded(this.roles);
  
  @override
  List<Object?> get props => [roles];
}

class RoleError extends RoleState {
  final String message;
  RoleError(this.message);
  @override
  List<Object?> get props => [message];
}

class RoleOperationSuccess extends RoleState {
  final String message;
  RoleOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class RoleBloc extends Bloc<RoleEvent, RoleState> {
  RoleBloc() : super(RoleInitial()) {
    on<LoadUserRoles>(_onLoadUserRoles);
    on<RequestNewRole>(_onRequestNewRole);
  }

  Future<void> _onLoadUserRoles(
    LoadUserRoles event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleLoading());
    try {
      // TODO: Implement API call
      await Future.delayed(Duration(seconds: 1));
      emit(RoleLoaded([]));
    } catch (e) {
      emit(RoleError(e.toString()));
    }
  }

  Future<void> _onRequestNewRole(
    RequestNewRole event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleLoading());
    try {
      // TODO: Implement API call
      await Future.delayed(Duration(seconds: 2));
      emit(RoleOperationSuccess('Demande de rôle soumise avec succès'));
      add(LoadUserRoles());
    } catch (e) {
      emit(RoleError(e.toString()));
    }
  }
}
