import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;
  final bool hasBadge;
  final String? badgeText;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 40,
    this.tooltip,
    this.hasBadge = false,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor =
        backgroundColor ?? AppColors.primary.withValues(alpha: 0.1);
    final effectiveIconColor = color ?? AppColors.primary;

    Widget button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, color: effectiveIconColor, size: size * 0.5),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    if (hasBadge || badgeText != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: EdgeInsets.all(badgeText != null ? 4 : 5),
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: badgeText != null
                  ? Text(
                      badgeText!,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : null,
            ),
          ),
        ],
      );
    }

    return button;
  }
}
