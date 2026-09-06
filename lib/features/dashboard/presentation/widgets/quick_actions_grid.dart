import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';

class QuickActionItem {
  final String id;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
  });
}

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback? onUploadPrescriptionTap;

  const QuickActionsGrid({
    super.key,
    this.onUploadPrescriptionTap,
  });

  void _showPrescriptionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upload Prescription',
                    style: ctx.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Our Abuja PCN-certified pharmacists verify and formulate within 15 minutes.',
                style: ctx.textTheme.bodySmall?.copyWith(
                  color: ctx.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ctx.showSnackBar('Camera opened. Capturing prescription document...', isSuccess: true);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: ctx.colorScheme.primary,
                        foregroundColor: ctx.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ctx.showSnackBar('Prescription PDF/Image uploaded for pharmacist review!', isSuccess: true);
                      },
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Browse Files'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    final actions = [
      QuickActionItem(
        id: 'action-upload',
        title: 'Upload Rx',
        subtitle: '15-Min Pharmacist Verify',
        badgeText: 'Instant',
        badgeColor: isDark ? colorScheme.secondaryContainer : const Color(0xFFDAE2FD),
        badgeTextColor: isDark ? colorScheme.onSecondaryContainer : const Color(0xFF003258),
        icon: Icons.document_scanner,
        iconBgColor: isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFDAE2FD),
        iconColor: colorScheme.primary,
        onTap: () {
          if (onUploadPrescriptionTap != null) {
            onUploadPrescriptionTap!();
          } else {
            _showPrescriptionModal(context);
          }
        },
      ),
      QuickActionItem(
        id: 'action-ai',
        title: 'AI Doctor',
        subtitle: 'Instant Clinical Triage',
        badgeText: '24/7 Live',
        badgeColor: isDark ? colorScheme.secondaryContainer : const Color(0xFFA0F399),
        badgeTextColor: isDark ? colorScheme.onSecondaryContainer : const Color(0xFF004F18),
        icon: Icons.smart_toy,
        iconBgColor: isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFA0F399).withValues(alpha: 0.3),
        iconColor: isDark ? colorScheme.secondary : const Color(0xFF006D2C),
        onTap: () => context.push('/ai-consult'),
      ),
      QuickActionItem(
        id: 'action-orders',
        title: 'Track Orders',
        subtitle: 'Live Abuja Courier',
        badgeText: '20-35m',
        badgeColor: isDark ? colorScheme.tertiaryContainer : const Color(0xFFFFDCC2),
        badgeTextColor: isDark ? colorScheme.onTertiaryContainer : const Color(0xFF6E3900),
        icon: Icons.local_shipping,
        iconBgColor: isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFFFDCC2).withValues(alpha: 0.3),
        iconColor: isDark ? colorScheme.tertiary : const Color(0xFF904D00),
        onTap: () => context.go('/orders'),
      ),
      QuickActionItem(
        id: 'action-vitals',
        title: 'Health Vitals',
        subtitle: 'BP, Glucose & Heart Rate',
        badgeText: 'Monitor',
        badgeColor: isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFEAEDFF),
        badgeTextColor: isDark ? colorScheme.onSurfaceVariant : const Color(0xFF3B4856),
        icon: Icons.monitor_heart,
        iconBgColor: isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFEAEDFF),
        iconColor: colorScheme.primary,
        onTap: () => context.push('/vitals'),
      ),
    ];

    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _buildActionItem(
              context,
              actions[i],
              isDark,
              colorScheme,
              context.textTheme,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    QuickActionItem item,
    bool isDark,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: item.iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: item.iconColor,
                      size: 20,
                    ),
                  ),
                  if (item.badgeText.isNotEmpty)
                    Positioned(
                      top: -3,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: item.badgeColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: colorScheme.surfaceContainerLowest,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          item.badgeText,
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            color: item.badgeTextColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                item.title,
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 9.5,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
