import '../../../../core/storage/local_storage_service.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCachedUser();
  Future<void> saveToken(String token);
  String? getToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorageService _storageService;

  AuthLocalDataSourceImpl(this._storageService);

  @override
  Future<void> cacheUser(UserModel user) async {
    await _storageService.saveUserJson(user.toJsonString());
    await _storageService.saveRole(user.role.name);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonStr = _storageService.getUserJson();
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return UserModel.fromJsonString(jsonStr);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearCachedUser() async {
    await _storageService.removeUserJson();
    await _storageService.removeToken();
  }

  @override
  Future<void> saveToken(String token) async {
    await _storageService.saveToken(token);
  }

  @override
  String? getToken() {
    return _storageService.getToken();
  }
}
