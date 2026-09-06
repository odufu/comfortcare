import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../extensions/context_extensions.dart';

class CCAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final bool showLocationSelector;
  final bool showBrandLogo;
  final bool showProfileAvatar;
  final String selectedLocation;
  final VoidCallback? onLocationTap;
  final int cartItemCount;
  final VoidCallback? onCartTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;
  final Widget? trailing;

  const CCAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = false,
    this.showLocationSelector = false,
    this.showBrandLogo = false,
    this.showProfileAvatar = false,
    this.selectedLocation = 'Comfort Mall, Life Camp, Abuja',
    this.onLocationTap,
    this.cartItemCount = 0,
    this.onCartTap,
    this.onNotificationsTap,
    this.onProfileTap,
    this.trailing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: colorScheme.surfaceContainerLowest.withValues(alpha: 0.95),
      elevation: 0,
      titleSpacing: 16,
      toolbarHeight: 64,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBackButton) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: colorScheme.onSurface,
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: 4),
          ],
          if (showBrandLogo) ...[
            InkWell(
              onTap: () => context.go('/dashboard'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainerLowest,
                  border: Border.all(
                    color: colorScheme.surfaceContainerHigh,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: context.isDarkMode ? 0.25 : 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.local_pharmacy,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (showLocationSelector)
            Flexible(
              child: InkWell(
                onTap: onLocationTap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: colorScheme.primary,
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'DELIVER TO',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              selectedLocation,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title ?? 'ComfortCare',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    Text(
                      subtitle!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
      actions: [
        if (trailing != null)
          trailing!
        else ...[
          IconButton(
            tooltip: 'Notifications',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_outlined, color: colorScheme.onSurfaceVariant, size: 22),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBA1A1A),
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surfaceContainerLowest, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: onNotificationsTap ??
                () {
                  context.showSnackBar('No new notifications. Cold-chain storage normal.');
                },
          ),
          IconButton(
            tooltip: 'Cart',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.shopping_bag_outlined, color: colorScheme.onSurfaceVariant, size: 22),
                if (cartItemCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.surfaceContainerLowest, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$cartItemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: onCartTap ?? () => context.push('/cart'),
          ),
          if (showProfileAvatar)
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 12),
              child: InkWell(
                onTap: onProfileTap ?? () => context.go('/profile'),
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.person,
                              color: colorScheme.primary,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B6D24),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surfaceContainerLowest,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}
