import 'package:equatable/equatable.dart';

/// The 4 primary system roles in ComfortCare:
/// - [user]: Individuals looking for consultants and ordering medications.
/// - [consultant]: Specialists (doctors, surgeons, psychotherapists, physiotherapists).
/// - [pharmacy]: Pharmacy partner companies retailing drugs to users and purchasing wholesale.
/// - [admin]: Platform administrators managing operations, reviews, and consultant approvals.
enum UserRole {
  user,
  consultant,
  pharmacy,
  admin;

  // Backward-compatible aliases for existing tests and legacy references
  static const UserRole patient = UserRole.user;
  static const UserRole doctor = UserRole.consultant;
  static const UserRole wholesale = UserRole.pharmacy;
  static const UserRole pharmacist = UserRole.pharmacy;

  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'User';
      case UserRole.consultant:
        return 'Consultant';
      case UserRole.pharmacy:
        return 'Pharmacy';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get description {
    switch (this) {
      case UserRole.user:
        return 'Search medicines, order drugs & consult specialists';
      case UserRole.consultant:
        return 'Doctor, surgeon or therapist providing teleconsultations';
      case UserRole.pharmacy:
        return 'Pharmacy company selling retail & buying wholesale';
      case UserRole.admin:
        return 'Operations, verification reviews & platform governance';
    }
  }
}

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final UserRole role;
  final String? licenseNumber;
  final String? facilityName;
  final String? address;
  final int loyaltyPoints;
  final bool isVerified;
  final String? specialty;
  final String? documentationName;
  final String approvalStatus; // 'approved', 'pending', 'rejected'

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    this.licenseNumber,
    this.facilityName,
    this.address,
    this.loyaltyPoints = 0,
    this.isVerified = false,
    this.specialty,
    this.documentationName,
    this.approvalStatus = 'approved',
  });

  bool get isApproved => approvalStatus == 'approved';
  bool get isPendingApproval => approvalStatus == 'pending';

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    UserRole? role,
    String? licenseNumber,
    String? facilityName,
    String? address,
    int? loyaltyPoints,
    bool? isVerified,
    String? specialty,
    String? documentationName,
    String? approvalStatus,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      facilityName: facilityName ?? this.facilityName,
      address: address ?? this.address,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      isVerified: isVerified ?? this.isVerified,
      specialty: specialty ?? this.specialty,
      documentationName: documentationName ?? this.documentationName,
      approvalStatus: approvalStatus ?? this.approvalStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phoneNumber,
        role,
        licenseNumber,
        facilityName,
        address,
        loyaltyPoints,
        isVerified,
        specialty,
        documentationName,
        approvalStatus,
      ];
}
