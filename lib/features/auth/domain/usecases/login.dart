import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<UserEntity> call({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  }) {
    return _repository.login(
      emailOrPhone: emailOrPhone,
      password: password,
      role: role,
    );
  }
}
