import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

class CCStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final double height;

  const CCStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 999,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.surfaceContainerHigh,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            iconSize: 18,
            constraints: BoxConstraints(minWidth: height, minHeight: height),
            splashRadius: 18,
            icon: Icon(
              Icons.remove,
              color: value > min ? colorScheme.primary : colorScheme.outline,
            ),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$value',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            iconSize: 18,
            constraints: BoxConstraints(minWidth: height, minHeight: height),
            splashRadius: 18,
            icon: Icon(
              Icons.add,
              color: value < max ? colorScheme.primary : colorScheme.outline,
            ),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
