import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthRepository _authRepository;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _authRepository = authRepository,
        super(const AuthState()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SwitchRoleEvent>(_onSwitchRole);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          selectedRole: user.role,
        ));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  void _onSwitchRole(SwitchRoleEvent event, Emitter<AuthState> emit) {
    emit(state.copyWith(selectedRole: event.role));
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final user = await _loginUseCase(
        emailOrPhone: event.emailOrPhone,
        password: event.password,
        role: event.role,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        selectedRole: user.role,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final user = await _authRepository.register(
        fullName: event.fullName,
        email: event.email,
        phoneNumber: event.phoneNumber,
        password: event.password,
        role: event.role,
        facilityName: event.facilityName,
        licenseNumber: event.licenseNumber,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        selectedRole: user.role,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _logoutUseCase();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (_) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onForgotPasswordSubmitted(
      ForgotPasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _authRepository.sendPasswordReset(event.emailOrPhone);
      emit(state.copyWith(status: AuthStatus.resetSent));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }
}
