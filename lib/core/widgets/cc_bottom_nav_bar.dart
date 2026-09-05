import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

class CCBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CCBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.local_pharmacy_outlined,
                activeIcon: Icons.local_pharmacy,
                label: 'Pharmacy',
              ),
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.medication_outlined,
                activeIcon: Icons.medication,
                label: 'Catalog',
              ),
              _buildNavItem(
                context,
                index: 2,
                icon: Icons.smart_toy_outlined,
                activeIcon: Icons.smart_toy,
                label: 'AI Doctor',
                isSpecial: true,
              ),
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'Orders',
              ),
              _buildNavItem(
                context,
                index: 4,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool isSpecial = false,
  }) {
    final isSelected = currentIndex == index;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final selectedColor = isSpecial ? colorScheme.primary : colorScheme.primary;
    final unselectedColor = colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSpecial)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.primaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 20,
                  color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                ),
              )
            else
              Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            const SizedBox(height: 3),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
