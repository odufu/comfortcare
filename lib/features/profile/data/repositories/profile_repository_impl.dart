import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserProfileEntity> getProfile() async {
    return _remoteDataSource.getProfile();
  }

  @override
  Future<void> updateProfile(UserProfileEntity profile) async {
    final model = profile is ProfileModel
        ? profile
        : ProfileModel(
            id: profile.id,
            fullName: profile.fullName,
            email: profile.email,
            phone: profile.phone,
            roleBadge: profile.roleBadge,
            totalOrders: profile.totalOrders,
            activeRefills: profile.activeRefills,
            pointsBalance: profile.pointsBalance,
            savedPrescriptions: profile.savedPrescriptions,
            primaryAddress: profile.primaryAddress,
          );
    await _remoteDataSource.updateProfile(model);
  }
}
