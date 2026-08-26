import 'package:flutter/material.dart';

enum AppButtonVariant { primary, outlined, text, danger }

enum AppButtonSize { small, medium, large }

/// Bouton réutilisable avec le même langage visuel que [AppGoogleButton] :
/// Container décoré + Material + InkWell pour un rendu premium et des ripples
/// parfaitement clippés, adapté automatiquement au thème.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;
  final AppButtonVariant variant;
  final AppButtonSize size;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
  });

  // ── Helpers de sizing ─────────────────────────────────────────────────────

  double get _height => switch (size) {
        AppButtonSize.small => 40,
        AppButtonSize.medium => 48,
        AppButtonSize.large => 54,
      };

  EdgeInsets get _padding => switch (size) {
        AppButtonSize.small => const EdgeInsets.symmetric(horizontal: 16),
        AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 24),
        AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 32),
      };

  double get _fontSize => switch (size) {
        AppButtonSize.small => 13,
        AppButtonSize.medium => 14,
        AppButtonSize.large => 16,
      };

  double get _iconSize => switch (size) {
        AppButtonSize.small => 16,
        AppButtonSize.medium => 18,
        AppButtonSize.large => 22,
      };

  double get _spinnerSize => switch (size) {
        AppButtonSize.small => 16,
        AppButtonSize.medium => 20,
        AppButtonSize.large => 22,
      };

  // ── Couleurs selon la variante et le thème ─────────────────────────────────

  Color _getBackgroundColor(ThemeData theme) => switch (variant) {
        AppButtonVariant.primary => theme.colorScheme.primary,
        AppButtonVariant.danger => theme.colorScheme.error,
        AppButtonVariant.outlined => theme.colorScheme.surface,
        AppButtonVariant.text => Colors.transparent,
      };

  Color _getForegroundColor(ThemeData theme) => switch (variant) {
        AppButtonVariant.primary => theme.colorScheme.onPrimary,
        AppButtonVariant.danger => theme.colorScheme.onError,
        AppButtonVariant.outlined || AppButtonVariant.text => theme.colorScheme.primary,
      };

  Color _getSpinnerColor(ThemeData theme) => switch (variant) {
        AppButtonVariant.primary => theme.colorScheme.onPrimary,
        AppButtonVariant.danger => theme.colorScheme.onError,
        AppButtonVariant.outlined || AppButtonVariant.text => theme.colorScheme.primary,
      };

  Color _getDisabledBgColor(ThemeData theme) => switch (variant) {
        AppButtonVariant.primary =>
          theme.colorScheme.primary.withValues(alpha: 0.55),
        AppButtonVariant.danger =>
          theme.colorScheme.error.withValues(alpha: 0.55),
        AppButtonVariant.outlined => theme.colorScheme.surface,
        AppButtonVariant.text => Colors.transparent,
      };

  Color _getDisabledFgColor(ThemeData theme) => switch (variant) {
        AppButtonVariant.primary =>
          theme.colorScheme.onPrimary.withValues(alpha: 0.7),
        AppButtonVariant.danger =>
          theme.colorScheme.onError.withValues(alpha: 0.7),
        AppButtonVariant.outlined || AppButtonVariant.text =>
          theme.colorScheme.primary.withValues(alpha: 0.45),
      };

  Border? _getBorder(ThemeData theme) => switch (variant) {
        AppButtonVariant.outlined => Border.all(
            color: onPressed != null && !isLoading
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withValues(alpha: 0.35),
            width: 1.5,
          ),
        AppButtonVariant.text => null,
        AppButtonVariant.primary || AppButtonVariant.danger => null,
      };

  List<BoxShadow> _getShadow(ThemeData theme) => switch (variant) {
        AppButtonVariant.primary => [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        AppButtonVariant.danger => [
            BoxShadow(
              color: theme.colorScheme.error.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        AppButtonVariant.outlined => [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        AppButtonVariant.text => [],
      };

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool disabled = isLoading || onPressed == null;
    final Color bgColor = disabled ? _getDisabledBgColor(theme) : _getBackgroundColor(theme);
    final Color fgColor = disabled ? _getDisabledFgColor(theme) : _getForegroundColor(theme);

    Widget content = isLoading
        ? SizedBox(
            width: _spinnerSize,
            height: _spinnerSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_getSpinnerColor(theme)),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _iconSize, color: fgColor),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w600,
                    color: fgColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          );

    final Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: _height,
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: _getBorder(theme),
        boxShadow: disabled ? [] : _getShadow(theme),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          splashColor: fgColor.withValues(alpha: 0.12),
          highlightColor: fgColor.withValues(alpha: 0.06),
          child: Padding(
            padding: _padding,
            child: Center(child: content),
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
