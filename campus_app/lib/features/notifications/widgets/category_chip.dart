import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class CategoryChip extends StatelessWidget {
  final int? categoryId;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? dotColor;

  const CategoryChip({
    super.key,
    this.categoryId,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor =
        categoryId != null ? AppCategories.getColor(categoryId!) : null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (categoryColor != null && !isSelected) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: categoryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: AppFontSizes.small,
                fontWeight:
                    isSelected ? AppFontWeights.medium : AppFontWeights.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
