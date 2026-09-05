import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/cc_chip.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Regulatory Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CCChip(
                      label: AppConstants.nafdacBadge,
                      icon: Icon(Icons.verified, size: 14, color: colorScheme.secondary),
                      variant: CCChipVariant.secondary,
                    ),
                    const SizedBox(width: 8),
                    CCChip(
                      label: 'Life Camp Hub',
                      icon: Icon(Icons.location_on, size: 14, color: colorScheme.primary),
                      variant: CCChipVariant.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Brand Emblem
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.local_pharmacy,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title & Subtitle
                Text(
                  AppConstants.appName,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appTagline,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppConstants.depotAddress,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.surfaceContainerHigh),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const LoginForm(),
                ),
                const SizedBox(height: 24),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    TextButton(
                      onPressed: () => context.push('/auth/register'),
                      child: Text(
                        'Create Account',
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
        ),
      ),
    );
  }
}
