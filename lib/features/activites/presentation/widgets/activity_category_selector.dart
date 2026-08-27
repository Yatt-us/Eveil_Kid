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
          width: 50,
          child: CircularProgressIndicator(),
        ),
      ),

      
      error: (err, stack) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.red.shade200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Erreur lors du chargement des catégories : $err',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),

      data: (categories) {
        if (categories.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.shade200,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Aucune catégorie disponible. '
                    'Veuillez en créer une.',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return _buildCategoryChips(categories);
      },
    );
  }


  Widget _buildCategoryChips(
    List<ActiviteCategorie> categories,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: categories.map((categorie) {
        final bool isSelected =
            selectedCategoryId == categorie.id;

        return ChoiceChip(
       
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (categorie.icon != null) ...[
                Icon(
                  _getIconData(categorie.icon!),
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
              ],

              Text(
                categorie.nom,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.grey.shade700,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),

          selected: isSelected,

          onSelected: (_) {
            onChanged(categorie.id!);
          },


          backgroundColor: Colors.grey.shade200,

          selectedColor: AppColors.primary,

          checkmarkColor: Colors.white,

       
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          elevation: isSelected ? 3 : 0,

          shadowColor: AppColors.primary.withOpacity(0.3),

          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),

          pressElevation: 1,
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