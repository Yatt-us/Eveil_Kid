import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_product_card.dart';
import 'package:eveilkid/features/admin/providers/admin_catalog_controller.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/shared/widgets/app_chip.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

class AdminProductListPage extends ConsumerWidget {
  const AdminProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredProductsAsync = ref.watch(adminFilteredProductsProvider);
    final filterState = ref.watch(adminProductFilterProvider);
    final filterNotifier = ref.read(adminProductFilterProvider.notifier);
    final categoriesAsync = ref.watch(categoriesAdminStreamProvider);
    final List<Categorie> categories = categoriesAsync.value ?? [];
    final stats = ref.watch(adminCatalogStatsProvider);

    return AdminScaffold(
      currentRoute: AdminNavRoute.products,
      appBar: AppBar(
        title: const Text(
          "Gestion des Produits",
          style: TextStyle(
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
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: "Actualiser",
            onPressed: () {
              ref.invalidate(jouetsAdminStreamProvider);
              ref.invalidate(categoriesAdminStreamProvider);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                _buildKpiBadge(
                  label: "Total",
                  value: "${stats.totalProducts}",
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _buildKpiBadge(
                  label: "Actifs",
                  value: "${stats.activeProducts}",
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _buildKpiBadge(
                  label: "Rupture",
                  value: "${stats.outOfStockProducts}",
                  color: stats.outOfStockProducts > 0
                      ? AppColors.danger
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                _buildKpiBadge(
                  label: "Populaires",
                  value: "${stats.popularProducts}",
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AppSearchBar(
              hintText: "Rechercher un produit (nom, description)...",
              onChanged: (query) => filterNotifier.setSearchQuery(query),
            ),
          ),

          // Filtres par Chips horizontaux
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // Filtre Tous
                AppChip(
                  label: "Tous",
                  variant: !filterState.hasActiveFilters
                      ? AppChipVariant.primary
                      : AppChipVariant.neutral,
                  onTap: () => filterNotifier.resetFilters(),
                ),
                const SizedBox(width: 8),

                // Filtre Populaires ⭐
                AppChip(
                  label: "⭐ Populaires",
                  variant: filterState.popularOnly
                      ? AppChipVariant.warning
                      : AppChipVariant.neutral,
                  onTap: () =>
                      filterNotifier.setPopularOnly(!filterState.popularOnly),
                ),
                const SizedBox(width: 8),

                // Filtre Ruptures
                AppChip(
                  label: "Rupture de stock",
                  variant: filterState.stockFilter == AdminStockFilter.outOfStock
                      ? AppChipVariant.danger
                      : AppChipVariant.neutral,
                  onTap: () {
                    filterNotifier.setStockFilter(
                      filterState.stockFilter == AdminStockFilter.outOfStock
                          ? AdminStockFilter.all
                          : AdminStockFilter.outOfStock,
                    );
                  },
                ),
                const SizedBox(width: 8),

                // Filtre Stock Bas
                AppChip(
                  label: "Stock faible (≤ 5)",
                  variant: filterState.stockFilter == AdminStockFilter.lowStock
                      ? AppChipVariant.warning
                      : AppChipVariant.neutral,
                  onTap: () {
                    filterNotifier.setStockFilter(
                      filterState.stockFilter == AdminStockFilter.lowStock
                          ? AdminStockFilter.all
                          : AdminStockFilter.lowStock,
                    );
                  },
                ),
                const SizedBox(width: 8),

                // Filtre Inactifs
                AppChip(
                  label: "Inactifs",
                  variant: filterState.activeFilter == AdminActiveFilter.inactiveOnly
                      ? AppChipVariant.primary
                      : AppChipVariant.neutral,
                  onTap: () {
                    filterNotifier.setActiveFilter(
                      filterState.activeFilter == AdminActiveFilter.inactiveOnly
                          ? AdminActiveFilter.all
                          : AdminActiveFilter.inactiveOnly,
                    );
                  },
                ),
                const SizedBox(width: 8),

                // Filtres par catégorie
                ...categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppChip(
                      label: cat.nom,
                      variant: filterState.selectedCategoryId == cat.categorieId
                          ? AppChipVariant.primary
                          : AppChipVariant.neutral,
                      onTap: () {
                        filterNotifier.setCategory(
                          filterState.selectedCategoryId == cat.categorieId
                              ? null
                              : cat.categorieId,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.verticalSm,

          // Liste des produits
          Expanded(
            child: filteredProductsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => AppErrorState(
                title: "Erreur de chargement",
                message: "Impossible de charger les produits : $err",
                onRetry: () => ref.refresh(jouetsAdminStreamProvider),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.search_off,
                    title: filterState.hasActiveFilters
                        ? "Aucun résultat trouvé"
                        : "Catalogue vide",
                    description: filterState.hasActiveFilters
                        ? "Aucun produit ne correspond à vos critères de recherche."
                        : "Vous n'avez pas encore ajouté de produit.",
                    actionText: filterState.hasActiveFilters
                        ? "Réinitialiser les filtres"
                        : "Ajouter un produit",
                    onActionPressed: filterState.hasActiveFilters
                        ? () => filterNotifier.resetFilters()
                        : () => context.push(AppRoutes.adminProductForm),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(jouetsAdminStreamProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final jouet = products[index];
                      return AdminProductCard(
                        jouet: jouet,
                        onEdit: () => context.push(
                          AppRoutes.adminProductForm,
                          extra: jouet,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text("Nouveau Produit"),
        onPressed: () => context.push(AppRoutes.adminProductForm),
      ),
    );
  }

  Widget _buildKpiBadge({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$label: ",
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
