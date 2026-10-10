import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/cc_button.dart';
import '../../../../core/widgets/cc_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'default_account_selector.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  DefaultAccountProfile? _selectedAccount = DefaultAccountSelector.defaultAccounts.first;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Auto-load default account credentials on startup for instant quick access
    if (_selectedAccount != null) {
      _identifierController.text = _selectedAccount!.email;
      _passwordController.text = _selectedAccount!.password;
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectDefaultAccount(DefaultAccountProfile account) {
    setState(() {
      _selectedAccount = account;
      _identifierController.text = account.email;
      _passwordController.text = account.password;
    });
    context.read<AuthBloc>().add(SwitchRoleEvent(account.role));
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

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.showSnackBar(
            'Welcome, ${state.user?.fullName ?? "Back to ComfortCare"}!',
            isSuccess: true,
          );
          try {
            if (state.user?.role == UserRole.admin) {
              context.go('/admin/console');
            } else if (state.user?.role == UserRole.consultant) {
              context.go('/doctor/console');
            } else if (state.user?.role == UserRole.pharmacy) {
              context.go('/pharmacy/console');
            } else {
              context.go('/dashboard');
            }
          } catch (_) {}
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
              // 1. Dropdown of the main roles default accounts
              DefaultAccountSelector(
                selectedAccount: _selectedAccount,
                onAccountSelected: _selectDefaultAccount,
              ),
              const SizedBox(height: 16),

              // 2. User (Email / Phone) field
              CCTextField(
                controller: _identifierController,
                label: 'Email or Phone Number',
                hintText: 'e.g. user@comfortcare.ng',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
                validator: (val) => Validators.validateRequired(val, 'Email or Phone'),
              ),
              const SizedBox(height: 14),

              // 3. Password field
              CCTextField(
                controller: _passwordController,
                label: 'Password',
                hintText: 'Enter password',
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
              const SizedBox(height: 20),

              // 4. Primary CTA Button
              CCButton(
                label: 'Sign In',
                isLoading: state.isLoading,
                leadingIcon: Icon(Icons.login, size: 18, color: colorScheme.onPrimary),
                onPressed: () => _onLogin(context, state),
              ),
            ],
          ),
        );
      },
    );
  }
}
