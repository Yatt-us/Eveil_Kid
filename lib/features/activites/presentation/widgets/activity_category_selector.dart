import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/ActivityCategorie/models/activity_category_model.dart';
import 'package:eveilkid/features/ActivityCategorie/providers/activity_category_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


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

    return categoriesAsync.when(
      loading: () => const Center(
        child: SizedBox(
          height: 50,
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Container(
        padding: const EdgeInsets.all(8),
        color: AppColors.danger,
        child: Text(
          'Erreur: $err',
          style: const TextStyle(color: AppColors.danger),
        ),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(8),
            color: Colors.orange.shade50,
            child: const Text(
              'Aucune catégorie disponible. Veuillez en créer une.',
              style: TextStyle(color: Colors.orange),
            ),
          );
        }
        return _buildCategoryChips(categories);
      },
    );
  }

  Widget _buildCategoryChips(List<ActiviteCategorie> categories) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((categorie) {
        final isSelected = selectedCategoryId == categorie.id;
        return FilterChip(
          label: Text(categorie.nom),
          selected: isSelected,
          onSelected: (_) => onChanged(categorie.id!),
          backgroundColor: Colors.grey.shade200,
          selectedColor: AppColors.primary,
          avatar: categorie.icon != null
              ? Icon(
                  _getIconData(categorie.icon!),
                  color: isSelected ? AppColors.primary : Colors.grey,
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
        return Icons.science;
      case 'art_track':
        return Icons.art_track;
      case 'music_note':
        return Icons.music_note;
      case 'psychology':
        return Icons.psychology;
      case 'sports':
        return Icons.sports;
      default:
        return Icons.category;
    }
  }
}