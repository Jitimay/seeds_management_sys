import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  
  RegisterUseCase(this.repository);
  
  Future<User> call(Map<String, dynamic> userData) {
    return repository.register(userData);
  }
}
