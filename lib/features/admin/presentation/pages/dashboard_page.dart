import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/features/admin/core/models/admin_role.dart';
import 'package:eveilkid/features/admin/core/providers/admin_role_provider.dart';
import 'package:eveilkid/features/admin/presentation/pages/catalog/admin_category_list_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/catalog/admin_product_form_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/catalog/admin_product_list_page.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/features/admin/providers/admin_catalog_controller.dart';
import 'package:eveilkid/features/admin/users/presentation/pages/admin_user_list_page.dart';
import 'package:eveilkid/features/admin/users/providers/admin_user_provider.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(adminRoleProvider);
    final stats = ref.watch(adminCatalogStatsProvider);
    final userStats = ref.watch(adminUserStatsProvider);

    return AdminScaffold(
      currentRoute: AdminNavRoute.dashboard,
      appBar: AppBar(
        title: Text(
          currentRole == AdminRole.admin
              ? "Tableau de Bord — Admin"
              : "Tableau de Bord — Manager",
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (currentRole == AdminRole.admin
                      ? AppColors.danger
                      : AppColors.primary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  currentRole == AdminRole.admin
                      ? Icons.admin_panel_settings
                      : Icons.storefront,
                  size: 14,
                  color: currentRole == AdminRole.admin
                      ? AppColors.danger
                      : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  currentRole.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: currentRole == AdminRole.admin
                        ? AppColors.danger
                        : AppColors.primary,
                  ),
                ),
              ],
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
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentRole == AdminRole.admin
                  ? "Vue globale de l'application et des comptes utilisateurs"
                  : "Résumé et pilotage de votre catalogue et stocks",
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.verticalLg,

            // Grille des statistiques KPIs
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  title: "Produits",
                  value: "${stats.totalProducts}",
                  subtitle: "${stats.activeProducts} actifs",
                  icon: Icons.toys_outlined,
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const AdminProductListPage(),
                      ),
                    );
                  },
                ),
                _buildStatCard(
                  title: "Catégories",
                  value: "${stats.totalCategories}",
                  subtitle: "Organisées",
                  icon: Icons.category_outlined,
                  color: AppColors.teal,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const AdminCategoryListPage(),
                      ),
                    );
                  },
                ),
                _buildStatCard(
                  title: "Ruptures",
                  value: "${stats.outOfStockProducts}",
                  subtitle: "À réapprovisionner",
                  icon: Icons.warning_amber_rounded,
                  color: stats.outOfStockProducts > 0
                      ? AppColors.danger
                      : AppColors.textSecondary,
                  onTap: () {
                    final notifier =
                        ref.read(adminProductFilterProvider.notifier);
                    notifier.setStockFilter(AdminStockFilter.outOfStock);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const AdminProductListPage(),
                      ),
                    );
                  },
                ),
                if (currentRole.canManageUsers)
                  _buildStatCard(
                    title: "Utilisateurs",
                    value: "${userStats.totalUsers}",
                    subtitle: "${userStats.activeUsers} actifs",
                    icon: Icons.people_outline,
                    color: AppColors.danger,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const AdminUserListPage(),
                        ),
                      );
                    },
                  )
                else
                  _buildStatCard(
                    title: "Populaires",
                    value: "${stats.popularProducts}",
                    subtitle: "Mis en avant",
                    icon: Icons.star_outline,
                    color: AppColors.accent,
                    onTap: () {
                      final notifier =
                          ref.read(adminProductFilterProvider.notifier);
                      notifier.setPopularOnly(true);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const AdminProductListPage(),
                        ),
                      );
                    },
                  ),
              ],
            ),
            AppSpacing.verticalLg,

            // Section Accès Rapide
            const Text(
              "Accès Rapide",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.verticalSm,

            // Carte Accès Produits
            AppCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const AdminProductListPage(),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.toys_outlined, color: AppColors.primary),
                  ),
                  AppSpacing.horizontalMd,
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gestion des Produits",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Consulter, filtrer, prix, stocks et images",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.icon),
                ],
              ),
            ),

            // Carte Accès Catégories
            AppCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const AdminCategoryListPage(),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.category_outlined, color: AppColors.teal),
                  ),
                  AppSpacing.horizontalMd,
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gestion des Catégories",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Catégories mères, sous-catégories et liaisons",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.icon),
                ],
              ),
            ),

            // Carte Gestion des Utilisateurs (Réservée exclusivement à l'Admin)
            if (currentRole.canManageUsers)
              AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const AdminUserListPage(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.people_outline, color: AppColors.danger),
                    ),
                    AppSpacing.horizontalMd,
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gestion des Utilisateurs",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Attribution des rôles (Parent, Manager, Admin) et blocage",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.icon),
                  ],
                ),
              ),

            // Carte Nouvel Ajout de Produit
            AppCard(
              padding: const EdgeInsets.all(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const AdminProductFormPage(),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_circle_outline, color: AppColors.secondary),
                  ),
                  AppSpacing.horizontalMd,
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ajouter un nouveau produit",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Formulaire d'enregistrement complet",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.icon),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
