import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String roleBadge;
  final int totalOrders;
  final int activeRefills;
  final int pointsBalance;
  final int savedPrescriptions;
  final String primaryAddress;

  const UserProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.roleBadge,
    this.totalOrders = 18,
    this.activeRefills = 2,
    this.pointsBalance = 1450,
    this.savedPrescriptions = 4,
    this.primaryAddress = 'Plot 1044, Adetokunbo Ademola Crescent, Wuse 2, Abuja',
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        roleBadge,
        totalOrders,
        activeRefills,
        pointsBalance,
        savedPrescriptions,
        primaryAddress,
      ];
}
