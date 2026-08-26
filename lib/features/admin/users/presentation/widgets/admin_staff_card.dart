import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import 'admin_deactivate_dialog.dart';
import '../../models/admin_user_model.dart';
import '../../providers/admin_user_provider.dart';

/// Carte épurée pour les membres de l'Équipe & Staff (Super Admin & Manager).
class AdminStaffCard extends ConsumerWidget {
  final AdminUserModel user;

  const AdminStaffCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(adminUserRepositoryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    final isAdmin = user.isAdmin;
    final roleColor = isAdmin ? theme.colorScheme.error : const Color(0xFFD97706);
    final roleLabel = isAdmin ? "Super Admin" : "Manager";
    final roleIcon =
        isAdmin ? Icons.admin_panel_settings_rounded : Icons.storefront_rounded;
    final hasEmail = user.email.trim().isNotEmpty;
    final hasPhoto = user.photoUrl != null && user.photoUrl!.trim().isNotEmpty;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Avatar avec bordure de couleur de rôle
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: roleColor.withValues(alpha: 0.45),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: roleColor.withValues(alpha: isDark ? 0.25 : 0.12),
              backgroundImage: hasPhoto ? NetworkImage(user.photoUrl!) : null,
              child: !hasPhoto
                  ? Text(
                      user.nom.isNotEmpty ? user.nom[0].toUpperCase() : (isAdmin ? 'A' : 'M'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: roleColor,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Informations & Badge de rôle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.nom.isNotEmpty
                            ? user.nom
                            : (isAdmin ? 'Administrateur' : 'Manager'),
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
                    ),
                    const SizedBox(width: 8),

                    // Badge de rôle simple et direct
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7.5, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: roleColor.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(roleIcon, size: 11, color: roleColor),
                          const SizedBox(width: 4),
                          Text(
                            roleLabel,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: roleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                if (!user.estActif &&
                    user.motifBlocage != null &&
                    user.motifBlocage!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Motif : ${user.motifBlocage}",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.error,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action : Activation / Désactivation du compte
          if (!isAdmin)
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
                              message: "Le compte manager a été désactivé.",
                            );
                          }
                        }
                      } else {
                        await repo.toggleUserStatus(user.utilisateurId, true);
                        if (context.mounted) {
                          AppDialogs.showSnackBar(
                            context: context,
                            message: "Le compte manager a été réactivé.",
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
    );
  }
}
