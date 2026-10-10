import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_event.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../clinical/presentation/bloc/clinical_bloc.dart';
import '../../../clinical/presentation/bloc/clinical_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class AccountProfileSettingsPage extends StatefulWidget {
  const AccountProfileSettingsPage({super.key});

  @override
  State<AccountProfileSettingsPage> createState() => _AccountProfileSettingsPageState();
}

class _AccountProfileSettingsPageState extends State<AccountProfileSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final themeState = context.watch<ThemeBloc>().state;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        final authUser = context.watch<AuthBloc>().state.user;
        final isDarkMode = context.isDarkMode;

        final displayName = authUser?.fullName.isNotEmpty == true
            ? authUser!.fullName
            : (profile?.fullName ?? 'ComfortCare Patient');
        final displayPhone = authUser?.phoneNumber.isNotEmpty == true
            ? authUser!.phoneNumber
            : (profile?.phone ?? '+234 803 265 1505');

        final String roleBadgeText;
        final IconData roleIcon;
        final String bannerNotice;
        final String bannerBadge;

        if (authUser?.role == UserRole.consultant) {
          roleBadgeText = 'Licensed Consultant (${authUser?.specialty ?? "Medical Specialist"})';
          roleIcon = Icons.medical_services;
          bannerNotice = 'On-Call Telehealth Active across Abuja';
          bannerBadge = 'PROVIDER';
        } else if (authUser?.role == UserRole.pharmacy) {
          roleBadgeText = 'Registered Community Pharmacy Partner';
          roleIcon = Icons.local_pharmacy;
          bannerNotice = 'Wholesale Bulk Ordering & Inventory Active';
          bannerBadge = 'PHARMACY';
        } else if (authUser?.role == UserRole.admin) {
          roleBadgeText = 'System Administrator & Governance';
          roleIcon = Icons.admin_panel_settings;
          bannerNotice = 'Full Administrative & Vetting Privileges';
          bannerBadge = 'ADMIN';
        } else {
          roleBadgeText = 'Verified Patient & Healthcare Consumer';
          roleIcon = Icons.person;
          bannerNotice = 'Cold-Chain Telemetry & Express Dispatch Active';
          bannerBadge = 'VERIFIED';
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Account & Settings'),
            actions: [
              IconButton(
                icon: const Icon(Icons.support_agent),
                onPressed: () {
                  context.showSnackBar('ComfortCare Abuja Customer Care: 0800 266 3678');
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Ambient Top Profile Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Icon(Icons.person, size: 36, color: colorScheme.primary),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$displayPhone • Abuja',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Role Tier Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(roleIcon, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                roleBadgeText,
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Status notice banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.verified_user, size: 14, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      bannerNotice,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.secondary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                bannerBadge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Metrics Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.6,
                  children: [
                    _buildMetricCard(
                      context,
                      title: 'ORDERS',
                      value: '${profile?.totalOrders ?? 18}',
                      sub: 'Abuja hub completed',
                      icon: Icons.receipt_long,
                      color: colorScheme.primary,
                    ),
                    _buildMetricCard(
                      context,
                      title: 'ACTIVE REFILLS',
                      value: '${profile?.activeRefills ?? 2}',
                      sub: 'Automated schedule',
                      icon: Icons.event_repeat,
                      color: colorScheme.tertiary,
                    ),
                    _buildMetricCard(
                      context,
                      title: 'POINTS BALANCE',
                      value: '${profile?.pointsBalance ?? 1450}',
                      sub: '₦1,450 store credit',
                      icon: Icons.toll,
                      color: colorScheme.secondary,
                    ),
                    _buildMetricCard(
                      context,
                      title: 'PRESCRIPTIONS',
                      value: '${profile?.savedPrescriptions ?? 4}',
                      sub: 'Verified dossiers',
                      icon: Icons.medical_information,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Settings & Preferences List
                Text(
                  'Preferences & Security',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // Dark Mode Switch Tile
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.surfaceContainerHigh),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: isDarkMode,
                        activeThumbColor: colorScheme.primary,
                        secondary: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Dark Appearance',
                          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          themeState.themeMode == ThemeMode.system
                              ? (isDarkMode ? 'System Default (Dark)' : 'System Default (Light)')
                              : (isDarkMode ? 'Night Mode Active' : 'Clinical Light Canvas'),
                          style: textTheme.bodySmall,
                        ),
                        onChanged: (val) {
                          context.read<ThemeBloc>().add(
                                ChangeThemeMode(val ? ThemeMode.dark : ThemeMode.light),
                              );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.location_on, color: colorScheme.primary, size: 20),
                        ),
                        title: Text(
                          'Saved Delivery Destinations',
                          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          'Wuse 2, Maitama, Life Camp',
                          style: textTheme.bodySmall,
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () {
                          context.showSnackBar('3 Abuja delivery addresses saved.');
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.monitor_heart, color: colorScheme.secondary, size: 20),
                        ),
                        title: Text(
                          'Health Vitals Monitor',
                          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          'BP, Pulse, Blood Glucose Telemetry',
                          style: textTheme.bodySmall,
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => context.push('/vitals'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.smart_toy, color: colorScheme.primary, size: 20),
                        ),
                        title: Text(
                          'ComfortCare AI Doctor Consult',
                          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          'PCN Regulated clinical triage',
                          style: textTheme.bodySmall,
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => context.push('/ai-consult'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.medical_services_outlined, color: colorScheme.primary, size: 20),
                        ),
                        title: Text(
                          'Medical Consultants & Doctors',
                          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          'Abuja specialists, patient ratings & telehealth booking',
                          style: textTheme.bodySmall,
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => context.push('/consultants'),
                      ),
                      if (authUser?.role == UserRole.consultant) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.video_camera_front_outlined, color: Color(0xFF0D9488), size: 20),
                          ),
                          title: Text(
                            'Doctor Clinical Console',
                            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            'On-call status, live patient queue & telehealth calls',
                            style: textTheme.bodySmall,
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Provider',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D9488),
                              ),
                            ),
                          ),
                          onTap: () => context.push('/doctor/console'),
                        ),
                      ] else if (authUser?.role == UserRole.pharmacy) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.local_pharmacy, color: colorScheme.secondary, size: 20),
                          ),
                          title: Text(
                            'Pharmacy Portal & Wholesale Console',
                            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            'Decentralized fulfillment, local inventory & cartons',
                            style: textTheme.bodySmall,
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Pharmacy',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.secondary,
                              ),
                            ),
                          ),
                          onTap: () => context.push('/pharmacy/console'),
                        ),
                      ] else if (authUser?.role == UserRole.admin) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.admin_panel_settings, color: colorScheme.primary, size: 20),
                          ),
                          title: Text(
                            'Admin Management Console',
                            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            'Vetting consultants, product catalog & governance',
                            style: textTheme.bodySmall,
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Admin',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          onTap: () => context.push('/admin/console'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Out Button
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.surfaceContainerHigh),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.logout, color: colorScheme.error, size: 20),
                    ),
                    title: Text(
                      'Sign Out',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.error,
                      ),
                    ),
                    subtitle: Text(
                      'Sign out of ComfortCare profile',
                      style: textTheme.bodySmall,
                    ),
                    onTap: () {
                      context.read<ClinicalBloc>().add(ClearConsultationSessionEvent());
                      context.read<AuthBloc>().add(LogoutRequested());
                      context.go('/auth/login');
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // Central Depot Footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        AppConstants.companyName,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.outline,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Central Depot: ${AppConstants.depotAddress}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                sub,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: colorScheme.outline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
