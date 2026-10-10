import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

class CCBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CCBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CCBottomNavBar> createState() => _CCBottomNavBarState();
}

class _CCBottomNavBarState extends State<CCBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _liquidController;
  late Animation<double> _liquidAnimation;

  double _fromIndex = 0.0;
  double _targetIndex = 0.0;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.currentIndex.toDouble().clamp(0.0, 4.0);
    _targetIndex = _fromIndex;

    // Continuous subtle breathing pulse for the central AI Doctor orb
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    );

    // Fluid liquid motion controller for tab transitions
    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _liquidAnimation = CurvedAnimation(
      parent: _liquidController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void didUpdateWidget(covariant CCBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex &&
        widget.currentIndex >= 0 &&
        widget.currentIndex <= 4) {
      _fromIndex = _targetIndex;
      _targetIndex = widget.currentIndex.toDouble();
      _liquidController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _liquidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

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
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final itemWidth = totalWidth / 5;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Animated Fluid Liquid Sliding Indicator (top accent bar, no round border on icons)
                  AnimatedBuilder(
                    animation: _liquidAnimation,
                    builder: (context, child) {
                      final progress = _liquidAnimation.value;
                      final currentIndexPos =
                          _fromIndex + (_targetIndex - _fromIndex) * progress;

                      // If currently pointing at the central AI tab, fade out the standard indicator
                      final isNearCenter = (currentIndexPos - 2.0).abs() < 0.3;
                      final opacity = isNearCenter ? (currentIndexPos - 2.0).abs() / 0.3 : 1.0;

                      // Liquid horizontal stretch/squish effect during motion
                      final stretchFactor =
                          math.sin(progress * math.pi) * 0.28 * (_targetIndex - _fromIndex).abs();
                      final indicatorWidth = 28.0 * (1.0 + stretchFactor).clamp(0.8, 1.4);
                      final indicatorLeft =
                          (currentIndexPos * itemWidth) + (itemWidth - indicatorWidth) / 2;

                      return Positioned(
                        left: indicatorLeft,
                        top: 0,
                        child: Opacity(
                          opacity: opacity.clamp(0.0, 1.0),
                          child: Container(
                            width: indicatorWidth,
                            height: 3,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.35),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // 5 Nav Items Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Item 0: Home
                      _buildStandardNavItem(
                        index: 0,
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: 'Home',
                      ),

                      // Item 1: Pharmacy
                      _buildStandardNavItem(
                        index: 1,
                        icon: Icons.local_pharmacy_outlined,
                        activeIcon: Icons.local_pharmacy,
                        label: 'Pharmacy',
                      ),

                      // Item 2: Central Stylized AI Doctor Chat
                      _buildCentralAiNavItem(context, isDark),

                      // Item 3: Orders
                      _buildStandardNavItem(
                        index: 3,
                        icon: Icons.receipt_long_outlined,
                        activeIcon: Icons.receipt_long,
                        label: 'Orders',
                      ),

                      // Item 4: Profile
                      _buildStandardNavItem(
                        index: 4,
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: 'Profile',
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStandardNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = widget.currentIndex == index;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final selectedColor = colorScheme.primary;
    final unselectedColor = colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => widget.onTap(index),
        splashColor: colorScheme.primary.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: (textTheme.labelSmall ?? const TextStyle()).copyWith(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? selectedColor : unselectedColor,
                  letterSpacing: -0.2,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCentralAiNavItem(BuildContext context, bool isDark) {
    final isSelected = widget.currentIndex == 2;
    final colorScheme = context.colorScheme;

    return Expanded(
      child: InkWell(
        onTap: () => widget.onTap(2),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final pulseScale = 1.0 + (_pulseAnimation.value * 0.08);
            final auraAlpha = isSelected ? 0.35 : (0.15 + (_pulseAnimation.value * 0.12));

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Elevated floating AI liquid orb
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: SizedBox(
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                      // Outer liquid aura ripple ring
                      Transform.scale(
                        scale: pulseScale,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0D9488).withValues(alpha: auraAlpha),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D9488).withValues(
                                  alpha: isSelected ? 0.45 : 0.25,
                                ),
                                blurRadius: isSelected ? 14 : 8,
                                spreadRadius: isSelected ? 2 : 0,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Core Stylized Liquid Orb
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isSelected
                                ? const [
                                    Color(0xFF06B6D4), // Liquid Cyan
                                    Color(0xFF0D9488), // Deep Teal
                                    Color(0xFF10B981), // Emerald
                                  ]
                                : const [
                                    Color(0xFF0D9488),
                                    Color(0xFF005470),
                                    Color(0xFF003859),
                                  ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: isSelected ? 0.7 : 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Main AI icon with fluid scale on active
                            AnimatedScale(
                              scale: isSelected ? 1.15 : 1.0,
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOutBack,
                              child: const Icon(
                                Icons.smart_toy,
                                color: Colors.white,
                                size: 21,
                              ),
                            ),

                            // Micro AI spark badge at top right
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFA7F3D0)
                                      : const Color(0xFF34D399),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF34D399).withValues(alpha: 0.8),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

                // Central Button Label
                Transform.translate(
                  offset: const Offset(0, -6),
                  child: Text(
                    'AI Doctor',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF0D9488)
                          : colorScheme.onSurfaceVariant,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
