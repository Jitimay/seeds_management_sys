import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  
  RegisterUseCase({required this.repository});
  
  Future<User> call(Map<String, dynamic> userData) async {
    return await repository.register(userData);
  }
}
