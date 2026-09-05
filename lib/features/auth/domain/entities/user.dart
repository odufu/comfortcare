import 'package:equatable/equatable.dart';

enum UserRole {
  patient,
  wholesale,
  pharmacist,
  admin,
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
  });

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
      ];
}
