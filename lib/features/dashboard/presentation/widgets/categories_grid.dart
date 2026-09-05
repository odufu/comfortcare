import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/category.dart';

class CategoriesGrid extends StatelessWidget {
  final List<CategoryEntity> categories;

  const CategoriesGrid({
    super.key,
    required this.categories,
  });

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'medication':
        return Icons.medication_outlined;
      case 'smart_toy':
        return Icons.smart_toy_outlined;
      case 'ac_unit':
        return Icons.ac_unit_outlined;
      case 'monitor_heart':
        return Icons.monitor_heart_outlined;
      case 'coronavirus':
        return Icons.coronavirus_outlined;
      case 'domain':
        return Icons.domain_outlined;
      default:
        return Icons.medical_services_outlined;
    }
  }

  void _onCategoryTap(BuildContext context, CategoryEntity category) {
    if (category.id == 'cat-ai') {
      context.push('/ai-consult');
    } else if (category.id == 'cat-vitals') {
      context.push('/vitals');
    } else {
      context.push('/products');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.25,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final item = categories[index];
        final isSpecial = item.id == 'cat-ai';

        return InkWell(
          onTap: () => _onCategoryTap(context, item),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSpecial
                    ? colorScheme.primary.withValues(alpha: 0.4)
                    : colorScheme.surfaceContainerHigh,
                width: isSpecial ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isSpecial
                            ? colorScheme.primary
                            : colorScheme.primaryContainer.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _resolveIcon(item.iconName),
                        color: isSpecial ? colorScheme.onPrimary : colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.itemCount,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
