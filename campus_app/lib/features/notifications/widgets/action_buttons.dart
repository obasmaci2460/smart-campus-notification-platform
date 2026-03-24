import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../models/notification_model.dart';

class ActionButtons extends StatefulWidget {
  final NotificationModel notification;
  final Function(NotificationModel) onUpdate;

  const ActionButtons({
    super.key,
    required this.notification,
    required this.onUpdate,
  });

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  bool _isLoading = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await StorageService.isAdmin();
    if (mounted) {
      setState(() => _isAdmin = isAdmin);
    }
  }

  Future<void> _handleFollow() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.followNotification(
        widget.notification.id,
      );

      if (response.success && mounted) {
        widget.onUpdate(widget.notification);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bildirim takibe alındı'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? 'İşlem başarısız')),
          );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bağlantı hatası')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUnfollow() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.unfollowNotification(
        widget.notification.id,
      );

      if (response.success && mounted) {
        widget.onUpdate(widget.notification);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Takipten çıkıldı'),
            backgroundColor: AppColors.neutral600,
          ),
        );
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? 'İşlem başarısız')),
          );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bağlantı hatası')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleStatusUpdate(int statusId) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.updateNotificationStatus(
        widget.notification.id,
        statusId,
      );

      if (response.success && mounted) {
        widget.onUpdate(widget.notification);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Durum güncellendi'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? 'İşlem başarısız')),
          );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bağlantı hatası')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showUnfollowDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Takibi Bırak'),
            content: const Text(
              'Bu bildirimle ilgili güncellemeleri almayı durdurmak istiyor musunuz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Vazgeç',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleUnfollow();
                },
                child: const Text(
                  'Takipten Çık',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }

  void _showStatusSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Durum Güncelle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildStatusOption(
                  1,
                  'Açık',
                  Icons.error_outline,
                  const Color(0xFFF59E0B),
                ),
                _buildStatusOption(
                  2,
                  'İnceleniyor',
                  Icons.hourglass_top,
                  const Color(0xFF3B82F6),
                ),
                _buildStatusOption(
                  3,
                  'Çözüldü',
                  Icons.check_circle,
                  const Color(0xFF16A34A),
                ),
                _buildStatusOption(
                  4,
                  'Spam',
                  Icons.block,
                  const Color(0xFFDC2626),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatusOption(int id, String text, IconData icon, Color color) {
    final isSelected = widget.notification.status.id == id;

    return InkWell(
      onTap: () => _handleStatusUpdate(id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? color : AppColors.neutral200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      isSelected
                          ? AppFontWeights.semibold
                          : AppFontWeights.medium,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check, color: color),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.neutral200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            if (widget.notification.isFollowing) {
                              _showUnfollowDialog();
                            } else {
                              _handleFollow();
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.notification.isFollowing
                            ? AppColors.neutral100
                            : AppColors.primary,
                    foregroundColor:
                        widget.notification.isFollowing
                            ? AppColors.textPrimary
                            : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      side:
                          widget.notification.isFollowing
                              ? const BorderSide(color: AppColors.neutral300)
                              : BorderSide.none,
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.notification.isFollowing
                                    ? Icons.notifications_off
                                    : Icons.notifications_active,
                                size: 20,
                                color:
                                    widget.notification.isFollowing
                                        ? AppColors.textSecondary
                                        : null,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  widget.notification.isFollowing
                                      ? 'Takipten Çık'
                                      : 'Takip Et',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: AppFontWeights.semibold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            if (_isAdmin)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _showStatusSheet,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.admin_panel_settings, size: 20),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "Durum",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
