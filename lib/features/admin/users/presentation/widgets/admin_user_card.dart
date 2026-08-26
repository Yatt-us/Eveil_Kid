import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import '../../models/admin_user_model.dart';
import '../../providers/admin_user_provider.dart';

/// Carte d'administration d'utilisateur responsive et adaptée aux thèmes clair et sombre.
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

    final hasEmail = user.email.trim().isNotEmpty;
    final roleColor = _getRoleColor(context, user.role);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildAvatar(context, 22, roleColor),
            SizedBox(width: isNarrow ? 8 : 12),
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
                      const SizedBox(width: 6),
                      _buildRoleBadge(context, user.role),
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
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(height: 1, color: dividerColor),
        const SizedBox(height: 4),
        Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 0.72,
                  child: Switch(
                    value: user.estActif,
                    activeThumbColor: theme.colorScheme.primary,
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
                        ? const Color(0xFF10B981)
                        : textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            TextButton.icon(
              icon: Icon(Icons.swap_horiz, size: 16, color: theme.colorScheme.primary),
              label: const Text(
                "Changer rôle",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                foregroundColor: theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    final roleColor = _getRoleColor(context, user.role);
    final hasEmail = user.email.trim().isNotEmpty;

    return Row(
      children: [
        _buildAvatar(context, 22, roleColor),
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
                  _buildRoleBadge(context, user.role),
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
            ],
          ),
        ),
        AppSpacing.horizontalMd,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.75,
              child: Switch(
                value: user.estActif,
                activeThumbColor: theme.colorScheme.primary,
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
                    ? const Color(0xFF10B981)
                    : textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              icon: Icon(Icons.swap_horiz, size: 16, color: theme.colorScheme.primary),
              label: const Text(
                "Changer rôle",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
              onPressed: () => _showRoleSelectionDialog(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, double radius, Color roleColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasPhoto = user.photoUrl != null && user.photoUrl!.trim().isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: roleColor.withValues(alpha: isDark ? 0.25 : 0.15),
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
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Modifier le rôle de ${user.nom}",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleMedium?.color ??
                theme.colorScheme.onSurface,
          ),
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
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: _getRoleColor(context, roleKey)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          color: isCurrent
              ? theme.colorScheme.primary
              : (theme.textTheme.bodyMedium?.color ??
                  theme.colorScheme.onSurface),
        ),
      ),
      trailing: isCurrent ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
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

  Widget _buildRoleBadge(BuildContext context, String role) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _getRoleColor(context, role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
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

  Color _getRoleColor(BuildContext context, String role) {
    final theme = Theme.of(context);

    switch (role.toUpperCase()) {
      case 'ADMIN':
        return theme.colorScheme.error;
      case 'MANAGER':
        return const Color(0xFFD97706);
      case 'PARENT':
      default:
        return theme.colorScheme.primary;
    }
  }
}
