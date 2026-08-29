import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/ActivityCategorie/models/activity_category_model.dart';
import 'package:eveilkid/features/ActivityCategorie/providers/activity_category_provider.dart';

class ActivityCategorySelector extends ConsumerWidget {
  final String selectedCategoryId;
  final Function(String) onChanged;

  const ActivityCategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesActivesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return categoriesAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (err, _) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Erreur chargement catégories : $err',
          style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
        ),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF78350F).withValues(alpha: 0.3)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Aucune catégorie disponible. Veuillez en créer une dans la zone admin.',
              style: TextStyle(color: Color(0xFFB45309), fontSize: 12.5),
            ),
          );
        }
        return _buildCategoryChips(categories, theme, isDark);
      },
    );
  }

  Widget _buildCategoryChips(
    List<ActiviteCategorie> categories,
    ThemeData theme,
    bool isDark,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((categorie) {
        final catId = categorie.id ?? '';
        final isSelected = selectedCategoryId == catId;
        final iconName = categorie.icon;

        return FilterChip(
          label: Text(categorie.nom),
          selected: isSelected,
          onSelected: (_) => onChanged(catId),
          backgroundColor: isDark
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : theme.colorScheme.surface,
          selectedColor: theme.colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.15),
          checkmarkColor: theme.colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withValues(alpha: isDark ? 0.3 : 0.15),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          avatar: iconName != null && iconName.isNotEmpty
              ? Icon(
                  _getIconData(iconName),
                  size: 16,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                )
              : null,
        );
      }).toList(),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'abc':
        return Icons.abc;
      case 'numbers':
        return Icons.numbers;
      case 'science':
        return Icons.science_outlined;
      case 'art_track':
        return Icons.palette_outlined;
      case 'music_note':
        return Icons.music_note_outlined;
      case 'psychology':
        return Icons.psychology_outlined;
      case 'sports':
        return Icons.sports_basketball_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}