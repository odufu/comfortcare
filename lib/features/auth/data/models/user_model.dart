import 'dart:convert';
import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.phoneNumber,
    required super.role,
    super.licenseNumber,
    super.facilityName,
    super.address,
    super.loyaltyPoints = 0,
    super.isVerified = false,
    super.specialty,
    super.documentationName,
    super.approvalStatus = 'approved',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? json['phoneNumber'] as String? ?? '',
      role: _roleFromString(json['role'] as String?),
      licenseNumber: json['license_number'] as String? ?? json['licenseNumber'] as String?,
      facilityName: json['facility_name'] as String? ?? json['facilityName'] as String?,
      address: json['address'] as String?,
      loyaltyPoints: json['loyalty_points'] as int? ?? json['loyaltyPoints'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? json['isVerified'] as bool? ?? false,
      specialty: json['specialty'] as String?,
      documentationName: json['documentation_name'] as String? ?? json['documentationName'] as String?,
      approvalStatus: json['approval_status'] as String? ?? json['approvalStatus'] as String? ?? 'approved',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role.name,
      'license_number': licenseNumber,
      'facility_name': facilityName,
      'address': address,
      'loyalty_points': loyaltyPoints,
      'is_verified': isVerified,
      'specialty': specialty,
      'documentation_name': documentationName,
      'approval_status': approvalStatus,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String jsonStr) =>
      UserModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);

  static UserRole _roleFromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'consultant':
      case 'doctor':
        return UserRole.consultant;
      case 'pharmacy':
      case 'wholesale':
      case 'pharmacist':
        return UserRole.pharmacy;
      case 'admin':
        return UserRole.admin;
      case 'user':
      case 'patient':
      default:
        return UserRole.user;
    }
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      role: entity.role,
      licenseNumber: entity.licenseNumber,
      facilityName: entity.facilityName,
      address: entity.address,
      loyaltyPoints: entity.loyaltyPoints,
      isVerified: entity.isVerified,
      specialty: entity.specialty,
      documentationName: entity.documentationName,
      approvalStatus: entity.approvalStatus,
    );
  }
}
