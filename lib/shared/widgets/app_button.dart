import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum AppButtonVariant { primary, outlined, text, danger }

enum AppButtonSize { small, medium, large }

/// Bouton réutilisable avec le même langage visuel que [AppGoogleButton] :
/// Container décoré + Material + InkWell pour un rendu premium et des ripples
/// parfaitement clippés.
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

  // ── Couleurs selon la variante ─────────────────────────────────────────────

  Color get _backgroundColor => switch (variant) {
        AppButtonVariant.primary => AppColors.primary,
        AppButtonVariant.danger => AppColors.danger,
        AppButtonVariant.outlined || AppButtonVariant.text => AppColors.surface,
      };

  Color get _foregroundColor => switch (variant) {
        AppButtonVariant.primary || AppButtonVariant.danger => AppColors.white,
        AppButtonVariant.outlined || AppButtonVariant.text => AppColors.primary,
      };

  Color get _spinnerColor => switch (variant) {
        AppButtonVariant.primary || AppButtonVariant.danger => AppColors.white,
        AppButtonVariant.outlined || AppButtonVariant.text => AppColors.primary,
      };

  // Couleur de fond quand disabled (isLoading)
  Color get _disabledBgColor => switch (variant) {
        AppButtonVariant.primary =>
          AppColors.primary.withValues(alpha: 0.55),
        AppButtonVariant.danger =>
          AppColors.danger.withValues(alpha: 0.55),
        AppButtonVariant.outlined || AppButtonVariant.text => AppColors.surface,
      };

  Color get _disabledFgColor => switch (variant) {
        AppButtonVariant.primary || AppButtonVariant.danger =>
          AppColors.white.withValues(alpha: 0.7),
        AppButtonVariant.outlined || AppButtonVariant.text =>
          AppColors.primary.withValues(alpha: 0.45),
      };

  Border? get _border => switch (variant) {
        AppButtonVariant.outlined => Border.all(
            color: onPressed != null && !isLoading
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.35),
            width: 1.5,
          ),
        AppButtonVariant.text => null,
        AppButtonVariant.primary || AppButtonVariant.danger => null,
      };

  List<BoxShadow> get _shadow => switch (variant) {
        AppButtonVariant.primary => [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        AppButtonVariant.danger => [
            BoxShadow(
              color: AppColors.danger.withValues(alpha: 0.22),
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
    final bool disabled = isLoading || onPressed == null;
    final Color bgColor = disabled ? _disabledBgColor : _backgroundColor;
    final Color fgColor = disabled ? _disabledFgColor : _foregroundColor;

    Widget content = isLoading
        ? SizedBox(
            width: _spinnerSize,
            height: _spinnerSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_spinnerColor),
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
              Text(
                text,
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                  letterSpacing: 0.1,
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
        border: _border,
        boxShadow: disabled ? [] : _shadow,
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
