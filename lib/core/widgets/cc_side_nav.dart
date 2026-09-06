import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../extensions/context_extensions.dart';
import '../theme/bloc/theme_bloc.dart';
import '../theme/bloc/theme_event.dart';

class _SideNavItemData {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? badge;

  const _SideNavItemData({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}

class CCSideNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onAiDoctorTap;
  final bool initialCollapsed;

  const CCSideNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onAiDoctorTap,
    this.initialCollapsed = false,
  });

  @override
  State<CCSideNav> createState() => _CCSideNavState();
}

class _CCSideNavState extends State<CCSideNav> {
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initialCollapsed;
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final isDark = context.isDarkMode;

    final navItems = [
      const _SideNavItemData(
        index: 0,
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        badge: 'Hub',
      ),
      const _SideNavItemData(
        index: 1,
        icon: Icons.local_pharmacy_outlined,
        activeIcon: Icons.local_pharmacy,
        label: 'Pharmacy',
        badge: 'Store',
      ),
      const _SideNavItemData(
        index: 2,
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'Orders',
        badge: 'Live',
      ),
      const _SideNavItemData(
        index: 3,
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
      ),
      const _SideNavItemData(
        index: 4,
        icon: Icons.monitor_heart_outlined,
        activeIcon: Icons.monitor_heart,
        label: 'Health Vitals',
        badge: 'Telemetry',
      ),
    ];

    final width = _isCollapsed ? 76.0 : 250.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          right: BorderSide(
            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = _isCollapsed || constraints.maxWidth < 180;

          return SafeArea(
            child: Column(
              children: [
                // Top Header: Brand Lockup & Collapse Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isNarrow ? 8 : 12,
                    vertical: 12,
                  ),
                  child: isNarrow
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLogoAvatar(colorScheme),
                            const SizedBox(height: 6),
                            IconButton(
                              icon: const Icon(Icons.menu, size: 20),
                              tooltip: 'Expand Sidebar',
                              color: colorScheme.onSurfaceVariant,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              onPressed: _toggleCollapse,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            _buildLogoAvatar(colorScheme),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ComfortCare',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: colorScheme.onSurface,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Abuja Health Hub',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.menu_open, size: 20),
                              tooltip: 'Collapse Sidebar',
                              color: colorScheme.onSurfaceVariant,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              onPressed: _toggleCollapse,
                            ),
                          ],
                        ),
                ),

                const Divider(height: 1),
                const SizedBox(height: 12),

                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    children: [
                      for (final item in navItems) ...[
                        _buildNavItemTile(
                          context,
                          item: item,
                          isSelected: widget.currentIndex == item.index,
                          isCollapsed: isNarrow,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        const SizedBox(height: 4),
                      ],
                      const SizedBox(height: 16),

                      // AI Doctor Launcher Card / Mini Button
                      if (!isNarrow)
                        _buildAiDoctorCard(context, colorScheme, textTheme)
                      else
                        _buildAiDoctorMiniButton(context, colorScheme),
                    ],
                  ),
                ),

                // Bottom Footer
                const Divider(height: 1),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isNarrow ? 8 : 12,
                    vertical: 10,
                  ),
                  child: isNarrow
                      ? IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          onPressed: () {
                            context.read<ThemeBloc>().add(ToggleThemeMode(isCurrentDark: isDark));
                          },
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1B6D24),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Abuja Central Depot',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: colorScheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '2°C - 8°C Cold-Chain',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                size: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: () {
                                context.read<ThemeBloc>().add(ToggleThemeMode(isCurrentDark: isDark));
                              },
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoAvatar(ColorScheme colorScheme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.local_hospital, color: colorScheme.primary, size: 20),
        ),
      ),
    );
  }

  Widget _buildNavItemTile(
    BuildContext context, {
    required _SideNavItemData item,
    required bool isSelected,
    required bool isCollapsed,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    if (isCollapsed) {
      return Tooltip(
        message: item.label,
        preferBelow: false,
        child: Material(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => widget.onTap(item.index),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 22,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => widget.onTap(item.index),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 21,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.badge!,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiDoctorCard(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF006194),
            const Color(0xFF007BB9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006194).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFA0F399),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy,
                  size: 16,
                  color: Color(0xFF005312),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'AI Doctor Co-Pilot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Instant 24/7 symptom triage and clinical formulary matching.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 10.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF006194),
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                if (widget.onAiDoctorTap != null) {
                  widget.onAiDoctorTap!();
                } else {
                  context.push('/ai-consult');
                }
              },
              child: const Text(
                'Consult Now →',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiDoctorMiniButton(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Tooltip(
      message: 'AI Doctor Consultation',
      preferBelow: false,
      child: Material(
        color: colorScheme.primary,
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: colorScheme.primary.withValues(alpha: 0.3),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            if (widget.onAiDoctorTap != null) {
              widget.onAiDoctorTap!();
            } else {
              context.push('/ai-consult');
            }
          },
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: const Icon(
              Icons.smart_toy,
              size: 22,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
