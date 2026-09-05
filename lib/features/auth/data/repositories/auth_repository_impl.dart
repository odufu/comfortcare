import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<UserEntity> login({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  }) async {
    final user = await _remoteDataSource.login(
      emailOrPhone: emailOrPhone,
      password: password,
      role: role,
    );
    await _localDataSource.cacheUser(user);
    await _localDataSource.saveToken('token-${user.id}');
    return user;
  }

  @override
  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
    String? facilityName,
    String? licenseNumber,
  }) async {
    final user = await _remoteDataSource.register(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      role: role,
      facilityName: facilityName,
      licenseNumber: licenseNumber,
    );
    await _localDataSource.cacheUser(user);
    await _localDataSource.saveToken('token-${user.id}');
    return user;
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _localDataSource.clearCachedUser();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final cached = await _localDataSource.getCachedUser();
    if (cached != null) return cached;

    final remote = await _remoteDataSource.getCurrentUser();
    if (remote != null) {
      await _localDataSource.cacheUser(remote);
      return remote;
    }
    return null;
  }

  @override
  Future<void> sendPasswordReset(String emailOrPhone) async {
    await _remoteDataSource.sendPasswordReset(emailOrPhone);
  }
}
