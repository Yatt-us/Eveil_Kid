import 'package:flutter/material.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';

/// Puce de filtre ultra-animée, ludique et parfaitement centrée pour l'espace enfant.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = widget.activeColor ?? KidTheme.primaryGreen;
    final primaryDark = KidTheme.primaryGreenDark;

    // Détermination de l'échelle d'animation
    final double scale = _isPressed ? 0.92 : (widget.isSelected ? 1.04 : 1.0);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    colors: [
                      primaryColor,
                      primaryColor.withValues(alpha: 0.88),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isSelected
                ? null
                : (isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : Colors.white),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.isSelected
                  ? (isDark
                      ? KidTheme.primaryGreenLight.withValues(alpha: 0.6)
                      : primaryColor)
                  : theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.15),
              width: widget.isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: widget.isSelected
                      ? (isDark ? 0.25 : 0.1)
                      : (isDark ? 0.2 : 0.04),
                ),
                blurRadius: widget.isSelected ? 8 : 4,
                offset: widget.isSelected
                    ? const Offset(0, 3)
                    : const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                AnimatedRotation(
                  turns: widget.isSelected ? 0.03 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    widget.icon,
                    size: 17,
                    color: widget.isSelected
                        ? Colors.white
                        : (isDark
                            ? theme.colorScheme.onSurfaceVariant
                            : primaryDark),
                  ),
                ),
                const SizedBox(width: 7),
              ],
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.isSelected ? FontWeight.w800 : FontWeight.w700,
                  color: widget.isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
              if (widget.count != null) ...[
                const SizedBox(width: 7),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? Colors.white.withValues(alpha: 0.28)
                        : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.count}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: widget.isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
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

/// Sélecteur segmenté pour enfant avec curseur animé fluide (animated indicator pill)
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
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.3 : 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
    final double scale = _isPressed ? 0.93 : (widget.isSelected ? 1.02 : 1.0);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? (widget.isDark ? widget.theme.colorScheme.surface : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: widget.isDark ? 0.25 : 0.08,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                AnimatedScale(
                  scale: widget.isSelected ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    widget.icon,
                    size: 16,
                    color: widget.isSelected
                        ? (widget.isDark
                            ? KidTheme.primaryGreenLight
                            : KidTheme.primaryGreenDark)
                        : widget.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: widget.isSelected
                      ? (widget.isDark
                          ? KidTheme.primaryGreenLight
                          : KidTheme.primaryGreenDark)
                      : widget.theme.colorScheme.onSurfaceVariant,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
