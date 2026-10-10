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
  bool _isSignInContext = false;

  final List<Map<String, dynamic>> _slides = [
    {
      'badge': '25-35 Min Delivery',
      'badgeColor': 'secondary',
      'title': 'Abuja Express Pharmacy & Bulk Wholesale',
      'desc':
          'Direct from certified wholesale depots. Ultra-fast cold-chain transit to Life Camp, Maitama, Jabi, and Gwarinpa.',
      'icon': Icons.electric_moped,
      'metric': '2°C - 8°C Monitored',
      'subMetric': 'Life Camp Central Depot',
    },
    {
      'badge': 'Pharmacist Oversight',
      'badgeColor': 'primary',
      'title': 'AI Doctor & Clinical Assistant',
      'desc':
          'Instant clinical triage, smart interaction alerts, and one-tap access to licensed on-call Abuja clinical specialists & pharmacists.',
      'icon': Icons.monitor_heart,
      'metric': 'MDCN Specialists',
      'subMetric': 'Video & Audio Telehealth',
    },
    {
      'badge': 'Zero Out-of-Stock',
      'badgeColor': 'primary',
      'title': 'Prescription Upload & Smart Refills',
      'desc':
          'Upload doctor prescription slips. Enjoy automated refill schedules and authentic, cold-chain protected medicines.',
      'icon': Icons.medication_liquid,
      'metric': '100% Genuine Packs',
      'subMetric': 'NAFDAC & PCN Verified',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
    final isDark = context.isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 920;

                if (isDesktop) {
                  return _buildDesktopLayout(
                    context: context,
                    authState: authState,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    isDark: isDark,
                  );
                }

                return _buildMobileLayout(
                  context: context,
                  authState: authState,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  isDark: isDark,
                );
              },
            );
          },
        ),
      ),
    );
  }

  // =========================================================================
  // DESKTOP DUAL-PANE LAYOUT (>= 920px)
  // =========================================================================
  Widget _buildDesktopLayout({
    required BuildContext context,
    required AuthState authState,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool isDark,
  }) {
    final activeSlide = _slides[_currentPage];

    return Row(
      children: [
        // Left Pane: Enterprise Medical Brand Showcase & Features (Flex 6)
        Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF003837),
                        const Color(0xFF002228),
                        const Color(0xFF00161A),
                      ]
                    : [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.88),
                        const Color(0xFF003859),
                      ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Brand Lockup & Regulatory Badges
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(7),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.local_pharmacy,
                                size: 24,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppConstants.appName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                AppConstants.appTagline,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          CCChip(
                            label: 'NAFDAC Reg. Certified',
                            icon: const Icon(Icons.verified, size: 14, color: Color(0xFF10B981)),
                            variant: CCChipVariant.secondary,
                          ),
                          CCChip(
                            label: 'Life Camp, Abuja',
                            icon: const Icon(Icons.location_on, size: 14, color: Colors.white),
                            variant: CCChipVariant.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Center Showcase: Impactful Hero Copy & Feature Tabs
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ac_unit, size: 14, color: Color(0xFF67E8F9)),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Cold-Chain Telemetry Active: 3.8°C Central Depot',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Direct Pharmaceutical Supply &\nLive Telehealth Network',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.18,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Supplying verified NAFDAC medications, clinical wholesale cartons, and instant MDCN doctor video consultations across Abuja FCT with tamper-evident cold-chain tracking.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Interactive Slide Showcase Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                activeSlide['icon'] as IconData,
                                size: 24,
                                color: const Color(0xFF67E8F9),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeSlide['title'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${activeSlide['metric']} • ${activeSlide['subMetric']}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.75),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                activeSlide['badge'] as String,
                                style: const TextStyle(
                                  color: Color(0xFF6EE7B7),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          activeSlide['desc'] as String,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Slide Selector Pills (Desktop)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            for (int i = 0; i < _slides.length; i++) ...[
                              InkWell(
                                onTap: () {
                                  setState(() => _currentPage = i);
                                  if (_pageController.hasClients) {
                                    _pageController.animateToPage(
                                      i,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _currentPage == i
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Feature 0${i + 1}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _currentPage == i
                                          ? const Color(0xFF003837)
                                          : Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bottom Live Telemetry Badges
                  Row(
                    children: [
                      const Icon(Icons.location_pin, size: 14, color: Colors.white70),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${AppConstants.companyName} • ${AppConstants.depotAddress}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
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

        // Right Pane: Role Customization & Action Portal (Flex 5)
        Expanded(
          flex: 5,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 36),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Lockup
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.health_and_safety, color: colorScheme.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to ComfortCare',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Select your care profile to personalize dispensary access',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Role Segment Selector
                    RoleSelectorTab(
                      selectedRole: authState.selectedRole,
                      onRoleChanged: (role) {
                        context.read<AuthBloc>().add(SwitchRoleEvent(role));
                      },
                    ),
                    const SizedBox(height: 20),

                    // Dynamic Role Benefits Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colorScheme.surfaceContainerHigh),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                authState.selectedRole == UserRole.wholesale
                                    ? Icons.domain_outlined
                                    : Icons.person_outline,
                                color: colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authState.selectedRole == UserRole.wholesale
                                      ? 'Wholesale & Clinic Tier Benefits'
                                      : 'Individual Patient Tier Benefits',
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (authState.selectedRole == UserRole.wholesale) ...[
                            _buildBenefitItem(
                              context,
                              icon: Icons.inventory_2_outlined,
                              title: 'Wholesale Cartons & Packs',
                              subtitle: 'Bulk tier discounts up to 25% direct from manufacturers.',
                            ),
                            const SizedBox(height: 10),
                            _buildBenefitItem(
                              context,
                              icon: Icons.receipt_long_outlined,
                              title: 'PCN Compliant Invoicing',
                              subtitle: 'Official batch release certificates and VAT invoices.',
                            ),
                            const SizedBox(height: 10),
                            _buildBenefitItem(
                              context,
                              icon: Icons.local_shipping_outlined,
                              title: 'Priority Depot Van Dispatch',
                              subtitle: 'Scheduled cold-chain deliveries across Abuja clinics.',
                            ),
                          ] else ...[
                            _buildBenefitItem(
                              context,
                              icon: Icons.electric_moped_outlined,
                              title: '25-35 Min Doorstep Delivery',
                              subtitle: 'Express dispatch to Life Camp, Maitama, Jabi, Gwarinpa.',
                            ),
                            const SizedBox(height: 10),
                            _buildBenefitItem(
                              context,
                              icon: Icons.video_camera_front_outlined,
                              title: 'MDCN Doctor Telehealth',
                              subtitle: 'AI symptom triage and instant HD video/audio calls.',
                            ),
                            const SizedBox(height: 10),
                            _buildBenefitItem(
                              context,
                              icon: Icons.document_scanner_outlined,
                              title: '15-Min Prescription Review',
                              subtitle: 'Snap doctor prescription slips for PCN verification.',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Single-Click Auth Context Switcher (Create Account vs Sign In)
                    _buildContextSwitcher(context, isDark),

                    if (!_isSignInContext) ...[
                      // Primary Action: Register
                      CCButton(
                        label: authState.selectedRole == UserRole.wholesale
                            ? 'Create Clinic / Wholesale Account'
                            : 'Create Patient Account',
                        leadingIcon: Icon(
                          authState.selectedRole == UserRole.wholesale
                              ? Icons.domain_add
                              : Icons.person_add_alt_1,
                          size: 18,
                          color: colorScheme.onPrimary,
                        ),
                        onPressed: () => _completeOnboarding('/auth/register'),
                      ),
                      const SizedBox(height: 12),

                      // Secondary Action: Sign In
                      CCButton(
                        label: 'Sign In to Dispensary Hub',
                        variant: CCButtonVariant.outline,
                        leadingIcon: Icon(
                          Icons.login,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        onPressed: () => _completeOnboarding('/auth/login'),
                      ),
                    ] else ...[
                      // Primary Action: Sign In
                      CCButton(
                        label: 'Sign In to Dispensary Hub',
                        leadingIcon: Icon(
                          Icons.login,
                          size: 18,
                          color: colorScheme.onPrimary,
                        ),
                        onPressed: () => _completeOnboarding('/auth/login'),
                      ),
                      const SizedBox(height: 12),

                      // Secondary Action: Register
                      CCButton(
                        label: authState.selectedRole == UserRole.wholesale
                            ? 'Create Clinic / Wholesale Account'
                            : 'Create Patient Account',
                        variant: CCButtonVariant.outline,
                        leadingIcon: Icon(
                          authState.selectedRole == UserRole.wholesale
                              ? Icons.domain_add
                              : Icons.person_add_alt_1,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        onPressed: () => _completeOnboarding('/auth/register'),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Tertiary Action: Explore as Guest
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _completeOnboarding('/dashboard'),
                        icon: Icon(Icons.explore_outlined, size: 16, color: colorScheme.primary),
                        label: Text(
                          'Explore Pharmacy Catalog as Guest',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Security & Privacy Footer Note
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined, size: 13, color: colorScheme.outline),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'PCN Regulated • NAFDAC Certified • End-to-End Encrypted',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 10.5,
                              color: colorScheme.outline,
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
        ),
      ],
    );
  }

  // =========================================================================
  // MOBILE / TABLET COMPACT LAYOUT (< 920px)
  // =========================================================================
  Widget _buildMobileLayout({
    required BuildContext context,
    required AuthState authState,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool isDark,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Top Credential Strip
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
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
              const SizedBox(height: 14),

              // Brand Identity
              Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
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
                        size: 32,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
              const SizedBox(height: 14),

              // Role Segment Selector
              RoleSelectorTab(
                selectedRole: authState.selectedRole,
                onRoleChanged: (role) {
                  context.read<AuthBloc>().add(SwitchRoleEvent(role));
                },
              ),
              const SizedBox(height: 14),

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
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorScheme.surfaceContainerHigh),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
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
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  slide['icon'] as IconData,
                                  size: 24,
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
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slide['desc'] as String,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline, size: 12, color: colorScheme.secondary),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${slide['metric']} • ${slide['subMetric']}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

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
              const SizedBox(height: 14),

              // Single-Click Auth Context Switcher (Create Account vs Sign In)
              _buildContextSwitcher(context, isDark),

              if (!_isSignInContext) ...[
                // Primary Action: Register
                CCButton(
                  label: authState.selectedRole == UserRole.wholesale
                      ? 'Create Clinic / Wholesale Account'
                      : 'Create Patient Account',
                  onPressed: () => _completeOnboarding('/auth/register'),
                ),
                const SizedBox(height: 10),
                // Secondary Action: Sign In
                CCButton(
                  label: 'Sign In to Dispensary Hub',
                  variant: CCButtonVariant.outline,
                  onPressed: () => _completeOnboarding('/auth/login'),
                ),
              ] else ...[
                // Primary Action: Sign In
                CCButton(
                  label: 'Sign In to Dispensary Hub',
                  onPressed: () => _completeOnboarding('/auth/login'),
                ),
                const SizedBox(height: 10),
                // Secondary Action: Register
                CCButton(
                  label: authState.selectedRole == UserRole.wholesale
                      ? 'Create Clinic / Wholesale Account'
                      : 'Create Patient Account',
                  variant: CCButtonVariant.outline,
                  onPressed: () => _completeOnboarding('/auth/register'),
                ),
              ],
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContextSwitcher(BuildContext context, bool isDark) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isSignInContext) {
                  setState(() => _isSignInContext = false);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !_isSignInContext
                      ? colorScheme.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isSignInContext
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_add_outlined,
                      size: 14,
                      color: !_isSignInContext ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Create Account',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: !_isSignInContext ? FontWeight.w800 : FontWeight.w600,
                          color: !_isSignInContext ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isSignInContext) {
                  setState(() => _isSignInContext = true);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isSignInContext
                      ? colorScheme.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isSignInContext
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.login_outlined,
                      size: 14,
                      color: _isSignInContext ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Sign In',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: _isSignInContext ? FontWeight.w800 : FontWeight.w600,
                          color: _isSignInContext ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
