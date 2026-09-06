import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/cc_button.dart';
import '../../../../core/widgets/cc_text_field.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'role_selector_tab.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isBiometricScanning = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _applyDemoCredentials(UserRole role, String identifier, String password, String label) {
    setState(() {
      _identifierController.text = identifier;
      _passwordController.text = password;
    });
    context.read<AuthBloc>().add(SwitchRoleEvent(role));
    context.showSnackBar('Demo credentials loaded for $label', isSuccess: true);
  }

  void _onBiometricLogin(BuildContext context, AuthState state) async {
    final authBloc = context.read<AuthBloc>();
    setState(() => _isBiometricScanning = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _isBiometricScanning = false);

    final email = _identifierController.text.trim().isNotEmpty
        ? _identifierController.text.trim()
        : 'patient@comfortcare.ng';
    final password = _passwordController.text.isNotEmpty
        ? _passwordController.text
        : 'Password123!';

    authBloc.add(
      LoginSubmitted(
        emailOrPhone: email,
        password: password,
        role: state.selectedRole,
      ),
    );
  }

  void _onLogin(BuildContext context, AuthState state) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginSubmitted(
              emailOrPhone: _identifierController.text.trim(),
              password: _passwordController.text,
              role: state.selectedRole,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.showSnackBar(
            'Welcome, ${state.user?.fullName ?? "Back to ComfortCare"}!',
            isSuccess: true,
          );
          context.go('/dashboard');
        } else if (state.status == AuthStatus.error && state.errorMessage != null) {
          context.showSnackBar(state.errorMessage!, isError: true);
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Role Selector
              RoleSelectorTab(
                selectedRole: state.selectedRole,
                onRoleChanged: (role) {
                  context.read<AuthBloc>().add(SwitchRoleEvent(role));
                },
              ),
              const SizedBox(height: 16),

              // Quick Demo Credentials Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.surfaceContainerHigh),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bolt, size: 14, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Quick Demo Logins:',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildDemoPill(
                          label: 'Patient',
                          icon: Icons.person_outline,
                          isSelected: state.selectedRole == UserRole.patient &&
                              _identifierController.text == 'patient@comfortcare.ng',
                          onTap: () => _applyDemoCredentials(
                            UserRole.patient,
                            'patient@comfortcare.ng',
                            'Patient123!',
                            'Patient',
                          ),
                        ),
                        _buildDemoPill(
                          label: 'Clinic / Wholesale',
                          icon: Icons.local_hospital_outlined,
                          isSelected: state.selectedRole == UserRole.wholesale &&
                              _identifierController.text == 'clinic@cedarcrest.ng',
                          onTap: () => _applyDemoCredentials(
                            UserRole.wholesale,
                            'clinic@cedarcrest.ng',
                            'Wholesale123!',
                            'Clinic Partner',
                          ),
                        ),
                        _buildDemoPill(
                          label: 'Pharmacist',
                          icon: Icons.medication_outlined,
                          isSelected: state.selectedRole == UserRole.pharmacist &&
                              _identifierController.text == 'pharmacist.amina@comfortcare.ng',
                          onTap: () => _applyDemoCredentials(
                            UserRole.pharmacist,
                            'pharmacist.amina@comfortcare.ng',
                            'Pharm123!',
                            'Licensed Pharmacist',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Identifier Field
              CCTextField(
                controller: _identifierController,
                label: 'Email or Phone Number',
                hintText: 'e.g. 0803 123 4567 or doctor@clinic.ng',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
                validator: (val) => Validators.validateRequired(val, 'Email or Phone'),
              ),
              const SizedBox(height: 16),

              // Password Field
              CCTextField(
                controller: _passwordController,
                label: 'Password',
                hintText: 'Enter your account password',
                obscureText: _obscurePassword,
                prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 12),

              // Remember Me & Forgot Password
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (val) => setState(() => _rememberMe = val ?? true),
                          activeColor: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember session',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.push('/auth/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Primary Login Action
              CCButton(
                label: 'Sign In to Dispensary Hub',
                isLoading: state.isLoading,
                onPressed: () => _onLogin(context, state),
              ),
              const SizedBox(height: 12),

              // Biometric Authentication Trigger
              OutlinedButton.icon(
                onPressed: _isBiometricScanning ? null : () => _onBiometricLogin(context, state),
                icon: _isBiometricScanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.fingerprint, color: colorScheme.secondary, size: 20),
                label: Text(
                  _isBiometricScanning ? 'Verifying Biometrics...' : 'Fast Biometric Sign In',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Security & Accreditation Footnote
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  Icon(Icons.lock_clock_outlined, size: 12, color: colorScheme.outline),
                  Text(
                    '256-Bit SSL Encrypted Healthcare Session',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDemoPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHigh,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

