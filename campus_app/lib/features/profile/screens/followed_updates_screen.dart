import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/services/api_service.dart';
import '../../../models/notification_model.dart';

class FollowedUpdatesScreen extends StatefulWidget {
  final int updateCount;

  const FollowedUpdatesScreen({super.key, this.updateCount = 0});

  @override
  State<FollowedUpdatesScreen> createState() => _FollowedUpdatesScreenState();
}

class _FollowedUpdatesScreenState extends State<FollowedUpdatesScreen> {
  List<NotificationModel> _updatedNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUpdatedNotifications();
  }

  Future<void> _loadUpdatedNotifications() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getFollowedNotifications();

      if (response.success && response.data != null) {
        final allFollowed = response.data!;

        allFollowed.sort((a, b) {
          final aTime = a.updatedAt ?? DateTime.now();
          final bTime = b.updatedAt ?? DateTime.now();
          return bTime.compareTo(aTime);
        });

        final reversedList = allFollowed.reversed.toList();

        debugPrint('=== FOLLOWED UPDATES (Badge-Based) ===');
        debugPrint('Total followed: ${reversedList.length}');
        debugPrint('Showing all, sorted by update time');

        setState(() {
          _updatedNotifications = reversedList;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Güncellemeler',
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
              : _updatedNotifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: _loadUpdatedNotifications,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _updatedNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = _updatedNotifications[index];
                    return _buildNotificationCard(notification, index);
                  },
                ),
              ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, int index) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/notification-detail',
          arguments: notification.id,
        ).then((_) => _loadUpdatedNotifications());
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
                      if (index < widget.updateCount)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
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
            Icon(
              Icons.notifications_none,
              size: 64,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Yeni güncelleme yok',
              style: TextStyle(
                fontSize: 18,
                fontWeight: AppFontWeights.semibold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Takip ettiğiniz bildirimlerde henüz güncelleme yok',
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
