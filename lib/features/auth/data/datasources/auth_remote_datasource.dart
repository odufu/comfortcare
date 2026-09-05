import 'package:uuid/uuid.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  });

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
    String? facilityName,
    String? licenseNumber,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<void> sendPasswordReset(String emailOrPhone);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final _uuid = const Uuid();

  @override
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  }) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final response = await client.auth.signInWithPassword(
          email: emailOrPhone,
          password: password,
        );
        final user = response.user;
        if (user == null) throw const AuthException(message: 'Authentication failed');

        final profileRes = await client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profileRes != null) {
          return UserModel.fromJson(profileRes);
        }

        return UserModel(
          id: user.id,
          email: user.email ?? emailOrPhone,
          fullName: user.userMetadata?['full_name'] as String? ?? 'ComfortCare User',
          phoneNumber: user.phone ?? '',
          role: role,
        );
      } catch (e) {
        throw AuthException(message: e.toString());
      }
    }

    // Decoupled Demo Fallback
    await Future.delayed(const Duration(milliseconds: 600));

    if (password.length < 6) {
      throw const AuthException(message: 'Invalid password. Must be at least 6 characters.');
    }

    if (role == UserRole.wholesale) {
      return UserModel(
        id: 'user-abj-wholesale-01',
        email: emailOrPhone.contains('@') ? emailOrPhone : 'wholesale@comfortcare.ng',
        fullName: 'Dr. Farouk Al-Mansur',
        phoneNumber: '+234 803 265 1505',
        role: UserRole.wholesale,
        facilityName: 'Al-Mansur Clinic & Diagnostics',
        licenseNumber: 'PCN-W-89412',
        address: 'Plot 1044, Adetokunbo Ademola Crescent, Wuse 2, Abuja',
        loyaltyPoints: 1450,
        isVerified: true,
      );
    }

    return UserModel(
      id: 'user-abj-patient-01',
      email: emailOrPhone.contains('@') ? emailOrPhone : 'patient@comfortcare.ng',
      fullName: 'Amina Bello',
      phoneNumber: '+234 802 345 6789',
      role: UserRole.patient,
      address: 'Comfort Mall, Life Camp, Abuja',
      loyaltyPoints: 320,
      isVerified: true,
    );
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
    String? facilityName,
    String? licenseNumber,
  }) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final response = await client.auth.signUp(
          email: email,
          password: password,
          data: {
            'full_name': fullName,
            'phone_number': phoneNumber,
            'role': role.name,
            'facility_name': facilityName,
            'license_number': licenseNumber,
          },
        );
        final user = response.user;
        if (user == null) throw const AuthException(message: 'Registration failed');

        final userModel = UserModel(
          id: user.id,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
          role: role,
          facilityName: facilityName,
          licenseNumber: licenseNumber,
        );

        await client.from('profiles').insert(userModel.toJson());
        return userModel;
      } catch (e) {
        throw AuthException(message: e.toString());
      }
    }

    // Decoupled Demo Fallback
    await Future.delayed(const Duration(milliseconds: 700));
    return UserModel(
      id: 'user-new-${_uuid.v4().substring(0, 8)}',
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: role,
      facilityName: facilityName,
      licenseNumber: licenseNumber,
      isVerified: role == UserRole.patient,
    );
  }

  @override
  Future<void> logout() async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      await client.auth.signOut();
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      final user = client.auth.currentUser;
      if (user != null) {
        final profile = await client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        if (profile != null) {
          return UserModel.fromJson(profile);
        }
      }
    }
    return null;
  }

  @override
  Future<void> sendPasswordReset(String emailOrPhone) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized && emailOrPhone.contains('@')) {
      await client.auth.resetPasswordForEmail(emailOrPhone);
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
