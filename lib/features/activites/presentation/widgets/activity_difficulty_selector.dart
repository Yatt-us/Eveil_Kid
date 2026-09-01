import 'package:flutter/material.dart';

class ActivityDifficultySelector extends StatelessWidget {
  final String selectedDifficulty;
  final Function(String) onChanged;

  const ActivityDifficultySelector({
    super.key,
    required this.selectedDifficulty,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.3 : 0.15);

    final difficulties = [
      {'value': 'facile', 'label': 'Facile', 'icon': Icons.sentiment_satisfied_alt_rounded, 'color': const Color(0xFF16A34A)},
      {'value': 'moyen', 'label': 'Moyen', 'icon': Icons.sentiment_neutral_rounded, 'color': const Color(0xFFD97706)},
      {'value': 'difficile', 'label': 'Difficile', 'icon': Icons.sentiment_very_dissatisfied_rounded, 'color': const Color(0xFFDC2626)},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : theme.colorScheme.surface,
        border: Border.all(color: dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: difficulties.map((diff) {
          final isSelected = selectedDifficulty == diff['value'];
          final color = diff['color'] as Color;

          return Expanded(
            child: Material(
              color: isSelected
                  ? (isDark ? color.withValues(alpha: 0.25) : color.withValues(alpha: 0.12))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                onTap: () => onChanged(diff['value'] as String),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    border: isSelected
                        ? Border.all(color: color.withValues(alpha: 0.5), width: 1.2)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        diff['icon'] as IconData,
                        size: 16,
                        color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        diff['label'] as String,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? color : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}