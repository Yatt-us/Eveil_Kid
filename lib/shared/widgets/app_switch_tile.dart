import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Tuile de commutation Switch élégante et sans conflit de `shape`/`borderRadius`.
///
/// Peut être affichée soit en tant que carte autonome avec bordure (`isOutlined: true`),
/// soit intégrée de façon transparente dans une `AppCard` (`isOutlined: false`).
class AppSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final bool isOutlined;

  const AppSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: isOutlined
          ? const BorderSide(color: AppColors.border, width: 1.0)
          : BorderSide.none,
    );

    return Material(
      color: isOutlined ? AppColors.surface : Colors.transparent,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primaryLight,
        activeThumbColor: AppColors.primary,
        dense: true,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        secondary: icon != null
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (value ? AppColors.primary : AppColors.icon)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: value ? AppColors.primary : AppColors.icon,
                  size: 20,
                ),
              )
            : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isOutlined ? 14 : 4,
          vertical: 2,
        ),
      ),
    );
  }
}

/// Tuile Checkbox épurée sans conflit de shape/borderRadius.
class AppCheckboxTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isOutlined;

  const AppCheckboxTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: isOutlined
          ? const BorderSide(color: AppColors.border, width: 1.0)
          : BorderSide.none,
    );

    return Material(
      color: isOutlined ? AppColors.surface : Colors.transparent,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        dense: true,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isOutlined ? 12 : 4,
          vertical: 2,
        ),
      ),
    );
  }
}
