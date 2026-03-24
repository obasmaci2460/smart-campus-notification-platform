import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../models/notification_model.dart';

class DetailHeader extends StatelessWidget {
  final NotificationModel notification;

  const DetailHeader({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: notification.category.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              notification.category.iconData,
              color: notification.category.color,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            notification.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: AppFontWeights.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
