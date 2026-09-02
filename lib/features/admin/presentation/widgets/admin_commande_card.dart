import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/commandes/models/commande_model.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';

class AdminCommandeCard extends StatelessWidget {
  final CommandeModel commande;
  final VoidCallback onTap;
  final Function(String nouveauStatut) onStatusChanged;
  final VoidCallback? onDelete;

  const AdminCommandeCard({
    super.key,
    required this.commande,
    required this.onTap,
    required this.onStatusChanged,
    this.onDelete,
  });

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'livree':
      case 'livrée':
        return AppColors.success;
      case 'en livraison':
      case 'expédiée':
      case 'expediee':
        return const Color(0xFF3B82F6);
      case 'en cours':
      case 'en attente':
      case 'confirmee':
      case 'confirmée':
        return const Color(0xFFF59E0B);
      case 'annulee':
      case 'annulée':
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  void _showStatusDialog(BuildContext context, ThemeData theme, bool isDark) {
    final statuts = [
      'En cours',
      'En livraison',
      'Livrée',
      'Annulée',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Modifier le statut de la commande',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Commande #${commande.id.length > 8 ? commande.id.substring(0, 8).toUpperCase() : commande.id.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ...statuts.map((s) {
                  final isSelected = commande.statut.toLowerCase() == s.toLowerCase();
                  final color = _getStatusColor(s);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: isSelected
                        ? color.withValues(alpha: isDark ? 0.2 : 0.1)
                        : null,
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      s,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? color : theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: color, size: 20)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      if (!isSelected) {
                        onStatusChanged(s);
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.15);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    final statusColor = _getStatusColor(commande.statut);
    final dateStr = DateFormat('dd/MM/yyyy à HH:mm').format(commande.dateCreation);
    final shortId = commande.id.isNotEmpty
        ? (commande.id.length > 8 ? commande.id.substring(0, 8).toUpperCase() : commande.id.toUpperCase())
        : 'EN COURS';

    final totalArticles = commande.articles.fold<int>(0, (sum, a) => sum + a.quantite);
    final isGps = commande.adresseLivraison.startsWith('GPS:');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dividerColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. En-tête : N° Commande + Date + Statut interactif
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#$shortId',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Text(
                            dateStr,
                            style: TextStyle(fontSize: 11.5, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge Statut interactif
                    GestureDetector(
                      onTap: () => _showStatusDialog(context, theme, isDark),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              commande.statut,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(Icons.arrow_drop_down, size: 16, color: statusColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: dividerColor),
                ),

                // 2. Informations de livraison & Téléphone
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isGps ? Icons.gps_fixed_rounded : Icons.location_on_outlined,
                      size: 16,
                      color: isGps ? const Color(0xFF10B981) : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        commande.adresseLivraison.isNotEmpty
                            ? commande.adresseLivraison
                            : 'Adresse non renseignée',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (commande.numeroTelephone != null && commande.numeroTelephone!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 15, color: textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        commande.numeroTelephone!,
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: commande.numeroTelephone!));
                          AppDialogs.showSnackBar(
                            context: context,
                            message: 'Numéro copié !',
                          );
                        },
                        child: Icon(Icons.copy_rounded, size: 14, color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                // 3. Pied de carte : Nombre d'articles + Mode de paiement + Montant total (Design responsive sans image)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Badge Nombre d'articles
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 15,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '$totalArticles article${totalArticles > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            // Badge Mode de paiement
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                commande.modePaiement,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Montant total
                      Text(
                        _formatPrice(commande.montantTotal),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
