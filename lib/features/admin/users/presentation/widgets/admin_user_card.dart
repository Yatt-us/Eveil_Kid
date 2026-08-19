import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import '../../models/admin_user_model.dart';
import '../../providers/admin_user_provider.dart';

class AdminUserCard extends ConsumerWidget {
  final AdminUserModel user;

  const AdminUserCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(adminUserRepositoryProvider);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: _getRoleColor(user.role).withValues(alpha: 0.15),
                backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null || user.photoUrl!.isEmpty
                    ? Text(
                        user.nom.isNotEmpty ? user.nom[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getRoleColor(user.role),
                        ),
                      )
                    : null,
              ),
              AppSpacing.horizontalMd,
              // Nom & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.nom,
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
                        _buildRoleBadge(user.role),
                      ],
                    ),
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
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: AppColors.border),
          // Actions: Changer de rôle & Switch statut
          Row(
            children: [
              // Switch Actif
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
                user.estActif ? "Compte actif" : "Compte bloqué",
                style: TextStyle(
                  fontSize: 12,
                  color: user.estActif
                      ? AppColors.success
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
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
                onPressed: () {
                  _showRoleSelectionDialog(context, ref);
                },
              ),
            ],
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
