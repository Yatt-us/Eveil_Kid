import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import 'admin_deactivate_dialog.dart';
import '../../models/admin_user_model.dart';
import '../../providers/admin_user_provider.dart';

/// Carte pour les utilisateurs Parents (utilisateurs lambda).
class AdminUserCard extends ConsumerWidget {
  final AdminUserModel user;

  const AdminUserCard({
    super.key,
    required this.user,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    try {
      return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
    } catch (_) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(adminUserRepositoryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    final hasEmail = user.email.trim().isNotEmpty;
    final hasPhoto = user.photoUrl != null && user.photoUrl!.trim().isNotEmpty;
    final dateStr = _formatDate(user.dateCreation.toDate());

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.12),
                backgroundImage: hasPhoto ? NetworkImage(user.photoUrl!) : null,
                child: !hasPhoto
                    ? Text(
                        user.nom.isNotEmpty ? user.nom[0].toUpperCase() : 'P',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.nom.isNotEmpty ? user.nom : "Parent sans nom",
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: user.estActif
                            ? (theme.textTheme.bodyLarge?.color ??
                                theme.colorScheme.onSurface)
                            : textSecondary,
                        decoration:
                            user.estActif ? null : TextDecoration.lineThrough,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasEmail) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Switch Statut Actif / Bloqué
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 0.72,
                    child: Switch(
                      value: user.estActif,
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (val) async {
                        if (!val) {
                          final motif = await AdminDeactivateDialog.show(
                            context: context,
                            userName: user.nom,
                            userEmail: user.email,
                            role: user.role,
                          );
                          if (motif != null && context.mounted) {
                            await repo.toggleUserStatus(
                              user.utilisateurId,
                              false,
                              motif: motif,
                            );
                            if (context.mounted) {
                              AppDialogs.showSnackBar(
                                context: context,
                                message: "Le compte a été désactivé.",
                              );
                            }
                          }
                        } else {
                          await repo.toggleUserStatus(user.utilisateurId, true);
                          if (context.mounted) {
                            AppDialogs.showSnackBar(
                              context: context,
                              message: "Le compte a été réactivé.",
                            );
                          }
                        }
                      },
                    ),
                  ),
                  Text(
                    user.estActif ? "Actif" : "Bloqué",
                    style: TextStyle(
                      fontSize: 11.5,
                      color: user.estActif
                          ? const Color(0xFF10B981)
                          : textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: dividerColor),
          const SizedBox(height: 8),

          // Badges d'informations d'utilisation parent
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildMetricChip(
                icon: Icons.child_care_rounded,
                label: "${user.nombreEnfants} enfant${user.nombreEnfants > 1 ? 's' : ''}",
                theme: theme,
                isDark: isDark,
              ),
              if (user.nombreFavoris > 0)
                _buildMetricChip(
                  icon: Icons.favorite_rounded,
                  label: "${user.nombreFavoris} favori${user.nombreFavoris > 1 ? 's' : ''}",
                  theme: theme,
                  isDark: isDark,
                ),
              if (dateStr.isNotEmpty)
                _buildMetricChip(
                  icon: Icons.calendar_today_rounded,
                  label: "Inscrit le $dateStr",
                  theme: theme,
                  isDark: isDark,
                ),
              if (!user.estActif &&
                  user.motifBlocage != null &&
                  user.motifBlocage!.isNotEmpty)
                _buildMetricChip(
                  icon: Icons.info_outline_rounded,
                  label: "Motif : ${user.motifBlocage}",
                  theme: theme,
                  isDark: isDark,
                  isError: true,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
    required bool isDark,
    bool isError = false,
  }) {
    final chipColor = isError ? theme.colorScheme.error : theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isError
            ? theme.colorScheme.error.withValues(alpha: isDark ? 0.2 : 0.1)
            : (isDark
                ? theme.colorScheme.surfaceContainerHighest
                : AppColors.surfaceVariant.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(6),
        border: isError
            ? Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isError ? FontWeight.w600 : FontWeight.w500,
              color: isError
                  ? theme.colorScheme.error
                  : (theme.textTheme.bodySmall?.color ?? AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
