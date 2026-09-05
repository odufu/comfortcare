import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/widgets/cc_button.dart';
import '../../../../core/widgets/cc_chip.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/role_selector_tab.dart';

class OnboardingPage extends StatefulWidget {
  final LocalStorageService localStorageService;

  const OnboardingPage({super.key, required this.localStorageService});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'badge': '25-35 Min Delivery',
      'badgeColor': 'secondary',
      'title': 'Abuja Express Pharmacy & Bulk Wholesale',
      'desc':
          'Direct from certified wholesale depots. Ultra-fast cold-chain transit to Life Camp, Maitama, Jabi, and Gwarinpa.',
      'icon': Icons.electric_moped,
    },
    {
      'badge': 'Pharmacist Oversight',
      'badgeColor': 'primary',
      'title': 'AI Doctor & Clinical Assistant',
      'desc':
          'Instant clinical triage, smart interaction alerts, and one-tap access to licensed on-call Abuja clinical pharmacists.',
      'icon': Icons.monitor_heart,
    },
    {
      'badge': 'Zero Out-of-Stock',
      'badgeColor': 'primary',
      'title': 'Prescription Upload & Smart Refills',
      'desc':
          'Upload doctor prescription slips. Enjoy automated refill schedules and authentic, cold-chain protected medicines.',
      'icon': Icons.medication_liquid,
    },
  ];

  Future<void> _completeOnboarding(String route) async {
    await widget.localStorageService.setOnboardingCompleted();
    if (mounted) {
      context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // Top Credential Strip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CCChip(
                        label: 'NAFDAC Reg. Certified',
                        icon: Icon(Icons.verified, size: 14, color: colorScheme.secondary),
                        variant: CCChipVariant.secondary,
                      ),
                      CCChip(
                        label: 'Life Camp, Abuja',
                        icon: Icon(Icons.location_on, size: 14, color: colorScheme.primary),
                        variant: CCChipVariant.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Brand Identity
                  Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surfaceContainerLowest,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.local_pharmacy,
                            size: 34,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppConstants.appName,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        AppConstants.appTagline,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${AppConstants.companyName} • ${AppConstants.depotAddress}',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Role Segment Selector
                  RoleSelectorTab(
                    selectedRole: authState.selectedRole,
                    onRoleChanged: (role) {
                      context.read<AuthBloc>().add(SwitchRoleEvent(role));
                    },
                  ),
                  const SizedBox(height: 16),

                  // Interactive Carousel
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final slide = _slides[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colorScheme.surfaceContainerHigh),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      slide['icon'] as IconData,
                                      size: 26,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  CCChip(
                                    label: slide['badge'] as String,
                                    variant: slide['badgeColor'] == 'secondary'
                                        ? CCChipVariant.secondary
                                        : CCChipVariant.primary,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                slide['title'] as String,
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                slide['desc'] as String,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Carousel Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == i ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  CCButton(
                    label: authState.selectedRole == UserRole.wholesale
                        ? 'Create Clinic / Wholesale Account'
                        : 'Create Patient Account',
                    onPressed: () => _completeOnboarding('/auth/register'),
                  ),
                  const SizedBox(height: 10),
                  CCButton(
                    label: 'Sign In to Dispensary Hub',
                    variant: CCButtonVariant.outline,
                    onPressed: () => _completeOnboarding('/auth/login'),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
