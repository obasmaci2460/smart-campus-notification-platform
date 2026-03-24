import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/notification_model.dart';
import 'status_badge.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryBadge(),
            const SizedBox(width: AppSpacing.md),

            Expanded(child: _buildContent()),

            _buildTrailing(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: notification.category.color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        notification.category.iconData,
        color: _getIconColor(notification.category.name),
        size: 28,
      ),
    );
  }

  Color _getIconColor(String categoryName) {
    if (categoryName == 'cleaning') {
      return AppColors.neutral800;
    }
    return Colors.white;
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: AppFontWeights.semibold,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),

        Text(
          notification.description,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),

        _buildMeta(),
      ],
    );
  }

  Widget _buildMeta() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 14, color: AppColors.neutral400),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                notification.user.maskedName,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutral400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 14, color: AppColors.neutral400),
            const SizedBox(width: AppSpacing.xs),
            Text(
              notification.relativeTime,
              style: const TextStyle(fontSize: 13, color: AppColors.neutral400),
            ),
          ],
        ),

        if (notification.photoCount > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image, size: 14, color: AppColors.neutral400),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${notification.photoCount}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),

        if (notification.followerCount > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline, size: 14, color: AppColors.neutral400),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${notification.followerCount}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTrailing() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge.fromStatusId(
            statusId: notification.status.id,
            displayName: notification.status.displayName,
          ),
        ],
      ),
    );
  }
}
