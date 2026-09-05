import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

enum CCButtonVariant { primary, secondary, outline, ghost }

class CCButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final CCButtonVariant variant;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double height;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const CCButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CCButtonVariant.primary,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.height = 48,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case CCButtonVariant.primary:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
      case CCButtonVariant.secondary:
        backgroundColor = colorScheme.secondary;
        foregroundColor = colorScheme.onSecondary;
        break;
      case CCButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.primary;
        borderSide = BorderSide(color: colorScheme.primary, width: 1.5);
        break;
      case CCButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.primary;
        break;
    }

    final effectiveOnPressed = isLoading ? null : onPressed;

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.6),
          elevation: variant == CCButtonVariant.primary ? 1 : 0,
          shadowColor: colorScheme.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderSide,
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: effectiveOnPressed,
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[
                    leadingIcon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    trailingIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}
