import '../../../../core/services/supabase_service.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<void> updateProfile(ProfileModel profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<ProfileModel> getProfile() async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final user = client.auth.currentUser;
        if (user != null) {
          final res = await client.from('profiles').select().eq('id', user.id).maybeSingle();
          if (res != null) {
            return ProfileModel.fromJson(res);
          }
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 250));
    return const ProfileModel(
      id: 'profile-abj-01',
      fullName: 'Dr. Farouk Al-Mansur',
      email: 'doctor@clinic.ng',
      phone: '+234 803 265 1505',
      roleBadge: 'Verified Clinic & Retail Buyer (Tier 2 Wholesale)',
      totalOrders: 18,
      activeRefills: 2,
      pointsBalance: 1450,
      savedPrescriptions: 4,
      primaryAddress: 'Plot 1044, Adetokunbo Ademola Crescent, Wuse 2, Abuja',
    );
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        await client.from('profiles').upsert(profile.toJson());
      } catch (_) {}
    }
  }
}
