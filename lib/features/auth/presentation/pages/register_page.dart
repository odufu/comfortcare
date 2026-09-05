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
import '../widgets/role_selector_tab.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _facilityController = TextEditingController();
  final _licenseController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _facilityController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _onRegister(BuildContext context, AuthState state) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            RegisterSubmitted(
              fullName: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              password: _passwordController.text,
              role: state.selectedRole,
              facilityName: state.selectedRole == UserRole.wholesale
                  ? _facilityController.text.trim()
                  : null,
              licenseNumber: state.selectedRole == UserRole.wholesale
                  ? _licenseController.text.trim()
                  : null,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              context.showSnackBar(
                'Registration successful! Welcome to ComfortCare.',
                isSuccess: true,
              );
              context.go('/dashboard');
            } else if (state.status == AuthStatus.error && state.errorMessage != null) {
              context.showSnackBar(state.errorMessage!, isError: true);
            }
          },
          builder: (context, state) {
            final isWholesale = state.selectedRole == UserRole.wholesale;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join ComfortCare Abuja',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Direct pharmaceutical procurement and prescription fulfillment.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    RoleSelectorTab(
                      selectedRole: state.selectedRole,
                      onRoleChanged: (role) {
                        context.read<AuthBloc>().add(SwitchRoleEvent(role));
                      },
                    ),
                    const SizedBox(height: 20),
                    CCTextField(
                      controller: _nameController,
                      label: isWholesale ? 'Lead Clinician / Officer Name' : 'Full Name',
                      hintText: isWholesale ? 'e.g. Dr. Farouk Al-Mansur' : 'e.g. Amina Bello',
                      prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
                      validator: (val) => Validators.validateRequired(val, 'Name'),
                    ),
                    const SizedBox(height: 16),
                    CCTextField(
                      controller: _emailController,
                      label: 'Official Email Address',
                      hintText: 'e.g. doctor@clinic.ng',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    CCTextField(
                      controller: _phoneController,
                      label: 'Phone Number (Abuja Delivery & SMS)',
                      hintText: 'e.g. 0803 265 1505',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icon(Icons.phone_outlined, color: colorScheme.primary),
                      validator: Validators.validatePhone,
                    ),
                    if (isWholesale) ...[
                      const SizedBox(height: 16),
                      CCTextField(
                        controller: _facilityController,
                        label: 'Hospital / Clinic / Pharmacy Name',
                        hintText: 'e.g. Maitama Clinic & Diagnostics',
                        prefixIcon: Icon(Icons.local_hospital_outlined, color: colorScheme.primary),
                        validator: (val) => Validators.validateRequired(val, 'Facility Name'),
                      ),
                      const SizedBox(height: 16),
                      CCTextField(
                        controller: _licenseController,
                        label: 'PCN / MDCN Registration Number',
                        hintText: 'e.g. PCN-W-89412',
                        prefixIcon: Icon(Icons.badge_outlined, color: colorScheme.primary),
                        validator: (val) => Validators.validateRequired(val, 'License Number'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    CCTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'Minimum 6 characters',
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
                    const SizedBox(height: 24),
                    CCButton(
                      label: isWholesale
                          ? 'Submit Wholesale Verification'
                          : 'Create Patient Account',
                      isLoading: state.isLoading,
                      onPressed: () => _onRegister(context, state),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already registered?',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            'Sign In',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
