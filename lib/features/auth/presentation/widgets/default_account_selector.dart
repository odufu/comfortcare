import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/user.dart';

class DefaultAccountProfile {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String roleBadge;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const DefaultAccountProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.roleBadge,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });
}

class DefaultAccountSelector extends StatelessWidget {
  final DefaultAccountProfile? selectedAccount;
  final ValueChanged<DefaultAccountProfile> onAccountSelected;
  final VoidCallback? onDirectSignIn;

  const DefaultAccountSelector({
    super.key,
    required this.selectedAccount,
    required this.onAccountSelected,
    this.onDirectSignIn,
  });

  static const List<DefaultAccountProfile> defaultAccounts = [
    DefaultAccountProfile(
      id: 'patient-default',
      name: 'Amina Bello',
      email: 'user@comfortcare.ng',
      password: 'User123!',
      role: UserRole.user,
      roleBadge: 'Patient',
      subtitle: 'Looking for consultants & drugs',
      icon: Icons.person_outline,
      accentColor: Color(0xFF007A78),
    ),
    DefaultAccountProfile(
      id: 'consultant-default',
      name: 'Dr. Chinedu Eze',
      email: 'consultant@comfortcare.ng',
      password: 'Consultant123!',
      role: UserRole.consultant,
      roleBadge: 'Consultant',
      subtitle: 'Doctor, Surgeon, Psychotherapist...',
      icon: Icons.medical_services_outlined,
      accentColor: Color(0xFF0D9488),
    ),
    DefaultAccountProfile(
      id: 'pharmacy-default',
      name: 'MedPlus Pharmacy Ltd',
      email: 'pharmacy@comfortcare.ng',
      password: 'Pharmacy123!',
      role: UserRole.pharmacy,
      roleBadge: 'Pharmacist',
      subtitle: 'Retail drug sales & wholesale procurement',
      icon: Icons.local_pharmacy_outlined,
      accentColor: Color(0xFF10B981),
    ),
    DefaultAccountProfile(
      id: 'admin-default',
      name: 'ComfortCare Admin',
      email: 'admin@comfortcare.ng',
      password: 'Admin123!',
      role: UserRole.admin,
      roleBadge: 'Admin',
      subtitle: 'Full operations & consultant approvals',
      icon: Icons.admin_panel_settings_outlined,
      accentColor: Color(0xFF8B5CF6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final currentAccount = selectedAccount ?? defaultAccounts.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.badge_outlined, size: 14, color: colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Default Role Account (Quick Access)',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.surfaceContainerHigh,
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DefaultAccountProfile>(
              value: currentAccount,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: colorScheme.primary,
                size: 26,
              ),
              items: defaultAccounts.map((account) {
                return DropdownMenuItem<DefaultAccountProfile>(
                  value: account,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: account.accentColor.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          account.icon,
                          size: 16,
                          color: account.accentColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    account.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: account.accentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    account.roleBadge,
                                    style: TextStyle(
                                      color: account.accentColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              account.email,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (account) {
                if (account != null) {
                  onAccountSelected(account);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
