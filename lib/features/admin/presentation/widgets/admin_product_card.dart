import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import 'admin_quick_stock_price_dialog.dart';

/// Carte d'administration de produit épurée et responsive pour le thème clair et sombre.
class AdminProductCard extends ConsumerWidget {
  final Jouet jouet;
  final VoidCallback onEdit;

  const AdminProductCard({
    super.key,
    required this.jouet,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jouetRepo = ref.read(jouetRepositoryProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 540;

        if (isWide) {
          return AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: _buildWideLayout(context, jouetRepo),
          );
        }

        return _buildMinimalMobileTile(context, ref, jouetRepo);
      },
    );
  }

  /// Disposition minimaliste pour mobile
  Widget _buildMinimalMobileTile(
    BuildContext context,
    WidgetRef ref,
    dynamic jouetRepo,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);
    final hasCategory = jouet.nomCategorieDenormalise.trim().isNotEmpty;

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
          onLongPress: () => _showActionBottomSheet(context, ref, jouetRepo),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                _buildThumbnail(context, 44),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              jouet.nom,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: jouet.estActif
                                    ? (theme.textTheme.bodyLarge?.color ??
                                        theme.colorScheme.onSurface)
                                    : textSecondary,
                                decoration: jouet.estActif
                                    ? null
                                    : TextDecoration.lineThrough,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (jouet.estPopulaire)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.star_rounded,
                                size: 15,
                                color: AppColors.warning,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            "${jouet.prix.toStringAsFixed(0)} ${jouet.devise}",
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            " • ",
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                          _buildStockText(context, jouet.stockDisponible),
                          if (hasCategory) ...[
                            Text(
                              " • ",
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                jouet.nomCategorieDenormalise,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
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
                  onPressed: () =>
                      _showActionBottomSheet(context, ref, jouetRepo),
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
  Widget _buildWideLayout(BuildContext context, dynamic jouetRepo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);
    final hasCategory = jouet.nomCategorieDenormalise.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildThumbnail(context, 56),
        AppSpacing.horizontalMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      jouet.nom,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: jouet.estActif
                            ? (theme.textTheme.bodyLarge?.color ??
                                theme.colorScheme.onSurface)
                            : textSecondary,
                        decoration: jouet.estActif
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (jouet.estPopulaire)
                    const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                ],
              ),
              if (hasCategory) ...[
                const SizedBox(height: 2),
                Text(
                  jouet.nomCategorieDenormalise,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    "${jouet.prix.toStringAsFixed(0)} ${jouet.devise}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildStockBadge(context, jouet.stockDisponible),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        _buildWideActions(context, jouetRepo),
      ],
    );
  }

  Widget _buildThumbnail(BuildContext context, double size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: size,
            height: size,
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest
                : AppColors.surfaceVariant,
            child: jouet.imagePrincipaleUrl.isNotEmpty
                ? Image.network(
                    jouet.imagePrincipaleUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.broken_image_rounded,
                      color: theme.iconTheme.color?.withValues(alpha: 0.5) ??
                          AppColors.icon,
                      size: 20,
                    ),
                  )
                : Icon(
                    Icons.toys_outlined,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
          ),
        ),
        if (jouet.estPopulaire)
          Positioned(
            top: 2,
            left: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, size: 8, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildWideActions(BuildContext context, dynamic jouetRepo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.70,
              child: Switch(
                value: jouet.estActif,
                activeThumbColor: theme.colorScheme.primary,
                onChanged: (val) async {
                  try {
                    await jouetRepo.toggleActif(jouet.jouetId, val);
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
            Text(
              jouet.estActif ? "Actif" : "Inactif",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: jouet.estActif
                    ? const Color(0xFF10B981)
                    : textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(
            Icons.tune_rounded,
            size: 18,
            color: theme.colorScheme.secondary,
          ),
          tooltip: "Modifier Prix / Stock",
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AdminQuickStockPriceDialog(jouet: jouet),
            );
          },
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
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
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        ),
        IconButton(
          icon: Icon(
            Icons.delete_outline,
            size: 18,
            color: theme.colorScheme.error,
          ),
          tooltip: "Supprimer",
          onPressed: () => _confirmDelete(context, jouetRepo),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        ),
      ],
    );
  }

  void _showActionBottomSheet(
    BuildContext context,
    WidgetRef ref,
    dynamic jouetRepo,
  ) {
    final theme = Theme.of(context);
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
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
                        _buildThumbnail(context, 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jouet.nom,
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
                                "${jouet.prix.toStringAsFixed(0)} ${jouet.devise} • Stock : ${jouet.stockDisponible}",
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
                        _buildStockBadge(context, jouet.stockDisponible),
                      ],
                    ),
                  ),
                  Divider(height: 16, color: dividerColor),

                  // Option 1 : Modifier
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                    title: const Text(
                      "Modifier le produit",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    subtitle: const Text(
                      "Formulaire complet avec photos, prix et catégories",
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      onEdit();
                    },
                  ),

                  // Option 2 : Ajuster Prix & Stock express
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.tune_rounded, color: theme.colorScheme.secondary),
                    title: const Text(
                      "Ajuster Prix & Stock",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    subtitle: const Text(
                      "Modification rapide des tarifs et quantités",
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      showDialog(
                        context: context,
                        builder: (dCtx) => AdminQuickStockPriceDialog(jouet: jouet),
                      );
                    },
                  ),

                  // Option 3 : Activer / Désactiver
                  ListTile(
                    dense: true,
                    leading: Icon(
                      jouet.estActif
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: jouet.estActif
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF10B981),
                    ),
                    title: Text(
                      jouet.estActif ? "Désactiver le produit" : "Activer le produit",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      jouet.estActif
                          ? "Masquer de la boutique pour les parents"
                          : "Rendre visible et achetable dans la boutique",
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        await jouetRepo.toggleActif(jouet.jouetId, !jouet.estActif);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF10B981),
                              content: Text(
                                jouet.estActif
                                    ? "Produit désactivé (déplacé vers Inactifs)"
                                    : "Produit activé avec succès !",
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

                  // Option 4 : Populaire
                  ListTile(
                    dense: true,
                    leading: Icon(
                      jouet.estPopulaire
                          ? Icons.star_border_rounded
                          : Icons.star_rounded,
                      color: AppColors.warning,
                    ),
                    title: Text(
                      jouet.estPopulaire
                          ? "Retirer des populaires"
                          : "Marquer comme populaire",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      jouet.estPopulaire
                          ? "Ne plus mettre en avant sur la page d'accueil"
                          : "Afficher dans les sélections phares",
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        await jouetRepo.togglePopulaire(jouet.jouetId, !jouet.estPopulaire);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF10B981),
                              content: Text(
                                jouet.estPopulaire
                                    ? "Retiré des populaires"
                                    : "Marqué comme populaire ⭐",
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

                  // Option 5 : Supprimer
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                    title: Text(
                      "Supprimer le produit",
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    subtitle: const Text(
                      "Suppression définitive du catalogue",
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmDelete(context, jouetRepo);
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

  Future<void> _confirmDelete(BuildContext context, dynamic jouetRepo) async {
    final theme = Theme.of(context);

    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: "Supprimer le produit",
      message: "Êtes-vous sûr de vouloir supprimer définitivement \"${jouet.nom}\" ?",
      confirmText: "Supprimer",
      cancelText: "Annuler",
      isDanger: true,
    );
    if (confirmed == true) {
      try {
        await jouetRepo.supprimerJouet(jouet.jouetId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF10B981),
              content: Text('Produit supprimé avec succès.'),
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

  Widget _buildStockText(BuildContext context, int stockDispo) {
    final theme = Theme.of(context);
    final Color color;
    final String label;

    if (stockDispo <= 0) {
      color = theme.colorScheme.error;
      label = "Rupture";
    } else if (stockDispo <= 5) {
      color = const Color(0xFFD97706);
      label = "Stock: $stockDispo";
    } else {
      color = const Color(0xFF10B981);
      label = "Stock: $stockDispo";
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _buildStockBadge(BuildContext context, int stockDispo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color bg;
    final Color fg;
    final String label;

    if (stockDispo <= 0) {
      bg = theme.colorScheme.error.withValues(alpha: isDark ? 0.2 : 0.12);
      fg = theme.colorScheme.error;
      label = "Rupture";
    } else if (stockDispo <= 5) {
      bg = const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.25 : 0.15);
      fg = const Color(0xFFD97706);
      label = "Stock: $stockDispo";
    } else {
      bg = const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.12);
      fg = const Color(0xFF10B981);
      label = "Stock: $stockDispo";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
