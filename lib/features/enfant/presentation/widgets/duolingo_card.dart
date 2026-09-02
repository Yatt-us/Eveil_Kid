import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Conteneur / Carte 3D tactile style Duolingo avec bordure inférieure et enfoncement à la pression.
class DuolingoCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? bottomBorderColor;
  final List<Color>? gradientColors;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double bottomThickness;
  final bool isInteractive;

  const DuolingoCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.bottomBorderColor,
    this.gradientColors,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.bottomThickness = 4.0,
    this.isInteractive = true,
  });

  @override
  State<DuolingoCard> createState() => _DuolingoCardState();
}

class _DuolingoCardState extends State<DuolingoCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap == null || !widget.isInteractive) return;
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

    final bg = widget.backgroundColor ??
        (isDark ? theme.colorScheme.surface : Colors.white);
    final border = widget.borderColor ??
        (isDark ? const Color(0xFF383842) : const Color(0xFFE2E8F0));
    final bottomBorder = widget.bottomBorderColor ??
        (isDark ? const Color(0xFF202026) : const Color(0xFFCBD5E1));

    final double verticalShift =
        _isPressed && widget.onTap != null ? (widget.bottomThickness * 0.6) : 0.0;
    final double activeBottomEdge =
        _isPressed && widget.onTap != null ? (widget.bottomThickness * 0.4) : widget.bottomThickness;

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOutQuad,
      margin: (widget.margin ?? EdgeInsets.zero).add(
        EdgeInsets.only(
          top: verticalShift,
          bottom: widget.bottomThickness - verticalShift,
        ),
      ),
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.gradientColors == null ? bg : null,
        gradient: widget.gradientColors != null
            ? LinearGradient(
                colors: widget.gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: border, width: 1.8),
        boxShadow: [
          if (!_isPressed)
            BoxShadow(
              color: bottomBorder,
              blurRadius: 0,
              offset: Offset(0, widget.bottomThickness),
            ),
        ],
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          fontFamily: 'Roboto',
          fontSize: 14,
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap == null || !widget.isInteractive) {
      return cardContent;
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: cardContent,
    );
  }
}
