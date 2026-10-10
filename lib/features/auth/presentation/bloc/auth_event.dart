import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class SwitchRoleEvent extends AuthEvent {
  final UserRole role;

  const SwitchRoleEvent(this.role);

  @override
  List<Object?> get props => [role];
}

class LoginSubmitted extends AuthEvent {
  final String emailOrPhone;
  final String password;
  final UserRole role;

  const LoginSubmitted({
    required this.emailOrPhone,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [emailOrPhone, password, role];
}

class RegisterSubmitted extends AuthEvent {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final UserRole role;
  final String? facilityName;
  final String? licenseNumber;
  final String? specialty;
  final String? documentationName;

  const RegisterSubmitted({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.role,
    this.facilityName,
    this.licenseNumber,
    this.specialty,
    this.documentationName,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        phoneNumber,
        password,
        role,
        facilityName,
        licenseNumber,
        specialty,
        documentationName,
      ];
}

class LogoutRequested extends AuthEvent {}

class ForgotPasswordSubmitted extends AuthEvent {
  final String emailOrPhone;

  const ForgotPasswordSubmitted(this.emailOrPhone);

  @override
  List<Object?> get props => [emailOrPhone];
}
