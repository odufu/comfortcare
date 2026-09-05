import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../extensions/context_extensions.dart';

class CCAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final bool showLocationSelector;
  final String selectedLocation;
  final VoidCallback? onLocationTap;
  final int cartItemCount;
  final VoidCallback? onCartTap;
  final VoidCallback? onNotificationsTap;
  final Widget? trailing;

  const CCAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = false,
    this.showLocationSelector = false,
    this.selectedLocation = 'Comfort Mall, Life Camp, Abuja',
    this.onLocationTap,
    this.cartItemCount = 0,
    this.onCartTap,
    this.onNotificationsTap,
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
      title: showLocationSelector
          ? InkWell(
              onTap: onLocationTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DELIVER TO',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            selectedLocation,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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
            )
          : Row(
              children: [
                if (showBackButton) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: colorScheme.onSurface,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                ],
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
          if (onNotificationsTap != null)
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications_outlined, color: colorScheme.onSurfaceVariant),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.surfaceContainerLowest, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: onNotificationsTap,
            ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.shopping_bag_outlined, color: colorScheme.onSurfaceVariant),
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
          const SizedBox(width: 8),
        ],
      ],
    );
  }
}
