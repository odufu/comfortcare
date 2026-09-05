import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

abstract class LocalStorageService {
  Future<bool> saveToken(String token);
  String? getToken();
  Future<bool> removeToken();

  Future<bool> saveUserJson(String userJson);
  String? getUserJson();
  Future<bool> removeUserJson();

  Future<bool> saveRole(String role);
  String? getRole();

  Future<bool> saveThemeMode(String themeMode);
  String? getThemeMode();

  Future<bool> setOnboardingCompleted();
  bool isOnboardingCompleted();

  Future<bool> saveCartJson(String cartJson);
  String? getCartJson();

  Future<bool> clearAll();
}

class LocalStorageServiceImpl implements LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageServiceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<bool> saveToken(String token) async {
    return _prefs.setString(AppConstants.tokenKey, token);
  }

  @override
  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  @override
  Future<bool> removeToken() async {
    return _prefs.remove(AppConstants.tokenKey);
  }

  @override
  Future<bool> saveUserJson(String userJson) async {
    return _prefs.setString(AppConstants.userKey, userJson);
  }

  @override
  String? getUserJson() {
    return _prefs.getString(AppConstants.userKey);
  }

  @override
  Future<bool> removeUserJson() async {
    return _prefs.remove(AppConstants.userKey);
  }

  @override
  Future<bool> saveRole(String role) async {
    return _prefs.setString(AppConstants.roleKey, role);
  }

  @override
  String? getRole() {
    return _prefs.getString(AppConstants.roleKey);
  }

  @override
  Future<bool> saveThemeMode(String themeMode) async {
    return _prefs.setString(AppConstants.themeModeKey, themeMode);
  }

  @override
  String? getThemeMode() {
    return _prefs.getString(AppConstants.themeModeKey);
  }

  @override
  Future<bool> setOnboardingCompleted() async {
    return _prefs.setBool(AppConstants.onboardingKey, true);
  }

  @override
  bool isOnboardingCompleted() {
    return _prefs.getBool(AppConstants.onboardingKey) ?? false;
  }

  @override
  Future<bool> saveCartJson(String cartJson) async {
    return _prefs.setString(AppConstants.cartKey, cartJson);
  }

  @override
  String? getCartJson() {
    return _prefs.getString(AppConstants.cartKey);
  }

  @override
  Future<bool> clearAll() async {
    return _prefs.clear();
  }
}
