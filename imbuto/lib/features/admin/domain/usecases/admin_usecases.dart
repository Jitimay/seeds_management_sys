import '../repositories/admin_repository.dart';

class GetPendingUsersUseCase {
  final AdminRepository repository;
  GetPendingUsersUseCase({required this.repository});
  Future<List<Map<String, dynamic>>> call() async =>
      await repository.getPendingUsers();
}

class ValidateUserUseCase {
  final AdminRepository repository;
  ValidateUserUseCase({required this.repository});
  Future<void> call(int id) async => await repository.validateUser(id);
}

class GetPendingStocksUseCase {
  final AdminRepository repository;
  GetPendingStocksUseCase({required this.repository});
  Future<List<Map<String, dynamic>>> call() async =>
      await repository.getPendingStocks();
}

class ValidateStockUseCase {
  final AdminRepository repository;
  ValidateStockUseCase({required this.repository});
  Future<void> call(int id) async => await repository.validateStock(id);
}

class GetPendingRolesUseCase {
  final AdminRepository repository;
  GetPendingRolesUseCase({required this.repository});
  Future<List<Map<String, dynamic>>> call() async =>
      await repository.getPendingRoles();
}

class ValidateRoleUseCase {
  final AdminRepository repository;
  ValidateRoleUseCase({required this.repository});
  Future<void> call(int id) async => await repository.validateRole(id);
}
