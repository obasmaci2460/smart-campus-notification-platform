import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/services/api_service.dart';
import '../../../models/notification_model.dart';

class FollowedNotificationsScreen extends StatefulWidget {
  const FollowedNotificationsScreen({super.key});

  @override
  State<FollowedNotificationsScreen> createState() =>
      _FollowedNotificationsScreenState();
}

class _FollowedNotificationsScreenState
    extends State<FollowedNotificationsScreen> {
  List<NotificationModel> _followedNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowed();
  }

  Future<void> _loadFollowed() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getFollowedNotifications();

      if (response.success && response.data != null) {
        setState(() {
          _followedNotifications = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unfollowNotification(int id) async {
    final response = await ApiService.unfollowNotification(id);

    if (response.success) {
      setState(() {
        _followedNotifications.removeWhere((n) => n.id == id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Takip bırakıldı'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Takip Ettiklerim',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _followedNotifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _followedNotifications.length,
                itemBuilder: (context, index) {
                  final notification = _followedNotifications[index];
                  return _buildSwipeableCard(notification);
                },
              ),
    );
  }

  Widget _buildSwipeableCard(NotificationModel notification) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Takibi Bırak'),
                content: const Text(
                  'Bu bildirimi takip etmeyi bırakmak istediğinizden emin misiniz?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('İptal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Bırak'),
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) {
        _unfollowNotification(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(
                  int.parse(
                    notification.category.colorHex.replaceFirst('#', '0xFF'),
                  ),
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                _getCategoryIcon(notification.category.name),
                color: Color(
                  int.parse(
                    notification.category.colorHex.replaceFirst('#', '0xFF'),
                  ),
                ),
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: AppFontWeights.semibold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      if (notification.hasUpdates ?? false)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    notification.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          notification.status.colorHex.replaceFirst(
                            '#',
                            '0xFF',
                          ),
                        ),
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      notification.status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: AppFontWeights.medium,
                        color: Color(
                          int.parse(
                            notification.status.colorHex.replaceFirst(
                              '#',
                              '0xFF',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: AppColors.neutral300),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Henüz takip ettiğiniz bildirim yok',
              style: TextStyle(
                fontSize: 18,
                fontWeight: AppFontWeights.semibold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Bildirimleri takip ederek güncel kalabilirsiniz',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'security':
        return Icons.security;
      case 'maintenance':
        return Icons.build;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'infrastructure':
        return Icons.construction;
      case 'other':
        return Icons.help_outline;
      default:
        return Icons.notifications;
    }
  }
}
