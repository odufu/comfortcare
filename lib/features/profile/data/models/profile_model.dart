import '../../domain/entities/user_profile.dart';

class ProfileModel extends UserProfileEntity {
  const ProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.roleBadge,
    super.totalOrders = 18,
    super.activeRefills = 2,
    super.pointsBalance = 1450,
    super.savedPrescriptions = 4,
    super.primaryAddress = 'Plot 1044, Adetokunbo Ademola Crescent, Wuse 2, Abuja',
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? 'Dr. Farouk Al-Mansur',
      email: json['email'] as String? ?? 'doctor@clinic.ng',
      phone: json['phone'] as String? ?? '+234 803 265 1505',
      roleBadge: json['role_badge'] as String? ?? 'Verified Clinic & Retail Buyer (Tier 2 Wholesale)',
      totalOrders: json['total_orders'] as int? ?? 18,
      activeRefills: json['active_refills'] as int? ?? 2,
      pointsBalance: json['points_balance'] as int? ?? 1450,
      savedPrescriptions: json['saved_prescriptions'] as int? ?? 4,
      primaryAddress: json['primary_address'] as String? ??
          'Plot 1044, Adetokunbo Ademola Crescent, Wuse 2, Abuja',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role_badge': roleBadge,
      'total_orders': totalOrders,
      'active_refills': activeRefills,
      'points_balance': pointsBalance,
      'saved_prescriptions': savedPrescriptions,
      'primary_address': primaryAddress,
    };
  }
}
