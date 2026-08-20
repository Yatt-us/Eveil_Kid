import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';

class AdminCategoryTile extends ConsumerWidget {
  final Categorie categorie;
  final String? parentCategoryName;
  final VoidCallback onEdit;

  const AdminCategoryTile({
    super.key,
    required this.categorie,
    this.parentCategoryName,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(categorieRepositoryProvider);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Icône / Avatar de la catégorie
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: categorie.estActive
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: categorie.iconeUrl != null && categorie.iconeUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      categorie.iconeUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.category_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.category_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
          ),
          AppSpacing.horizontalMd,
          // Nom & détails
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        categorie.nom,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: categorie.estActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          decoration:
                              categorie.estActive ? null : TextDecoration.lineThrough,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (parentCategoryName != null && parentCategoryName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.subdirectory_arrow_right,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        "Parent : $parentCategoryName",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                // Compteurs
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${categorie.nombreJouetsDenormalise} produits",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${categorie.nbTutoriels} tutoriels",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Switch Actif
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: categorie.estActive,
              activeThumbColor: AppColors.success,
              onChanged: (val) async {
                await repo.toggleActif(categorie.categorieId, val);
              },
            ),
          ),
          // Bouton Édition
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
            tooltip: "Modifier la catégorie",
            onPressed: onEdit,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
          // Bouton Suppression
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
            tooltip: "Supprimer la catégorie",
            onPressed: () async {
              final confirmed = await AppDialogs.showConfirmDialog(
                context: context,
                title: "Supprimer la catégorie",
                message:
                    "Êtes-vous sûr de vouloir supprimer la catégorie \"${categorie.nom}\" ?",
                confirmText: "Supprimer",
                cancelText: "Annuler",
                isDanger: true,
              );
              if (confirmed == true) {
                await repo.supprimerCategorie(categorie.categorieId);
              }
            },
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
        ],
      ),
    );
  }
}
