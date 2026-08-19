import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:eveilkid/core/constants/AppPadding.dart';
import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/auth/models/utilisateur.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';

/// Page d'accueil placeholder pour les utilisateurs connectés.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Déconnexion',
      message: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      confirmText: 'Se déconnecter',
      cancelText: 'Annuler',
      isDanger: true,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.utilisateur;

    final isAdminOrManager = user?.role == UserRole.admin || user?.role == UserRole.manager;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.child_care_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            AppSpacing.horizontalSm,
            const Text(
              'Éveil Kid',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.danger,
            ),
            onPressed: () => _logout(context, ref),
          ),
          AppSpacing.horizontalXs,
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête Utilisateur & Rôle ──────────────────────────────────────
            _buildUserHeader(context, user),
            AppSpacing.verticalLg,

            // ── Bannière Administration (si Admin / Manager) ────────────────────
            if (isAdminOrManager) ...[
              _buildAdminBanner(context, user?.role),
              AppSpacing.verticalLg,
            ],

            // ── Cartes de Statistiques Rapides ─────────────────────────────────
            _buildQuickStats(user),
            AppSpacing.verticalXl,

            // ── Section Modules & Navigation ───────────────────────────────────
            const Text(
              'Découvrir & Explorer',
              style: AppTextStyles.headingMedium,
            ),
            AppSpacing.verticalSm,

            _buildFeatureGrid(context),
            AppSpacing.verticalXxl,
          ],
        ),
      ),
    );
  }

  /// En-tête avec message de bienvenue et badge de rôle
  Widget _buildUserHeader(BuildContext context, Utilisateur? user) {
    final nom = user?.nom.isNotEmpty == true ? user!.nom : 'Parent';
    final email = user?.email ?? 'Compte connecté';
    final roleLabel = _getRoleLabel(user?.role);
    final roleColor = _getRoleColor(user?.role);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                child: Text(
                  nom.isNotEmpty ? nom[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour, $nom 👋',
                      style: AppTextStyles.headingSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalMd,
          const Divider(height: 1, color: AppColors.border),
          AppSpacing.verticalSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getRoleIcon(user?.role),
                      size: 14,
                      color: roleColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      roleLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: roleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Compte Actif',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bannière d'accès rapide vers le tableau de bord d'administration
  Widget _buildAdminBanner(BuildContext context, UserRole? role) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.indigo,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              AppSpacing.horizontalMd,
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Espace Administration',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Gestion des produits, catégories et utilisateurs',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalMd,
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.admin),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.indigo,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              minimumSize: const Size(double.infinity, 44),
            ),
            icon: const Icon(Icons.dashboard_rounded, size: 18),
            label: const Text(
              'Ouvrir le Tableau de Bord Admin',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Statistiques rapides du compte
  Widget _buildQuickStats(Utilisateur? user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite_rounded,
            iconColor: AppColors.danger,
            value: '${user?.nombreFavoris ?? 0}',
            label: 'Favoris',
          ),
        ),
        AppSpacing.horizontalMd,
        Expanded(
          child: _buildStatCard(
            icon: Icons.child_friendly_rounded,
            iconColor: AppColors.secondary,
            value: '${user?.nombreEnfants ?? 0}',
            label: 'Enfants',
          ),
        ),
        AppSpacing.horizontalMd,
        Expanded(
          child: _buildStatCard(
            icon: Icons.inventory_2_rounded,
            iconColor: AppColors.accent,
            value: '0',
            label: 'Emprunts',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// Grille des modules de fonctionnalités
  Widget _buildFeatureGrid(BuildContext context) {
    final modules = [
      _FeatureModule(
        title: 'Tutoriels & Guides',
        description: 'Vidéos pédagogiques et activités par tranche d’âge.',
        icon: Icons.play_circle_fill_rounded,
        iconColor: AppColors.primary,
        onTap: () => context.push(AppRoutes.tutoriels),
      ),
      _FeatureModule(
        title: 'Catalogue de Jouets',
        description: 'Explorez la sélection de jeux d’éveil disponibles.',
        icon: Icons.toys_rounded,
        iconColor: AppColors.secondary,
        onTap: () {
          AppDialogs.showSnackBar(
            context: context,
            message: 'Le catalogue public sera bientôt disponible !',
          );
        },
      ),
      _FeatureModule(
        title: 'Espace Enfants',
        description: 'Gérez les profils et les centres d’intérêt de vos enfants.',
        icon: Icons.face_rounded,
        iconColor: AppColors.teal,
        onTap: () {
          AppDialogs.showSnackBar(
            context: context,
            message: 'Gestion des profils enfants bientôt disponible.',
          );
        },
      ),
      _FeatureModule(
        title: 'Mes Réservations',
        description: 'Suivez vos commandes d’emprunt et retours de matériel.',
        icon: Icons.calendar_month_rounded,
        iconColor: AppColors.accent,
        onTap: () {
          AppDialogs.showSnackBar(
            context: context,
            message: 'Module de réservations bientôt disponible.',
          );
        },
      ),
    ];

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: modules.length,
      separatorBuilder: (context, index) => AppSpacing.verticalMd,
      itemBuilder: (context, index) {
        final item = modules[index];
        return InkWell(
          onTap: item.onTap,
          borderRadius: AppRadius.card,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.iconColor,
                    size: 26,
                  ),
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.icon,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getRoleLabel(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.manager:
        return 'Manager';
      case UserRole.parent:
      default:
        return 'Parent';
    }
  }

  Color _getRoleColor(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.primary;
      case UserRole.manager:
        return AppColors.secondary;
      case UserRole.parent:
      default:
        return AppColors.teal;
    }
  }

  IconData _getRoleIcon(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return Icons.security_rounded;
      case UserRole.manager:
        return Icons.business_center_rounded;
      case UserRole.parent:
      default:
        return Icons.family_restroom_rounded;
    }
  }
}

class _FeatureModule {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _FeatureModule({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });
}
