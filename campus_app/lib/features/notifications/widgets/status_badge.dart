import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class StatusBadge extends StatelessWidget {
  final String displayName;
  final Color color;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    super.key,
    required this.displayName,
    required this.color,
    this.icon,
    this.fontSize = AppFontSizes.caption,
    this.padding,
  });

  factory StatusBadge.fromStatusId({
    Key? key,
    required int statusId,
    required String displayName,
    double fontSize = AppFontSizes.caption,
    EdgeInsetsGeometry? padding,
  }) {
    return StatusBadge(
      key: key,
      displayName: displayName,
      color: _getStatusColor(statusId),
      icon: _getStatusIcon(statusId),
      fontSize: fontSize,
      padding: padding,
    );
  }

  static Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1:
        return Color(0xFFF59E0B);
      case 2:
        return Color(0xFF3B82F6);
      case 3:
        return Color(0xFF16A34A);
      case 4:
        return Color(0xFFDC2626);
      default:
        return Color(0xFFF59E0B);
    }
  }

  static IconData _getStatusIcon(int statusId) {
    switch (statusId) {
      case 1:
        return Icons.error_outline;
      case 2:
        return Icons.hourglass_top;
      case 3:
        return Icons.check_circle_outline;
      case 4:
        return Icons.block;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: AppSpacing.xs + 2,
          ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.24),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              displayName,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: AppFontWeights.bold,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
