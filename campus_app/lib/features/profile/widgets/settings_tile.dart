import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.neutral200, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? AppColors.error : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: AppFontWeights.medium,
                  color: isLogout ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            if (!isLogout)
              Icon(Icons.chevron_right, color: AppColors.neutral400, size: 20),
          ],
        ),
      ),
    );
  }
}
