import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/cc_button.dart';
import '../../../../core/widgets/cc_text_field.dart';
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

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              RoleSelectorTab(
                selectedRole: state.selectedRole,
                onRoleChanged: (role) {
                  context.read<AuthBloc>().add(SwitchRoleEvent(role));
                },
              ),
              const SizedBox(height: 20),
              CCTextField(
                controller: _identifierController,
                label: 'Email or Phone Number',
                hintText: 'e.g. 0803 123 4567 or doctor@clinic.ng',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
                validator: (val) => Validators.validateRequired(val, 'Email or Phone'),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/auth/forgot-password'),
                  child: Text(
                    'Forgot Password?',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CCButton(
                label: 'Sign In to Dispensary Hub',
                isLoading: state.isLoading,
                onPressed: () => _onLogin(context, state),
              ),
            ],
          ),
        );
      },
    );
  }
}
