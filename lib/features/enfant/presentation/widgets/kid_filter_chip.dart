import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';

/// Puce de filtre 3D ultra-tactile style Duolingo avec enfoncement physique et bordure 3D.
class KidFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final int? count;
  final Color? activeColor;

  const KidFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.count,
    this.activeColor,
  });

  @override
  State<KidFilterChip> createState() => _KidFilterChipState();
}

class _KidFilterChipState extends State<KidFilterChip> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = widget.activeColor ?? KidTheme.primaryGreen;
    final primaryDark = KidTheme.primaryGreenDark;

    Color bg;
    Color borderColor;
    Color bottomBorderColor;
    Color textColor;

    if (widget.isSelected) {
      bg = primaryColor;
      borderColor = primaryColor;
      bottomBorderColor = primaryDark;
      textColor = Colors.white;
    } else {
      bg = isDark ? const Color(0xFF222228) : Colors.white;
      borderColor = isDark ? const Color(0xFF383842) : const Color(0xFFE2E8F0);
      bottomBorderColor = isDark ? const Color(0xFF18181C) : const Color(0xFFCBD5E1);
      textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    }

    const double bottomThickness = 3.0;
    final double verticalShift = _isPressed ? 2.0 : 0.0;
    final double activeBottomEdge = _isPressed ? 1.0 : bottomThickness;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutQuad,
        margin: EdgeInsets.only(
          top: verticalShift,
          bottom: bottomThickness - verticalShift,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: bottomBorderColor,
                blurRadius: 0,
                offset: const Offset(0, bottomThickness),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 17,
                color: widget.isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFF86EFAC) : primaryDark),
              ),
              const SizedBox(width: 7),
            ],
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: -0.2,
              ),
            ),
            if (widget.count != null) ...[
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? Colors.white.withValues(alpha: 0.28)
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.count}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: widget.isSelected
                        ? Colors.white
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sélecteur segmenté pour enfant 3D avec boutons physiques tactiles style Duolingo
class KidFilterSegmentBar extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<IconData>? icons;

  const KidFilterSegmentBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E24)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF383842) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;
          final icon = icons != null && index < icons!.length ? icons![index] : null;

          return Expanded(
            child: _SegmentItem(
              label: items[index],
              icon: icon,
              isSelected: isSelected,
              onTap: () => onSelected(index),
              isDark: isDark,
              theme: theme,
            ),
          );
        }),
      ),
    );
  }
}

class _SegmentItem extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final ThemeData theme;

  const _SegmentItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.theme,
  });

  @override
  State<_SegmentItem> createState() => _SegmentItemState();
}

class _SegmentItemState extends State<_SegmentItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bottomThickness = 2.5;
    final double verticalShift = _isPressed ? 1.5 : 0.0;
    final double activeBottomEdge = _isPressed ? 1.0 : bottomThickness;

    Color bg;
    Color bottomBorder;
    Color textCol;

    if (widget.isSelected) {
      bg = widget.isDark ? const Color(0xFF2A2A34) : Colors.white;
      bottomBorder = widget.isDark ? const Color(0xFF16161A) : const Color(0xFFCBD5E1);
      textCol = widget.isDark ? Colors.white : KidTheme.primaryGreenDark;
    } else {
      bg = Colors.transparent;
      bottomBorder = Colors.transparent;
      textCol = widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    }

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutQuad,
        margin: EdgeInsets.only(
          top: verticalShift,
          bottom: bottomThickness - verticalShift,
        ),
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: widget.isSelected
              ? Border.all(color: bg, width: 1.0)
              : null,
          boxShadow: [
            if (widget.isSelected && !_isPressed)
              BoxShadow(
                color: bottomBorder,
                blurRadius: 0,
                offset: const Offset(0, bottomThickness),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 16,
                color: textCol,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: widget.isSelected ? FontWeight.w900 : FontWeight.w700,
                color: textCol,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
