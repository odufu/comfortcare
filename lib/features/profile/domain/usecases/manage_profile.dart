import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class ManageProfileUseCase {
  final ProfileRepository _repository;

  ManageProfileUseCase(this._repository);

  Future<UserProfileEntity> getProfile() => _repository.getProfile();

  Future<void> updateProfile(UserProfileEntity profile) =>
      _repository.updateProfile(profile);
}
