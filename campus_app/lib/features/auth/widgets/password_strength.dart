import 'package:flutter/material.dart';
import '../../../core/constants.dart';

enum PasswordStrength { none, weak, medium, strong }

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  bool get hasMinLength => password.length >= 8;
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => password.contains(RegExp(r'[a-z]'));
  bool get hasDigit => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecial => password.contains(RegExp(r'[!@#$%^&*]'));

  int get score =>
      [
        hasMinLength,
        hasUppercase,
        hasLowercase,
        hasDigit,
        hasSpecial,
      ].where((e) => e).length;

  PasswordStrength get strength {
    if (password.isEmpty) return PasswordStrength.none;
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  Color get strengthColor => switch (strength) {
    PasswordStrength.none => AppColors.divider,
    PasswordStrength.weak => AppColors.error,
    PasswordStrength.medium => AppColors.warning,
    PasswordStrength.strong => AppColors.success,
  };

  String get strengthText => switch (strength) {
    PasswordStrength.none => 'Şifre gereksinimleri',
    PasswordStrength.weak => 'Zayıf',
    PasswordStrength.medium => 'Orta',
    PasswordStrength.strong => 'Güçlü',
  };

  int get barCount => switch (strength) {
    PasswordStrength.none => 0,
    PasswordStrength.weak => 1,
    PasswordStrength.medium => 2,
    PasswordStrength.strong => 3,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: List.generate(3, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                decoration: BoxDecoration(
                  color: index < barCount ? strengthColor : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strengthText,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: AppFontSizes.small,
                color: strengthColor,
                fontWeight: AppFontWeights.medium,
              ),
            ),
            if (password.isNotEmpty)
              Text(
                '$score/5',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppFontSizes.small,
                  color: strengthColor,
                ),
              ),
          ],
        ),
        if (password.isNotEmpty && strength != PasswordStrength.strong) ...[
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: 2,
            children: [
              _buildRule('8+ karakter', hasMinLength),
              _buildRule('Büyük harf', hasUppercase),
              _buildRule('Küçük harf', hasLowercase),
              _buildRule('Rakam', hasDigit),
              _buildRule('Özel (!@#\$%^&*)', hasSpecial),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRule(String text, bool isValid) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          size: 12,
          color: isValid ? AppColors.success : AppColors.textSecondary,
        ),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: isValid ? AppColors.success : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
