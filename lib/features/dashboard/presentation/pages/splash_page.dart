import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class SplashPage extends StatefulWidget {
  final LocalStorageService localStorageService;

  const SplashPage({super.key, required this.localStorageService});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    context.read<AuthBloc>().add(CheckAuthStatus());

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        final isOnboarded = widget.localStorageService.isOnboardingCompleted();
        final authState = context.read<AuthBloc>().state;

        if (authState.isAuthenticated) {
          context.go('/dashboard');
        } else if (isOnboarded) {
          context.go('/auth/login');
        } else {
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Glow Orbs
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Regulatory Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified, size: 14, color: colorScheme.secondary),
                            const SizedBox(width: 6),
                            Text(
                              AppConstants.nafdacBadge.toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_pharmacy, size: 14, color: colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              AppConstants.pcnBadge.toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Center Hero: Layered Bio-Ring Emblem
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surfaceContainerLowest,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.18),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.local_pharmacy,
                            size: 60,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppConstants.appName,
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConstants.appTagline.toUpperCase(),
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppConstants.companyName,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        AppConstants.metroRegion,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  // Bottom Telemetry & Progress
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.surfaceContainerHigh),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.sync,
                                      size: 16,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Abuja Logistics & Cold-Chain Hub',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                AnimatedBuilder(
                                  animation: _progressAnimation,
                                  builder: (context, _) {
                                    final pct = (_progressAnimation.value * 100).toInt();
                                    return Text(
                                      '$pct%',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, _) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _progressAnimation.value,
                                    minHeight: 6,
                                    backgroundColor: colorScheme.surfaceContainerHigh,
                                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.ac_unit, size: 12, color: colorScheme.secondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppConstants.coldChainStatus,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.outline,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Secured Stream',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.secondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront, size: 14, color: colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            AppConstants.depotAddress,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
