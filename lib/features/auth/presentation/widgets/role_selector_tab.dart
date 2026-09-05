import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/user.dart';

class RoleSelectorTab extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const RoleSelectorTab({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleButton(
              context: context,
              role: UserRole.patient,
              label: 'Individual / Patient',
              icon: Icons.person,
              isSelected: selectedRole == UserRole.patient,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildRoleButton(
              context: context,
              role: UserRole.wholesale,
              label: 'Clinic / Wholesale',
              icon: Icons.domain,
              isSelected: selectedRole == UserRole.wholesale,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required UserRole role,
    required String label,
    required IconData icon,
    required bool isSelected,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onRoleChanged(role),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
