import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool disabled;

  const CustomSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: disabled ? null : onChanged,
      activeColor: AppColors.primary,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: AppColors.neutral300,
      activeTrackColor: AppColors.primary.withOpacity(0.5),
    );
  }
}
