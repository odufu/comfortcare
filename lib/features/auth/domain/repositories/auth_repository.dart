import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  });

  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
    String? facilityName,
    String? licenseNumber,
  });

  Future<void> logout();

  Future<UserEntity?> getCurrentUser();

  Future<void> sendPasswordReset(String emailOrPhone);
}
