import 'package:flutter/material.dart';

class ActivityAgeSelector extends StatelessWidget {
  final int minAge;
  final int maxAge;
  final Function(int) onMinAgeChanged;
  final Function(int) onMaxAgeChanged;

  const ActivityAgeSelector({
    super.key,
    required this.minAge,
    required this.maxAge,
    required this.onMinAgeChanged,
    required this.onMaxAgeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.3 : 0.15);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Âge Minimum',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                      : theme.colorScheme.surface,
                  border: Border.all(color: dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: minAge,
                    isExpanded: true,
                    dropdownColor: theme.colorScheme.surface,
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    items: List.generate(12, (index) => index + 1)
                        .map(
                          (age) => DropdownMenuItem(
                            value: age,
                            child: Text(
                              '$age ans',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        if (value <= maxAge) {
                          onMinAgeChanged(value);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('L\'âge minimum ($value ans) ne peut pas dépasser l\'âge maximum ($maxAge ans)'),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Âge Maximum',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                      : theme.colorScheme.surface,
                  border: Border.all(color: dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: maxAge,
                    isExpanded: true,
                    dropdownColor: theme.colorScheme.surface,
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    items: List.generate(12, (index) => index + 1)
                        .map(
                          (age) => DropdownMenuItem(
                            value: age,
                            child: Text(
                              '$age ans',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        if (value >= minAge) {
                          onMaxAgeChanged(value);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('L\'âge maximum ($value ans) ne peut pas être inférieur à l\'âge minimum ($minAge ans)'),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}