import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import 'admin_quick_stock_price_dialog.dart';

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

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du produit avec badge "Populaire" si activé
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: AppColors.surfaceVariant,
                      child: jouet.imagePrincipaleUrl.isNotEmpty
                          ? Image.network(
                              jouet.imagePrincipaleUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, color: AppColors.icon),
                            )
                          : const Icon(Icons.toys_outlined, color: AppColors.primary, size: 36),
                    ),
                  ),
                  if (jouet.estPopulaire)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star, size: 12, color: AppColors.white),
                      ),
                    ),
                ],
              ),
              AppSpacing.horizontalMd,
              // Infos produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            jouet.nom,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: jouet.estActif
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              decoration:
                                  jouet.estActif ? null : TextDecoration.lineThrough,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Bouton étoile populaire toggle
                        IconButton(
                          icon: Icon(
                            jouet.estPopulaire ? Icons.star : Icons.star_border,
                            color: jouet.estPopulaire
                                ? AppColors.accent
                                : AppColors.icon,
                            size: 20,
                          ),
                          tooltip: jouet.estPopulaire
                              ? "Retirer des populaires"
                              : "Marquer comme populaire",
                          onPressed: () async {
                            await jouetRepo.togglePopulaire(
                                jouet.jouetId, !jouet.estPopulaire);
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      jouet.nomCategorieDenormalise.isNotEmpty
                          ? jouet.nomCategorieDenormalise
                          : "Sans catégorie",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          "${jouet.prix.toStringAsFixed(0)} ${jouet.devise}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        // Badge Stock
                        _buildStockBadge(jouet.stockDisponible),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: AppColors.border),
          // Barre d'actions manager
          Row(
            children: [
              // Switch Actif / Inactif
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: jouet.estActif,
                      activeThumbColor: AppColors.success,
                      onChanged: (val) async {
                        await jouetRepo.toggleActif(jouet.jouetId, val);
                      },
                    ),
                  ),
                  Text(
                    jouet.estActif ? "Actif" : "Inactif",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: jouet.estActif
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Bouton ajustement rapide Prix / Stock
              IconButton(
                icon: const Icon(Icons.tune, size: 18, color: AppColors.secondary),
                tooltip: "Modifier Prix / Stock rapidement",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AdminQuickStockPriceDialog(jouet: jouet),
                  );
                },
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              // Bouton Modifier complet
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                tooltip: "Modifier le produit",
                onPressed: onEdit,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              // Bouton Supprimer
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                tooltip: "Supprimer",
                onPressed: () async {
                  final confirmed = await AppDialogs.showConfirmDialog(
                    context: context,
                    title: "Supprimer le produit",
                    message:
                        "Êtes-vous sûr de vouloir supprimer définitivement \"${jouet.nom}\" ?",
                    confirmText: "Supprimer",
                    cancelText: "Annuler",
                    isDanger: true,
                  );
                  if (confirmed == true) {
                    await jouetRepo.supprimerJouet(jouet.jouetId);
                  }
                },
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge(int stockDispo) {
    Color bg;
    Color fg;
    String label;

    if (stockDispo <= 0) {
      bg = AppColors.danger.withValues(alpha: 0.12);
      fg = AppColors.danger;
      label = "Rupture";
    } else if (stockDispo <= 5) {
      bg = AppColors.warning.withValues(alpha: 0.15);
      fg = const Color(0xFFB45309);
      label = "Stock: $stockDispo";
    } else {
      bg = AppColors.success.withValues(alpha: 0.12);
      fg = AppColors.success;
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
