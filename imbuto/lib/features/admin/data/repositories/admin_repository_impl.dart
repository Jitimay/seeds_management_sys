import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Map<String, dynamic>>> getPendingUsers() async {
    return await remoteDataSource.getPendingUsers();
  }

  @override
  Future<void> validateUser(int id) async {
    await remoteDataSource.validateUser(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingStocks() async {
    return await remoteDataSource.getPendingStocks();
  }

  @override
  Future<void> validateStock(int id) async {
    await remoteDataSource.validateStock(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingRoles() async {
    return await remoteDataSource.getPendingRoles();
  }

  @override
  Future<void> validateRole(int id) async {
    await remoteDataSource.validateRole(id);
  }
}
