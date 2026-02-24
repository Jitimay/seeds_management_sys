import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../../core/storage/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  
  AuthRepositoryImpl(this.remoteDataSource);
  
  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final result = await remoteDataSource.login(username, password);
      
      // Save tokens
      await StorageService.saveAccessToken(result['access']);
      await StorageService.saveRefreshToken(result['refresh']);
      
      // Save user data
      final userData = Map<String, dynamic>.from(result);
      userData.remove('access');
      userData.remove('refresh');
      await StorageService.saveUserData(userData);
      
      return result;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
  
  @override
  Future<User> register(Map<String, dynamic> userData) async {
    try {
      return await remoteDataSource.register(userData);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }
  
  @override
  Future<void> logout() async {
    await StorageService.clearAll();
    await remoteDataSource.logout();
  }
  
  @override
  Future<User?> getCurrentUser() async {
    final userData = StorageService.getUserData();
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }
  
  @override
  Future<void> requestPasswordReset(String email) async {
    await remoteDataSource.requestPasswordReset(email);
  }
  
  @override
  Future<void> confirmPasswordReset(String token, String newPassword) async {
    await remoteDataSource.confirmPasswordReset(token, newPassword);
  }
}
