import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';

enum DuolingoButtonColor {
  green,
  sky,
  amber,
  purple,
  coral,
  pink,
  neutral,
}

/// Bouton physique 3D universel tactile style Duolingo avec enfoncement à la pression.
class DuolingoButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final DuolingoButtonColor colorType;
  final Color? customColor;
  final Color? customBottomColor;
  final Color? customTextColor;
  final bool isFullWidth;
  final bool isCompact;
  final bool isEnabled;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final BorderRadius? borderRadius;

  const DuolingoButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.colorType = DuolingoButtonColor.green,
    this.customColor,
    this.customBottomColor,
    this.customTextColor,
    this.isFullWidth = false,
    this.isCompact = false,
    this.isEnabled = true,
    this.isLoading = false,
    this.padding,
    this.fontSize,
    this.borderRadius,
  });

  @override
  State<DuolingoButton> createState() => _DuolingoButtonState();
}

class _DuolingoButtonState extends State<DuolingoButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (!widget.isEnabled || widget.isLoading || widget.onPressed == null) return;
    setState(() => _isPressed = true);
    HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bg;
    Color bottomBorder;
    Color textCol;

    if (!widget.isEnabled) {
      bg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      bottomBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);
      textCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    } else if (widget.customColor != null) {
      bg = widget.customColor!;
      bottomBorder = widget.customBottomColor ?? bg.withValues(alpha: 0.8);
      textCol = widget.customTextColor ?? Colors.white;
    } else {
      switch (widget.colorType) {
        case DuolingoButtonColor.green:
          bg = KidTheme.primaryGreen;
          bottomBorder = KidTheme.primaryGreenDark;
          textCol = Colors.white;
          break;
        case DuolingoButtonColor.sky:
          bg = KidTheme.playfulSky;
          bottomBorder = const Color(0xFF0284C7);
          textCol = Colors.white;
          break;
        case DuolingoButtonColor.amber:
          bg = KidTheme.playfulAmber;
          bottomBorder = const Color(0xFFD97706);
          textCol = const Color(0xFF78350F);
          break;
        case DuolingoButtonColor.purple:
          bg = KidTheme.playfulPurple;
          bottomBorder = const Color(0xFF7C3AED);
          textCol = Colors.white;
          break;
        case DuolingoButtonColor.coral:
          bg = KidTheme.playfulCoral;
          bottomBorder = const Color(0xFFDC2626);
          textCol = Colors.white;
          break;
        case DuolingoButtonColor.pink:
          bg = const Color(0xFFEC4899);
          bottomBorder = const Color(0xFFBE185D);
          textCol = Colors.white;
          break;
        case DuolingoButtonColor.neutral:
          bg = isDark ? const Color(0xFF222228) : Colors.white;
          bottomBorder = isDark ? const Color(0xFF18181C) : const Color(0xFFCBD5E1);
          textCol = isDark ? Colors.white : const Color(0xFF0F172A);
          break;
      }
    }

    final double bottomThickness = widget.isCompact ? 3.0 : 4.0;
    final double verticalShift = _isPressed && widget.isEnabled ? (widget.isCompact ? 2.0 : 2.5) : 0.0;
    final double activeBottomEdge = _isPressed && widget.isEnabled ? 1.5 : bottomThickness;
    final radius = widget.borderRadius ?? BorderRadius.circular(widget.isCompact ? 16 : 20);

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOutQuad,
      margin: EdgeInsets.only(
        top: verticalShift,
        bottom: bottomThickness - verticalShift,
      ),
      padding: widget.padding ??
          EdgeInsets.symmetric(
            vertical: widget.isCompact ? 10 : 14,
            horizontal: widget.isCompact ? 14 : 20,
          ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: Border.all(color: bg, width: 1.5),
        boxShadow: [
          if (!_isPressed && widget.isEnabled)
            BoxShadow(
              color: bottomBorder,
              blurRadius: 0,
              offset: Offset(0, bottomThickness),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isLoading) ...[
            SizedBox(
              width: widget.isCompact ? 16 : 20,
              height: widget.isCompact ? 16 : 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(textCol),
              ),
            ),
            const SizedBox(width: 8),
          ] else if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: widget.isCompact ? 18 : 22,
              color: textCol,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: widget.fontSize ?? (widget.isCompact ? 13.5 : 16.0),
                  fontWeight: FontWeight.w900,
                  color: textCol,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
      child: widget.isFullWidth ? SizedBox(width: double.infinity, child: content) : content,
    );
  }
}
