import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

enum CCChipVariant {
  primary,
  secondary,
  tertiary,
  neutral,
  success,
  warning,
}

class CCChip extends StatelessWidget {
  final String label;
  final Widget? icon;
  final CCChipVariant variant;
  final bool isSelected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const CCChip({
    super.key,
    required this.label,
    this.icon,
    this.variant = CCChipVariant.neutral,
    this.isSelected = false,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    Color bg;
    Color fg;
    Color border;

    if (isSelected) {
      bg = colorScheme.primary;
      fg = colorScheme.onPrimary;
      border = colorScheme.primary;
    } else {
      switch (variant) {
        case CCChipVariant.primary:
          bg = colorScheme.primaryContainer.withValues(alpha: 0.15);
          fg = colorScheme.primary;
          border = colorScheme.primary.withValues(alpha: 0.3);
          break;
        case CCChipVariant.secondary:
        case CCChipVariant.success:
          bg = colorScheme.secondaryContainer.withValues(alpha: 0.25);
          fg = colorScheme.secondary;
          border = colorScheme.secondary.withValues(alpha: 0.4);
          break;
        case CCChipVariant.tertiary:
        case CCChipVariant.warning:
          bg = colorScheme.tertiaryContainer.withValues(alpha: 0.2);
          fg = colorScheme.tertiary;
          border = colorScheme.tertiary.withValues(alpha: 0.4);
          break;
        case CCChipVariant.neutral:
          bg = colorScheme.surfaceContainer;
          fg = colorScheme.onSurfaceVariant;
          border = colorScheme.surfaceContainerHigh;
          break;
      }
    }

    final chipWidget = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: chipWidget,
      );
    }

    return chipWidget;
  }
}
