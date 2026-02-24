import '../entities/user.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String username, String password);
  Future<User> register(Map<String, dynamic> userData);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> requestPasswordReset(String email);
  Future<void> confirmPasswordReset(String token, String newPassword);
}
