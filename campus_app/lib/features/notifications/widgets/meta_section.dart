import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../models/notification_model.dart';

class MetaSection extends StatelessWidget {
  final NotificationModel notification;

  const MetaSection({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _buildChip(
            icon: notification.category.iconData,
            label: notification.category.displayName,
            iconColor: notification.category.color,
          ),
          const SizedBox(width: AppSpacing.sm),

          _buildChip(
            icon: Icons.person_outline,
            label: notification.user.maskedName,
          ),
          const SizedBox(width: AppSpacing.sm),

          if (notification.user.department.isNotEmpty) ...[
            _buildChip(
              icon: Icons.business_outlined,
              label: notification.user.department,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],

          _buildChip(icon: Icons.access_time, label: notification.relativeTime),
          const SizedBox(width: AppSpacing.sm),

          if (notification.photoCount > 0) ...[
            _buildChip(
              icon: Icons.image_outlined,
              label: '${notification.photoCount} Fotoğraf',
            ),
            const SizedBox(width: AppSpacing.sm),
          ],

          if (notification.followerCount > 0) ...[
            _buildChip(
              icon: Icons.people_outline,
              label: '${notification.followerCount} Takipçi',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor ?? AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: AppFontWeights.medium,
            ),
          ),
        ],
      ),
    );
  }
}
