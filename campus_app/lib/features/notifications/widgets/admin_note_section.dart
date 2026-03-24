import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../models/notification_model.dart';

class AdminNoteSection extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback onNoteAdded;

  const AdminNoteSection({
    super.key,
    required this.notification,
    required this.onNoteAdded,
  });

  @override
  State<AdminNoteSection> createState() => _AdminNoteSectionState();
}

class _AdminNoteSectionState extends State<AdminNoteSection> {
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitNote() async {
    if (_noteController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    final response = await ApiService.addAdminNote(
      widget.notification.id,
      _noteController.text.trim(),
    );
    setState(() => _isSubmitting = false);

    if (response.success) {
      _noteController.clear();
      widget.onNoteAdded();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yönetici notu eklendi'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Hata oluştu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Yönetici Notları',
          style: TextStyle(
            fontSize: 16,
            fontWeight: AppFontWeights.semibold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        if (widget.notification.adminNotes.isNotEmpty)
          ...widget.notification.adminNotes.map((note) => _buildNoteItem(note)),

        if (widget.notification.adminNotes.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.neutral200),
            ),
            child: const Text(
              'Henüz yönetici notu eklenmemiş.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        const SizedBox(height: AppSpacing.sm),

        FutureBuilder<bool>(
          future: StorageService.isAdmin(),
          builder: (context, snapshot) {
            if (snapshot.data != true) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.neutral200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Yeni not ekle...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const Divider(height: 24, color: AppColors.neutral200),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      icon:
                          _isSubmitting
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.send, size: 16),
                      label: const Text('Not Ekle'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNoteItem(AdminNoteModel note) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                note.adminName ?? 'Yönetici',
                style: const TextStyle(
                  fontWeight: AppFontWeights.semibold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${note.createdAt.day}.${note.createdAt.month}.${note.createdAt.year} ${note.createdAt.hour}:${note.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.noteContent,
            style: const TextStyle(color: AppColors.textPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
