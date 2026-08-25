import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';

/// Tuile de catégorie épurée et adaptée aux thèmes clair et sombre.
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

  /// Disposition minimaliste pour mobile
  Widget _buildMinimalMobileTile(
    BuildContext context,
    WidgetRef ref,
    dynamic repo,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
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
                _buildIcon(context, 36),
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
                              ? (theme.textTheme.bodyLarge?.color ??
                                  theme.colorScheme.onSurface)
                              : textSecondary,
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
                        style: TextStyle(
                          fontSize: 11.5,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: theme.iconTheme.color?.withValues(alpha: 0.6) ??
                        AppColors.icon,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    return Row(
      children: [
        _buildIcon(context, 44),
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
                      ? (theme.textTheme.bodyLarge?.color ??
                          theme.colorScheme.onSurface)
                      : textSecondary,
                  decoration:
                      categorie.estActive ? null : TextDecoration.lineThrough,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              _buildCountBadges(context),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Transform.scale(
          scale: 0.72,
          child: Switch(
            value: categorie.estActive,
            activeThumbColor: theme.colorScheme.primary,
            onChanged: (val) async {
              try {
                await repo.toggleActif(categorie.categorieId, val);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: theme.colorScheme.error,
                      content: Text('Erreur : $e'),
                    ),
                  );
                }
              }
            },
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.edit_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          tooltip: "Modifier",
          onPressed: onEdit,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 5),
        ),
        IconButton(
          icon: Icon(
            Icons.delete_outline,
            size: 18,
            color: theme.colorScheme.error,
          ),
          tooltip: "Supprimer",
          onPressed: () => _confirmDelete(context, repo),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 5),
        ),
      ],
    );
  }

  Widget _buildIcon(BuildContext context, double size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasIcon = categorie.iconeUrl != null && categorie.iconeUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: categorie.estActive
            ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1)
            : (isDark
                ? theme.colorScheme.surfaceContainerHighest
                : AppColors.surfaceVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: hasIcon
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                categorie.iconeUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.category_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            )
          : Icon(
              Icons.category_outlined,
              color: theme.colorScheme.primary,
              size: size * 0.55,
            ),
    );
  }

  Widget _buildCountBadges(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);
    final badgeBg = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : AppColors.surfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "${categorie.nombreJouetsDenormalise} produits",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
        ),
        if (categorie.nbTutoriels > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "${categorie.nbTutoriels} tutos",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showActionBottomSheet(
    BuildContext context,
    WidgetRef ref,
    dynamic repo,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
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
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        _buildIcon(context, 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categorie.nom,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.titleSmall?.color ??
                                      theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${categorie.nombreJouetsDenormalise} produit(s) associés",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.7) ??
                                      AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (categorie.estActive
                                    ? const Color(0xFF10B981)
                                    : (isDark ? Colors.white24 : AppColors.textSecondary))
                                .withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            categorie.estActive ? "Active" : "Inactive",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: categorie.estActive
                                  ? const Color(0xFF10B981)
                                  : (isDark ? Colors.white70 : AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 16, color: dividerColor),

                  ListTile(
                    dense: true,
                    leading: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
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

                  ListTile(
                    dense: true,
                    leading: Icon(
                      categorie.estActive
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: categorie.estActive
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF10B981),
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
                              backgroundColor: const Color(0xFF10B981),
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
                              backgroundColor: theme.colorScheme.error,
                              content: Text('Erreur : $e'),
                            ),
                          );
                        }
                      }
                    },
                  ),

                  ListTile(
                    dense: true,
                    leading: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                    title: Text(
                      "Supprimer la catégorie",
                      style: TextStyle(
                        color: theme.colorScheme.error,
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
    final theme = Theme.of(context);

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
              backgroundColor: Color(0xFF10B981),
              content: Text('Catégorie supprimée avec succès.'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: theme.colorScheme.error,
              content: Text('Erreur lors de la suppression : $e'),
            ),
          );
        }
      }
    }
  }
}
