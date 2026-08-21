import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import '../../models/admin_user_model.dart';
import '../../providers/admin_user_provider.dart';

/// Carte d'administration d'utilisateur responsive et optimisée.
///
/// Ne gaspille aucun espace si certaines données sont absentes et s'adapte
/// aux différentes largeurs d'écran.
class AdminUserCard extends ConsumerWidget {
  final AdminUserModel user;

  const AdminUserCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(adminUserRepositoryProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isNarrow = width < 340;
        final isWide = width >= 580;

        return AppCard(
          margin: const EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(isNarrow ? 10 : 12),
          child: isWide
              ? _buildWideLayout(context, ref, repo)
              : _buildStandardLayout(context, ref, repo, isNarrow),
        );
      },
    );
  }

  /// Disposition standard (mobile)
  Widget _buildStandardLayout(
    BuildContext context,
    WidgetRef ref,
    dynamic repo,
    bool isNarrow,
  ) {
    final hasEmail = user.email.trim().isNotEmpty;
    final roleColor = _getRoleColor(user.role);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Avatar
            _buildAvatar(22, roleColor),
            SizedBox(width: isNarrow ? 8 : 12),
            // Nom & Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.nom.isNotEmpty ? user.nom : "Utilisateur sans nom",
                          style: TextStyle(
                            fontSize: isNarrow ? 14 : 15,
                            fontWeight: FontWeight.bold,
                            color: user.estActif
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            decoration:
                                user.estActif ? null : TextDecoration.lineThrough,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildRoleBadge(user.role),
                    ],
                  ),
                  if (hasEmail) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 4),
        // Actions
        Row(
          children: [
            // Switch Statut
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 0.72,
                  child: Switch(
                    value: user.estActif,
                    activeThumbColor: AppColors.success,
                    onChanged: (val) async {
                      await repo.toggleUserStatus(user.utilisateurId, val);
                    },
                  ),
                ),
                Text(
                  user.estActif ? "Actif" : "Bloqué",
                  style: TextStyle(
                    fontSize: 12,
                    color: user.estActif
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Bouton Changer de Rôle
            TextButton.icon(
              icon: const Icon(Icons.swap_horiz, size: 16, color: AppColors.primary),
              label: const Text(
                "Changer rôle",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
              ),
              onPressed: () => _showRoleSelectionDialog(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  /// Disposition large (tablette / desktop)
  Widget _buildWideLayout(BuildContext context, WidgetRef ref, dynamic repo) {
    final roleColor = _getRoleColor(user.role);
    final hasEmail = user.email.trim().isNotEmpty;

    return Row(
      children: [
        _buildAvatar(22, roleColor),
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
                      user.nom.isNotEmpty ? user.nom : "Utilisateur sans nom",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: user.estActif
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        decoration:
                            user.estActif ? null : TextDecoration.lineThrough,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildRoleBadge(user.role),
                ],
              ),
              if (hasEmail) ...[
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        AppSpacing.horizontalMd,
        // Switch & Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.75,
              child: Switch(
                value: user.estActif,
                activeThumbColor: AppColors.success,
                onChanged: (val) async {
                  await repo.toggleUserStatus(user.utilisateurId, val);
                },
              ),
            ),
            Text(
              user.estActif ? "Actif" : "Bloqué",
              style: TextStyle(
                fontSize: 12,
                color: user.estActif
                    ? AppColors.success
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              icon: const Icon(Icons.swap_horiz, size: 16, color: AppColors.primary),
              label: const Text(
                "Changer rôle",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showRoleSelectionDialog(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(double radius, Color roleColor) {
    final hasPhoto = user.photoUrl != null && user.photoUrl!.trim().isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: roleColor.withValues(alpha: 0.15),
      backgroundImage: hasPhoto ? NetworkImage(user.photoUrl!) : null,
      child: !hasPhoto
          ? Text(
              user.nom.isNotEmpty ? user.nom[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: radius * 0.75,
                fontWeight: FontWeight.bold,
                color: roleColor,
              ),
            )
          : null,
    );
  }

  void _showRoleSelectionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Modifier le rôle de ${user.nom}",
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoleOption(ctx, ref, 'PARENT', 'Parent (Utilisateur standard)', Icons.family_restroom),
            _buildRoleOption(ctx, ref, 'MANAGER', 'Manager (Gestion catalogue & commandes)', Icons.inventory_2_outlined),
            _buildRoleOption(ctx, ref, 'ADMIN', 'Administrateur (Accès total)', Icons.admin_panel_settings_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context,
    WidgetRef ref,
    String roleKey,
    String title,
    IconData icon,
  ) {
    final isCurrent = user.role.toUpperCase() == roleKey;
    final repo = ref.read(adminUserRepositoryProvider);

    return ListTile(
      leading: Icon(icon, color: _getRoleColor(roleKey)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          color: isCurrent ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isCurrent ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () async {
        if (context.canPop()) context.pop();
        if (!isCurrent) {
          await repo.updateUserRole(user.utilisateurId, roleKey);
          if (context.mounted) {
            AppDialogs.showSnackBar(
              context: context,
              message: "Rôle de ${user.nom} modifié en $roleKey",
            );
          }
        }
      },
    );
  }

  Widget _buildRoleBadge(String role) {
    final color = _getRoleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return AppColors.danger;
      case 'MANAGER':
        return AppColors.primary;
      case 'PARENT':
      default:
        return AppColors.teal;
    }
  }
}
