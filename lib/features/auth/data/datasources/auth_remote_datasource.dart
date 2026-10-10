import 'package:uuid/uuid.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import '../../../consultants/data/datasources/consultants_remote_datasource.dart';
import '../../../consultants/data/models/doctor_model.dart';

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
    String? specialty,
    String? documentationName,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<void> sendPasswordReset(String emailOrPhone);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final _uuid = const Uuid();

  bool _isDemoAccount(String emailOrPhone) {
    final normalized = emailOrPhone.trim().toLowerCase();
    return normalized == 'user@comfortcare.ng' ||
        normalized == 'patient@comfortcare.ng' ||
        normalized == 'consultant@comfortcare.ng' ||
        normalized == 'doctor@comfortcare.ng' ||
        normalized == 'dr.eze@comfortcare.ng' ||
        normalized == 'pharmacy@comfortcare.ng' ||
        normalized == 'clinic@cedarcrest.ng' ||
        normalized == 'wholesale@comfortcare.ng' ||
        normalized == 'pharmacist.amina@comfortcare.ng' ||
        normalized == 'pharm@comfortcare.ng' ||
        normalized == 'admin@comfortcare.ng' ||
        normalized.endsWith('@comfortcare.ng');
  }

  UserModel _getDemoUser({
    required String emailOrPhone,
    required UserRole role,
  }) {
    final normalized = emailOrPhone.trim().toLowerCase();

    // 1. Admin Demo Account
    if (normalized == 'admin@comfortcare.ng' || role == UserRole.admin) {
      return UserModel(
        id: 'user-abj-admin-01',
        email: emailOrPhone.contains('@') ? emailOrPhone.trim() : 'admin@comfortcare.ng',
        fullName: 'ComfortCare Admin',
        phoneNumber: '+234 809 111 2233',
        role: UserRole.admin,
        facilityName: 'ComfortCare Operations HQ & Medical Board',
        licenseNumber: 'PCN-ADMIN-01',
        address: 'Plot 1044, Adetokunbo Ademola Crescent, Wuse 2, Abuja',
        loyaltyPoints: 9999,
        isVerified: true,
        approvalStatus: 'approved',
      );
    }

    // 2. Pharmacy Demo Account (selling drugs & wholesale buying)
    if (normalized == 'pharmacy@comfortcare.ng' ||
        normalized == 'pharmacist.amina@comfortcare.ng' ||
        normalized == 'pharm@comfortcare.ng' ||
        normalized == 'clinic@cedarcrest.ng' ||
        normalized == 'wholesale@comfortcare.ng' ||
        role == UserRole.pharmacy) {
      return UserModel(
        id: 'user-abj-pharm-01',
        email: emailOrPhone.contains('@') ? emailOrPhone.trim() : 'pharmacy@comfortcare.ng',
        fullName: 'MedPlus Pharmacy Ltd',
        phoneNumber: '+234 803 555 7890',
        role: UserRole.pharmacy,
        facilityName: 'MedPlus Pharmacy & Store Life Camp',
        licenseNumber: 'PCN-R-90412',
        address: 'Comfort Mall, Life Camp, Abuja',
        loyaltyPoints: 2450,
        isVerified: true,
        approvalStatus: 'approved',
      );
    }

    // 3. Consultant Demo Account (Specialists: Doctor, Surgeon, Psychotherapist)
    if (normalized == 'consultant@comfortcare.ng' ||
        normalized == 'doctor@comfortcare.ng' ||
        normalized == 'dr.eze@comfortcare.ng' ||
        role == UserRole.consultant) {
      return UserModel(
        id: 'doc-chinedu-eze',
        email: emailOrPhone.contains('@') ? emailOrPhone.trim() : 'consultant@comfortcare.ng',
        fullName: 'Dr. Chinedu Eze',
        phoneNumber: '+234 803 112 4455',
        role: UserRole.consultant,
        specialty: 'Senior Consultant Physician',
        facilityName: 'National Hospital Abuja / ComfortCare Telehealth',
        licenseNumber: 'MDCN-61842-FMC',
        address: 'Central Medical District, Garki, Abuja',
        loyaltyPoints: 3400,
        isVerified: true,
        approvalStatus: 'approved',
        documentationName: 'MDCN_Consultant_Fellowship_2026.pdf',
      );
    }

    // 4. Regular User Demo Account (Looking for consultants & drugs)
    return UserModel(
      id: 'user-abj-patient-01',
      email: emailOrPhone.contains('@') ? emailOrPhone.trim() : 'user@comfortcare.ng',
      fullName: 'Amina Bello',
      phoneNumber: '+234 802 345 6789',
      role: UserRole.user,
      address: 'Plot 1044, Adetokunbo Ademola Crescent, Wuse 2, Abuja',
      loyaltyPoints: 320,
      isVerified: true,
      approvalStatus: 'approved',
    );
  }

  @override
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  }) async {
    final cleanEmailOrPhone = emailOrPhone.trim();

    if (password.length < 6) {
      throw const AuthException(message: 'Invalid password. Must be at least 6 characters.');
    }

    // Prioritize default demo accounts for instant, resilient offline/demo presentation:
    if (_isDemoAccount(cleanEmailOrPhone)) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _getDemoUser(emailOrPhone: cleanEmailOrPhone, role: role);
    }

    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final response = await client.auth.signInWithPassword(
          email: cleanEmailOrPhone,
          password: password,
        );
        final user = response.user;
        if (user == null) throw const AuthException(message: 'Authentication failed');

        final profileRes = await client
            .from(ApiConstants.profilesTable)
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profileRes != null) {
          return UserModel.fromJson(profileRes);
        }

        return UserModel(
          id: user.id,
          email: user.email ?? cleanEmailOrPhone,
          fullName: user.userMetadata?['full_name'] as String? ?? 'ComfortCare User',
          phoneNumber: user.phone ?? '',
          role: role,
        );
      } catch (e) {
        final errorMsg = e.toString();
        if (errorMsg.contains('invalid_credentials')) {
          throw const AuthException(
            message: 'Invalid email or password. For demo testing, select one of the Quick Demo Logins above.',
          );
        }
        throw AuthException(message: errorMsg);
      }
    }

    // Decoupled Demo Fallback
    await Future.delayed(const Duration(milliseconds: 400));
    return _getDemoUser(emailOrPhone: cleanEmailOrPhone, role: role);
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
    String? specialty,
    String? documentationName,
  }) async {
    final client = SupabaseService.client;
    final isConsultant = role == UserRole.consultant;
    final approvalStatus = isConsultant ? 'pending' : 'approved';

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
            'specialty': specialty,
            'documentation_name': documentationName,
            'approval_status': approvalStatus,
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
          specialty: specialty,
          documentationName: documentationName,
          approvalStatus: approvalStatus,
          isVerified: !isConsultant,
        );

        await client.from(ApiConstants.profilesTable).insert(userModel.toJson());
        return userModel;
      } catch (e) {
        throw AuthException(message: e.toString());
      }
    }

    // Decoupled Demo Fallback
    await Future.delayed(const Duration(milliseconds: 700));
    final newUserId = isConsultant
        ? 'doc-${fullName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-').replaceAll(RegExp(r'-+'), '-')}'
        : 'user-new-${_uuid.v4().substring(0, 8)}';

    final newUser = UserModel(
      id: newUserId,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: role,
      facilityName: facilityName,
      licenseNumber: licenseNumber,
      specialty: specialty,
      documentationName: documentationName ?? (isConsultant ? 'Medical_Practicing_License_2026.pdf' : null),
      approvalStatus: approvalStatus,
      isVerified: !isConsultant,
    );

    // If consultant, also register into the Consultants datasource as pending
    if (isConsultant) {
      final docModel = DoctorModel(
        id: newUserId,
        name: fullName.startsWith('Dr.') ? fullName : 'Dr. $fullName',
        title: specialty != null ? 'Consultant $specialty' : 'Specialist Consultant',
        specialty: specialty ?? 'General Medicine & Specialist Care',
        licenseNumber: licenseNumber ?? 'MDCN-PENDING-01',
        qualifications: 'MBBS, Specialist Board Certified',
        yearsOfExperience: 5,
        hospital: facilityName ?? 'ComfortCare Telehealth Network',
        consultationFee: 7000.0,
        rating: 5.0,
        reviewCount: 0,
        isAvailable: false,
        availabilityStatus: 'Pending Verification',
        approvalStatus: 'pending',
        documentationName: documentationName ?? 'Medical_Practicing_License_2026.pdf',
        specializations: [specialty ?? 'General Medicine', 'Telehealth Consultation'],
        avatarUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&q=80',
        bio: '$fullName is a licensed $specialty with $facilityName. Credentials submitted for review.',
        nextAvailableSlot: 'Pending Admin Approval',
      );
      await ConsultantsRemoteDataSourceImpl().registerDoctor(docModel);
    }

    return newUser;
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
            .from(ApiConstants.profilesTable)
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
