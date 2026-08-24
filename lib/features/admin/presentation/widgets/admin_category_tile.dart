import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';

/// Tuile de catégorie épurée et ultra-minimaliste pour l'espace administration.
///
/// Affiche les éléments de manière compacte sur mobile.
/// Un simple appui ouvre l'édition, et un appui long affiche le menu contextuel.
class AdminCategoryTile extends ConsumerWidget {
  final Categorie categorie;
  final VoidCallback onEdit;

  const AdminCategoryTile({
    super.key,
    required this.categorie,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(categorieRepositoryProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 540;

        if (isWide) {
          return AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: _buildWideLayout(context, repo),
          );
        }

        return _buildMinimalMobileTile(context, ref, repo);
      },
    );
  }

  /// Disposition minimaliste pour mobile (hauteur ~56px)
  Widget _buildMinimalMobileTile(
    BuildContext context,
    WidgetRef ref,
    dynamic repo,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onEdit,
          onLongPress: () => _showActionBottomSheet(context, ref, repo),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                _buildIcon(36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        categorie.nom,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: categorie.estActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          decoration: categorie.estActive
                              ? null
                              : TextDecoration.lineThrough,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${categorie.nombreJouetsDenormalise} produit${categorie.nombreJouetsDenormalise > 1 ? 's' : ''}",
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: AppColors.icon,
                  ),
                  tooltip: "Actions",
                  onPressed: () => _showActionBottomSheet(context, ref, repo),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Disposition large (tablette / desktop)
  Widget _buildWideLayout(BuildContext context, dynamic repo) {
    return Row(
      children: [
        _buildIcon(44),
        AppSpacing.horizontalMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
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
              const SizedBox(height: 4),
              _buildCountBadges(),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Switch Actif
        Transform.scale(
          scale: 0.72,
          child: Switch(
            value: categorie.estActive,
            activeThumbColor: AppColors.success,
            onChanged: (val) async {
              try {
                await repo.toggleActif(categorie.categorieId, val);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.danger,
                      content: Text('Erreur : $e'),
                    ),
                  );
                }
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
          tooltip: "Modifier",
          onPressed: onEdit,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 5),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
          tooltip: "Supprimer",
          onPressed: () => _confirmDelete(context, repo),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 5),
        ),
      ],
    );
  }

  Widget _buildIcon(double size) {
    final hasIcon = categorie.iconeUrl != null && categorie.iconeUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: categorie.estActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: hasIcon
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                categorie.iconeUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.category_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            )
          : Icon(
              Icons.category_outlined,
              color: AppColors.primary,
              size: size * 0.55,
            ),
    );
  }

  Widget _buildCountBadges() {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
        if (categorie.nbTutoriels > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "${categorie.nbTutoriels} tutos",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Tiroir d'actions modal affiché lors d'un appui long sur une catégorie
  void _showActionBottomSheet(
    BuildContext context,
    WidgetRef ref,
    dynamic repo,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Poignée du drawer
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // En-tête de la catégorie
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        _buildIcon(40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categorie.nom,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${categorie.nombreJouetsDenormalise} produit(s) associés",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (categorie.estActive ? AppColors.success : AppColors.textSecondary)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            categorie.estActive ? "Active" : "Inactive",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: categorie.estActive ? AppColors.success : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 16, color: AppColors.border),

                  // Option 1 : Modifier
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                    title: const Text(
                      "Modifier la catégorie",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    subtitle: const Text(
                      "Renommer ou changer l'illustration",
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      onEdit();
                    },
                  ),

                  // Option 2 : Activer / Désactiver
                  ListTile(
                    dense: true,
                    leading: Icon(
                      categorie.estActive
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: categorie.estActive ? AppColors.warning : AppColors.success,
                    ),
                    title: Text(
                      categorie.estActive ? "Désactiver la catégorie" : "Activer la catégorie",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      categorie.estActive
                          ? "Masquer pour les utilisateurs de l'application"
                          : "Rendre visible dans le catalogue",
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        await repo.toggleActif(categorie.categorieId, !categorie.estActive);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.success,
                              content: Text(
                                categorie.estActive
                                    ? "Catégorie désactivée (déplacée vers Inactives)"
                                    : "Catégorie activée avec succès !",
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.danger,
                              content: Text('Erreur : $e'),
                            ),
                          );
                        }
                      }
                    },
                  ),

                  // Option 3 : Supprimer
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                    title: const Text(
                      "Supprimer la catégorie",
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    subtitle: const Text(
                      "Suppression définitive de la catégorie",
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmDelete(context, repo);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, dynamic repo) async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: "Supprimer la catégorie",
      message:
          "Êtes-vous sûr de vouloir supprimer définitivement la catégorie \"${categorie.nom}\" ?",
      confirmText: "Supprimer",
      cancelText: "Annuler",
      isDanger: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await repo.supprimerCategorie(categorie.categorieId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('Catégorie supprimée avec succès.'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.danger,
              content: Text('Erreur lors de la suppression : $e'),
            ),
          );
        }
      }
    }
  }
}
