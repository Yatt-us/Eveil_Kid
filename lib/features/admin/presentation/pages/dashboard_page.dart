import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/admin/core/models/admin_role.dart';
import 'package:eveilkid/features/admin/core/providers/admin_role_provider.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:eveilkid/features/admin/providers/admin_catalog_controller.dart';
import 'package:eveilkid/features/admin/users/providers/admin_user_provider.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(adminRoleProvider);
    final stats = ref.watch(adminCatalogStatsProvider);
    final userStats = ref.watch(adminUserStatsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);
    final roleColor = currentRole == AdminRole.admin
        ? theme.colorScheme.error
        : const Color(0xFFD97706);

    return AdminScaffold(
      currentRoute: AdminNavRoute.dashboard,
      appBar: AppBar(
        title: Text(
          "Tableau de bord",
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Tooltip(
            message: "Rôle : ${currentRole.label}",
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: isDark ? 0.22 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                currentRole == AdminRole.admin
                    ? Icons.admin_panel_settings_rounded
                    : Icons.storefront_rounded,
                size: 19,
                color: roleColor,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message de bienvenue
            Text(
              "Bonjour, ${currentRole == AdminRole.admin ? 'Administrateur' : 'Manager'} 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentRole == AdminRole.admin
                  ? "Vue globale de l'application et des comptes utilisateurs"
                  : "Résumé et pilotage de votre catalogue et stocks",
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
              ),
            ),
            AppSpacing.verticalLg,

            // Grille responsive des 4 statistiques bilan / KPIs
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final int crossAxisCount;
                final double childAspectRatio;

                if (width >= 720) {
                  crossAxisCount = 4;
                  childAspectRatio = 1.6;
                } else if (width >= 420) {
                  crossAxisCount = 2;
                  childAspectRatio = 1.8;
                } else {
                  crossAxisCount = 2;
                  childAspectRatio = 1.45;
                }

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    AdminStatCard(
                      title: "Produits",
                      value: "${stats.totalProducts}",
                      subtitle: "${stats.activeProducts} actifs",
                      icon: Icons.toys_outlined,
                      color: theme.colorScheme.primary,
                      onTap: () => context.push(AppRoutes.adminProducts),
                    ),
                    AdminStatCard(
                      title: "Catégories",
                      value: "${stats.totalCategories}",
                      subtitle: "Organisées",
                      icon: Icons.category_outlined,
                      color: AppColors.teal,
                      onTap: () => context.push(AppRoutes.adminCategories),
                    ),
                    AdminStatCard(
                      title: "Ruptures",
                      value: "${stats.outOfStockProducts}",
                      subtitle: stats.outOfStockProducts > 0
                          ? "À réapprovisionner"
                          : "Stock optimal",
                      badgeText: stats.outOfStockProducts > 0 ? "Alerte" : null,
                      badgeColor: theme.colorScheme.error,
                      icon: Icons.warning_amber_rounded,
                      color: stats.outOfStockProducts > 0
                          ? theme.colorScheme.error
                          : const Color(0xFF10B981),
                      onTap: () {
                        final notifier =
                            ref.read(adminProductFilterProvider.notifier);
                        notifier.setStockFilter(AdminStockFilter.outOfStock);
                        context.push(AppRoutes.adminProducts);
                      },
                    ),
                    if (currentRole.canManageUsers)
                      AdminStatCard(
                        title: "Utilisateurs",
                        value: "${userStats.totalUsers}",
                        subtitle: "${userStats.activeUsers} actifs",
                        icon: Icons.people_outline,
                        color: const Color(0xFFD97706),
                        onTap: () => context.push(AppRoutes.adminUsers),
                      )
                    else
                      AdminStatCard(
                        title: "Populaires",
                        value: "${stats.popularProducts}",
                        subtitle: "Mis en avant",
                        icon: Icons.star_outline,
                        color: AppColors.warning,
                        onTap: () {
                          final notifier =
                              ref.read(adminProductFilterProvider.notifier);
                          notifier.setPopularOnly(true);
                          context.push(AppRoutes.adminProducts);
                        },
                      ),
                  ],
                );
              },
            ),
            AppSpacing.verticalLg,

            // Section Accès Rapide
            Text(
              "Accès Rapide",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            AppSpacing.verticalSm,

            // Carte Accès Produits
            AppCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              onTap: () => context.push(AppRoutes.adminProducts),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.toys_outlined, color: theme.colorScheme.primary),
                  ),
                  AppSpacing.horizontalMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gestion des Produits",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Consulter, filtrer, prix, stocks et images",
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.iconTheme.color?.withValues(alpha: 0.5) ??
                        AppColors.icon,
                  ),
                ],
              ),
            ),

            // Carte Accès Catégories
            AppCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              onTap: () => context.push(AppRoutes.adminCategories),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.category_outlined, color: AppColors.teal),
                  ),
                  AppSpacing.horizontalMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gestion des Catégories",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Catégories mères, sous-catégories et liaisons",
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.iconTheme.color?.withValues(alpha: 0.5) ??
                        AppColors.icon,
                  ),
                ],
              ),
            ),

            // Carte Gestion des Utilisateurs (Réservée exclusivement à l'Admin)
            if (currentRole.canManageUsers)
              AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                onTap: () => context.push(AppRoutes.adminUsers),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.people_outline, color: theme.colorScheme.error),
                    ),
                    AppSpacing.horizontalMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gestion des Utilisateurs",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Attribution des rôles (Parent, Manager, Admin) et blocage",
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.iconTheme.color?.withValues(alpha: 0.5) ??
                          AppColors.icon,
                    ),
                  ],
                ),
              ),

            // Carte Nouvel Ajout de Produit
            AppCard(
              padding: const EdgeInsets.all(16),
              onTap: () => context.push(AppRoutes.adminProductForm),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_circle_outline, color: Color(0xFFD97706)),
                  ),
                  AppSpacing.horizontalMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ajouter un nouveau produit",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Formulaire d'enregistrement complet",
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.iconTheme.color?.withValues(alpha: 0.5) ??
                        AppColors.icon,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
