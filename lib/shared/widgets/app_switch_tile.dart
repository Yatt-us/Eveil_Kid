import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: isOutlined
          ? BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.2),
              width: 1.0,
            )
          : BorderSide.none,
    );

    return Material(
      color: isOutlined ? theme.colorScheme.surface : Colors.transparent,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.4),
        activeThumbColor: theme.colorScheme.primary,
        dense: true,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleMedium?.color ??
                theme.colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12.5,
                  color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.7) ??
                      theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        secondary: icon != null
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (value
                          ? theme.colorScheme.primary
                          : (theme.iconTheme.color ??
                              theme.colorScheme.onSurfaceVariant))
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: value
                      ? theme.colorScheme.primary
                      : (theme.iconTheme.color ??
                          theme.colorScheme.onSurfaceVariant),
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
    final theme = Theme.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: isOutlined
          ? BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.2),
              width: 1.0,
            )
          : BorderSide.none,
    );

    return Material(
      color: isOutlined ? theme.colorScheme.surface : Colors.transparent,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
        dense: true,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleMedium?.color ??
                theme.colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12.5,
                  color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.7) ??
                      theme.colorScheme.onSurfaceVariant,
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
