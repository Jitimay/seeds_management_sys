import '../entities/user.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String username, String password);
  Future<User> register(Map<String, dynamic> userData);
  Future<void> logout();
}
