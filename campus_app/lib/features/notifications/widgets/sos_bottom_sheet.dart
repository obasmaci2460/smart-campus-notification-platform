import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class SosBottomSheet extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const SosBottomSheet({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => SosBottomSheet(
            onConfirm: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
    );
  }

  @override
  State<SosBottomSheet> createState() => _SosBottomSheetState();
}

class _SosBottomSheetState extends State<SosBottomSheet> {
  bool _isCountingDown = false;
  int _countdown = 3;

  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });
    _tick();
  }

  void _tick() {
    if (_countdown > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _isCountingDown) {
          setState(() => _countdown--);
          if (_countdown > 0) {
            _tick();
          } else {
            widget.onConfirm();
          }
        }
      });
    }
  }

  void _cancelCountdown() {
    setState(() {
      _isCountingDown = false;
      _countdown = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          if (_isCountingDown) ...[
            _buildCountdownView(),
          ] else ...[
            _buildConfirmationView(),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmationView() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            size: 36,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        const Text(
          'Acil Durum Bildirimi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: AppFontWeights.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        Text(
          'SOS bildirimi gönderdiğinizde konumunuz ve bilgileriniz güvenlik birimine iletilecektir. Yalnızca gerçek acil durumlarda kullanın.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFontSizes.small,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  side: const BorderSide(color: AppColors.neutral300),
                ),
                child: const Text(
                  'İptal',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: AppFontWeights.semibold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: _startCountdown,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Text(
                  'SOS Gönder',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: AppFontWeights.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCountdownView() {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 0.8),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value + 0.2,
              child: Text(
                '$_countdown',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: AppFontWeights.bold,
                  color: AppColors.error,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),

        const Text(
          'SOS gönderiliyor...',
          style: TextStyle(
            fontSize: AppFontSizes.body,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              _cancelCountdown();
              widget.onCancel();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              side: const BorderSide(color: AppColors.neutral300),
            ),
            child: const Text(
              'İptal Et',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: AppFontWeights.semibold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
