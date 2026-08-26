import 'package:flutter/material.dart';
import 'package:eveilkid/core/constants/AppRadius.dart';

class TutorielSearchField extends StatelessWidget {
  const TutorielSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Rechercher un tutoriel...',
    this.onClear,
    this.onFilterTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surface,
            borderRadius: AppRadius.input,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.4),
              width: 1,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasText)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: theme.colorScheme.onSurfaceVariant,
                      tooltip: 'Effacer',
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                        onClear?.call();
                      },
                    ),
                  if (onFilterTap != null)
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      color: theme.colorScheme.primary,
                      tooltip: 'Filtres',
                      onPressed: onFilterTap,
                    ),
                ],
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}
