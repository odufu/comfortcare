import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfileEntity> getProfile();
  Future<void> updateProfile(UserProfileEntity profile);
}
