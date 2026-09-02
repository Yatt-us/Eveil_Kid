import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';

enum DuolingoTileState {
  neutral,
  selected,
  correct,
  incorrect,
  disabled,
}

class DuolingoOptionTile extends StatefulWidget {
  final String text;
  final String? badgeText;
  final IconData? badgeIcon;
  final String? imageUrl;
  final DuolingoTileState state;
  final VoidCallback? onTap;
  final bool isCompact;
  final EdgeInsetsGeometry? padding;
  final Color? customBackgroundColor;
  final Color? customBorderColor;
  final Color? customBottomBorderColor;
  final Color? customTextColor;
  final Color? customBadgeColor;
  final Color? customBadgeTextColor;

  const DuolingoOptionTile({
    super.key,
    required this.text,
    this.badgeText,
    this.badgeIcon,
    this.imageUrl,
    this.state = DuolingoTileState.neutral,
    this.onTap,
    this.isCompact = false,
    this.padding,
    this.customBackgroundColor,
    this.customBorderColor,
    this.customBottomBorderColor,
    this.customTextColor,
    this.customBadgeColor,
    this.customBadgeTextColor,
  });

  @override
  State<DuolingoOptionTile> createState() => _DuolingoOptionTileState();
}

class _DuolingoOptionTileState extends State<DuolingoOptionTile>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.state == DuolingoTileState.disabled || widget.onTap == null) return;
    setState(() => _isPressed = true);
    _animController.forward();
    HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
    _animController.reverse();
  }

  void _handleTapCancel() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Palette de styles selon l'état Duolingo avec fort contraste garanti
    Color backgroundColor;
    Color borderColor;
    Color bottomBorderColor;
    Color textColor;
    Color badgeBgColor;
    Color badgeTextColor;

    switch (widget.state) {
      case DuolingoTileState.selected:
        backgroundColor = isDark
            ? const Color(0xFF0C4A6E).withValues(alpha: 0.45)
            : const Color(0xFFE0F2FE);
        borderColor = KidTheme.playfulSky;
        bottomBorderColor = const Color(0xFF0284C7);
        textColor = isDark ? Colors.white : const Color(0xFF0369A1);
        badgeBgColor = KidTheme.playfulSky;
        badgeTextColor = Colors.white;
        break;

      case DuolingoTileState.correct:
        backgroundColor = isDark
            ? const Color(0xFF14532D).withValues(alpha: 0.45)
            : const Color(0xFFDCFCE7);
        borderColor = const Color(0xFF22C55E);
        bottomBorderColor = const Color(0xFF15803D);
        textColor = isDark ? const Color(0xFF86EFAC) : const Color(0xFF14532D);
        badgeBgColor = const Color(0xFF22C55E);
        badgeTextColor = Colors.white;
        break;

      case DuolingoTileState.incorrect:
        backgroundColor = isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.45)
            : const Color(0xFFFEE2E2);
        borderColor = const Color(0xFFEF4444);
        bottomBorderColor = const Color(0xFFB91C1C);
        textColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B);
        badgeBgColor = const Color(0xFFEF4444);
        badgeTextColor = Colors.white;
        break;

      case DuolingoTileState.disabled:
        backgroundColor = isDark
            ? const Color(0xFF2E2E36)
            : const Color(0xFFF1F5F9);
        borderColor = isDark ? const Color(0xFF383842) : const Color(0xFFE2E8F0);
        bottomBorderColor = isDark ? const Color(0xFF1E1E24) : const Color(0xFFCBD5E1);
        textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        badgeBgColor = isDark ? const Color(0xFF383842) : const Color(0xFFE2E8F0);
        badgeTextColor = textColor;
        break;

      case DuolingoTileState.neutral:
        backgroundColor = isDark ? const Color(0xFF222228) : Colors.white;
        borderColor = isDark ? const Color(0xFF383842) : const Color(0xFFCBD5E1);
        bottomBorderColor = isDark ? const Color(0xFF18181C) : const Color(0xFF94A3B8);
        textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        badgeBgColor = isDark
            ? const Color(0xFF2E2E36)
            : const Color(0xFFF1F5F9);
        badgeTextColor = isDark ? const Color(0xFF86EFAC) : const Color(0xFF16A34A);
        break;
    }

    if (widget.customBackgroundColor != null) {
      backgroundColor = widget.customBackgroundColor!;
    }
    if (widget.customBorderColor != null) {
      borderColor = widget.customBorderColor!;
    }
    if (widget.customBottomBorderColor != null) {
      bottomBorderColor = widget.customBottomBorderColor!;
    }
    if (widget.customTextColor != null) {
      textColor = widget.customTextColor!;
    }
    if (widget.customBadgeColor != null) {
      badgeBgColor = widget.customBadgeColor!;
    }
    if (widget.customBadgeTextColor != null) {
      badgeTextColor = widget.customBadgeTextColor!;
    }

    final double bottomEdgeThickness = _isPressed ? 1.5 : (widget.isCompact ? 3.0 : 4.0);
    final double verticalShift = _isPressed ? (widget.isCompact ? 2.0 : 2.5) : 0.0;

    final String displayText = widget.text.trim().isNotEmpty
        ? widget.text.trim()
        : (widget.badgeText != null ? 'Option ${widget.badgeText}' : 'Option');

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutQuad,
          margin: EdgeInsets.only(
            top: verticalShift,
            bottom: (widget.isCompact ? 2.5 : 3.0) - verticalShift,
          ),
          padding: widget.padding ??
              EdgeInsets.symmetric(
                horizontal: widget.isCompact ? 14 : 18,
                vertical: widget.isCompact ? 12 : 16,
              ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.isCompact ? 16 : 20),
            border: Border.all(
              color: borderColor,
              width: 2.0,
            ),
            boxShadow: [
              if (!_isPressed)
                BoxShadow(
                  color: bottomBorderColor.withValues(alpha: isDark ? 0.45 : 0.4),
                  blurRadius: 0,
                  offset: Offset(0, bottomEdgeThickness + 1.0),
                ),
            ],
          ),
          child: Row(
            children: [
              // Badge optionnel (A, B, C ou 1, 2, 3 ou Icône)
              if (widget.badgeText != null || widget.badgeIcon != null) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: widget.isCompact ? 28 : 34,
                  height: widget.isCompact ? 28 : 34,
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(widget.isCompact ? 10 : 12),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: widget.badgeIcon != null
                        ? Icon(
                            widget.badgeIcon,
                            size: widget.isCompact ? 16 : 18,
                            color: badgeTextColor,
                          )
                        : Text(
                            widget.badgeText!,
                            style: TextStyle(
                              fontSize: widget.isCompact ? 12.5 : 14,
                              fontWeight: FontWeight.w900,
                              color: badgeTextColor,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: widget.isCompact ? 10 : 14),
              ],

              // Vignette Image si disponible
              if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.imageUrl!,
                    width: widget.isCompact ? 40 : 54,
                    height: widget.isCompact ? 40 : 54,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                SizedBox(width: widget.isCompact ? 10 : 14),
              ],

              // Texte principal de l'option (avec contraste élevé garanti)
              Expanded(
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: widget.isCompact ? 14.5 : 16.5,
                    fontWeight: widget.state == DuolingoTileState.selected ||
                            widget.state == DuolingoTileState.correct
                        ? FontWeight.w900
                        : FontWeight.w800,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ),

              // Indicateur de statut (Correct / Erreur / Check)
              if (widget.state == DuolingoTileState.correct) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ] else if (widget.state == DuolingoTileState.incorrect) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ] else if (widget.state == DuolingoTileState.selected) ...[
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: KidTheme.playfulSky,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
