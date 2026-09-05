import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  resetSent,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final UserRole selectedRole;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.selectedRole = UserRole.patient,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    UserRole? selectedRole,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      selectedRole: selectedRole ?? this.selectedRole,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, selectedRole, errorMessage];
}
