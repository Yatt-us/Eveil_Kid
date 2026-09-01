import 'package:flutter/material.dart';
import 'package:eveilkid/core/constants/app_colors.dart';

class StatutCommandeWidget extends StatelessWidget {
  final String statut;

  const StatutCommandeWidget({super.key, required this.statut});

  static Color getStatusColor(String statut) {
    final s = statut.trim().toLowerCase();
    switch (s) {
      case 'livree':
      case 'livrée':
      case 'delivered':
        return AppColors.success;
      case 'expediee':
      case 'expédiée':
      case 'en livraison':
      case 'shipped':
        return AppColors.info;
      case 'en preparation':
      case 'en préparation':
      case 'en_preparation':
      case 'confirmee':
      case 'confirmée':
        return AppColors.primary;
      case 'en attente':
      case 'en_attente':
      case 'en cours':
      case 'en_cours':
      case 'pending':
        return AppColors.warning;
      case 'annulee':
      case 'annulée':
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  static String getStatusLabel(String statut) {
    final s = statut.trim().toLowerCase();
    switch (s) {
      case 'livree':
      case 'livrée':
      case 'delivered':
        return 'Livrée';
      case 'expediee':
      case 'expédiée':
      case 'en livraison':
      case 'shipped':
        return 'Expédiée';
      case 'en preparation':
      case 'en préparation':
      case 'en_preparation':
        return 'En préparation';
      case 'confirmee':
      case 'confirmée':
        return 'Confirmée';
      case 'en attente':
      case 'en_attente':
      case 'pending':
        return 'En attente';
      case 'en cours':
      case 'en_cours':
        return 'En cours';
      case 'annulee':
      case 'annulée':
      case 'cancelled':
        return 'Annulée';
      default:
        return statut;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = getStatusColor(statut);
    final label = getStatusLabel(statut);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.5 : 0.35),
          width: 1.0,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class SuiviCommandeChronologie extends StatelessWidget {
  final String statutActuel;

  const SuiviCommandeChronologie({super.key, required this.statutActuel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary);
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.3 : 0.15);

    final etapes = [
      {'cle': 'en_attente', 'libelle': 'Commande validée', 'icon': Icons.receipt_long_rounded},
      {'cle': 'confirmee', 'libelle': 'Confirmée', 'icon': Icons.verified_rounded},
      {'cle': 'en_preparation', 'libelle': 'En préparation', 'icon': Icons.inventory_2_rounded},
      {'cle': 'expediee', 'libelle': 'En cours de livraison', 'icon': Icons.local_shipping_rounded},
      {'cle': 'livree', 'libelle': 'Livrée avec succès', 'icon': Icons.task_alt_rounded},
    ];

    final s = statutActuel.trim().toLowerCase();
    int indexActuel = 0;
    if (s == 'confirmee' || s == 'confirmée') {
      indexActuel = 1;
    } else if (s == 'en preparation' || s == 'en préparation' || s == 'en_preparation') {
      indexActuel = 2;
    } else if (s == 'expediee' || s == 'expédiée' || s == 'en livraison') {
      indexActuel = 3;
    } else if (s == 'livree' || s == 'livrée' || s == 'delivered') {
      indexActuel = 4;
    } else if (s == 'annulee' || s == 'annulée' || s == 'cancelled') {
      indexActuel = -1;
    }

    if (indexActuel == -1) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: isDark ? 0.18 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: AppColors.danger, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cette commande a été annulée.',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(etapes.length, (index) {
        final bool estFait = index <= indexActuel;
        final bool estEnCours = index == indexActuel;
        final item = etapes[index];

        final Color stepColor = estFait
            ? (index == 4 ? AppColors.success : theme.colorScheme.primary)
            : textSecondary.withValues(alpha: 0.4);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: estFait
                          ? stepColor.withValues(alpha: isDark ? 0.25 : 0.12)
                          : Colors.transparent,
                      border: Border.all(
                        color: stepColor,
                        width: estEnCours ? 2.0 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        estFait ? (item['icon'] as IconData) : Icons.circle,
                        color: stepColor,
                        size: estFait ? 16 : 8,
                      ),
                    ),
                  ),
                  if (index < etapes.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: index < indexActuel ? stepColor : dividerColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3, bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['libelle'] as String,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: estEnCours
                              ? FontWeight.w800
                              : (estFait ? FontWeight.w600 : FontWeight.w500),
                          color: estFait
                              ? (theme.textTheme.titleSmall?.color ?? theme.colorScheme.onSurface)
                              : textSecondary,
                        ),
                      ),
                      if (estEnCours)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Étape en cours',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}