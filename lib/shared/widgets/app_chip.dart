import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum AppChipVariant { primary, success, warning, danger, neutral }

class AppChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final AppChipVariant variant;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.variant = AppChipVariant.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getChipColors();

    Widget chipContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: colors.textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textColor,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: chipContent,
      );
    }

    return chipContent;
  }

  _ChipColors _getChipColors() {
    switch (variant) {
      case AppChipVariant.primary:
        return _ChipColors(
          bgColor: AppColors.primary.withValues(alpha: 0.1),
          borderColor: AppColors.primary.withValues(alpha: 0.3),
          textColor: AppColors.primary,
        );
      case AppChipVariant.success:
        return _ChipColors(
          bgColor: AppColors.success.withValues(alpha: 0.1),
          borderColor: AppColors.success.withValues(alpha: 0.3),
          textColor: AppColors.success,
        );
      case AppChipVariant.warning:
        return _ChipColors(
          bgColor: AppColors.warning.withValues(alpha: 0.1),
          borderColor: AppColors.warning.withValues(alpha: 0.3),
          textColor: AppColors.warning,
        );
      case AppChipVariant.danger:
        return _ChipColors(
          bgColor: AppColors.danger.withValues(alpha: 0.1),
          borderColor: AppColors.danger.withValues(alpha: 0.3),
          textColor: AppColors.danger,
        );
      case AppChipVariant.neutral:
        return const _ChipColors(
          bgColor: AppColors.background,
          borderColor: AppColors.border,
          textColor: AppColors.textSecondary,
        );
    }
  }
}

class _ChipColors {
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  const _ChipColors({
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });
}
