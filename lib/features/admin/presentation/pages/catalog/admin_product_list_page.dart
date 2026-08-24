import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_product_card.dart';
import 'package:eveilkid/features/admin/providers/admin_catalog_controller.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

/// Page d'administration du catalogue de produits avec recherche, onglets et tiroir de filtres dédié.
class AdminProductListPage extends ConsumerStatefulWidget {
  const AdminProductListPage({super.key});

  @override
  ConsumerState<AdminProductListPage> createState() =>
      _AdminProductListPageState();
}

class _AdminProductListPageState extends ConsumerState<AdminProductListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {});
    final notifier = ref.read(adminProductFilterProvider.notifier);
    if (_tabController.index == 0) {
      notifier.setActiveFilter(AdminActiveFilter.activeOnly);
    } else {
      notifier.setActiveFilter(AdminActiveFilter.inactiveOnly);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProductsAsync = ref.watch(adminFilteredProductsProvider);
    final filterState = ref.watch(adminProductFilterProvider);
    final filterNotifier = ref.read(adminProductFilterProvider.notifier);
    final categoriesAsync = ref.watch(categoriesAdminStreamProvider);
    final List<Categorie> categories = categoriesAsync.value ?? [];
    final stats = ref.watch(adminCatalogStatsProvider);

    final int inactiveCount = stats.totalProducts - stats.activeProducts;

    return AdminScaffold(
      currentRoute: AdminNavRoute.products,
      appBar: AppBar(
        title: const Text(
          "Catalogue Produits",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            padding: const EdgeInsets.all(3),
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Actifs"),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: _tabController.index == 0
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${stats.activeProducts}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _tabController.index == 0
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Inactifs"),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: _tabController.index == 1
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "$inactiveCount",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _tabController.index == 1
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
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
      body: Column(
        children: [
          // Barre de Recherche + Bouton Filtres
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: AppSearchBar(
                    hintText: "Rechercher par nom, catégorie...",
                    onChanged: (query) => filterNotifier.setSearchQuery(query),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _showFilterBottomSheet(context, ref, categories, stats),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: filterState.hasActiveFilters
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: filterState.hasActiveFilters
                            ? AppColors.primary
                            : AppColors.border,
                        width: filterState.hasActiveFilters ? 1.2 : 1.0,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 19,
                          color: filterState.hasActiveFilters
                              ? AppColors.primary
                              : AppColors.icon,
                        ),
                        if (filterState.hasActiveFilters)
                          Positioned(
                            top: 9,
                            right: 9,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Ligne d'information discrète et compacte
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                filteredProductsAsync.maybeWhen(
                  data: (list) => Text(
                    "${list.length} ${list.length <= 1 ? 'produit' : 'produits'}${_tabController.index == 1 ? ' inactifs' : ''}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                if (filterState.hasActiveFilters)
                  InkWell(
                    onTap: () => filterNotifier.resetFilters(),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded, size: 13, color: AppColors.primary),
                          SizedBox(width: 2),
                          Text(
                            "Effacer filtres",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // Liste dense et minimaliste des produits
          Expanded(
            child: filteredProductsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              error: (err, stack) => AppErrorState(
                title: "Erreur de chargement",
                message: "Impossible de charger les produits : $err",
                onRetry: () => ref.refresh(jouetsAdminStreamProvider),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          ref.invalidate(jouetsAdminStreamProvider);
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: AppEmptyState(
                              icon: _tabController.index == 1
                                  ? Icons.inventory_2_outlined
                                  : Icons.search_off_rounded,
                              title: _tabController.index == 1
                                  ? "Aucun produit inactif"
                                  : (filterState.hasActiveFilters
                                      ? "Aucun produit correspondant"
                                      : "Catalogue vide"),
                              description: _tabController.index == 1
                                  ? "Tous vos produits sont actuellement actifs et visibles."
                                  : (filterState.hasActiveFilters
                                      ? "Modifiez vos filtres pour voir plus de résultats."
                                      : "Commencez par ajouter un produit."),
                              actionText: _tabController.index == 1
                                  ? null
                                  : (filterState.hasActiveFilters
                                      ? "Réinitialiser les filtres"
                                      : "Ajouter un produit"),
                              onActionPressed: filterState.hasActiveFilters
                                  ? () => filterNotifier.resetFilters()
                                  : () => context.push(AppRoutes.adminProductForm),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(jouetsAdminStreamProvider);
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isTabletOrDesktop = constraints.maxWidth >= 720;

                      if (isTabletOrDesktop) {
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 6, 14, 90),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 620,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            mainAxisExtent: 150,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final jouet = products[index];
                            return AdminProductCard(
                              jouet: jouet,
                              onEdit: () => _navigateToEdit(context, jouet),
                            );
                          },
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final jouet = products[index];
                          return AdminProductCard(
                            jouet: jouet,
                            onEdit: () => _navigateToEdit(context, jouet),
                          );
                        },
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
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          "Nouveau Produit",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
        onPressed: () => context.push(AppRoutes.adminProductForm),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, Jouet jouet) {
    context.push(
      AppRoutes.adminProductForm,
      extra: jouet,
    );
  }

  /// Tiroir Bottom Sheet de filtres propre, flat et moderne
  void _showFilterBottomSheet(
    BuildContext context,
    WidgetRef ref,
    List<Categorie> categories,
    dynamic stats,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final filterState = ref.watch(adminProductFilterProvider);
            final filterNotifier = ref.read(adminProductFilterProvider.notifier);

            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Poignée
                      Center(
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // En-tête avec titre et bouton réinitialiser
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Filtres du catalogue",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (filterState.hasActiveFilters)
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => filterNotifier.resetFilters(),
                              child: const Text(
                                "Réinitialiser",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 20, color: AppColors.border),

                      // 1. Popularité
                      const Text(
                        "Popularité & Mise en avant",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text("⭐ Produits Populaires"),
                            selected: filterState.popularOnly,
                            selectedColor: AppColors.warning.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              fontSize: 12.5,
                              fontWeight: filterState.popularOnly
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: filterState.popularOnly
                                  ? AppColors.warning
                                  : AppColors.textPrimary,
                            ),
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: filterState.popularOnly
                                    ? AppColors.warning
                                    : AppColors.border,
                                width: filterState.popularOnly ? 1.2 : 1.0,
                              ),
                            ),
                            onSelected: (val) {
                              filterNotifier.setPopularOnly(val);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 2. Disponibilité Stock
                      const Text(
                        "Disponibilité Stock",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text("Tous les stocks"),
                            selected: filterState.stockFilter == AdminStockFilter.all,
                            selectedColor: AppColors.primary.withValues(alpha: 0.1),
                            labelStyle: TextStyle(
                              fontSize: 12.5,
                              fontWeight: filterState.stockFilter == AdminStockFilter.all
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: filterState.stockFilter == AdminStockFilter.all
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: filterState.stockFilter == AdminStockFilter.all
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: filterState.stockFilter == AdminStockFilter.all
                                    ? 1.2
                                    : 1.0,
                              ),
                            ),
                            onSelected: (_) =>
                                filterNotifier.setStockFilter(AdminStockFilter.all),
                          ),
                          ChoiceChip(
                            label: Text("Rupture de stock (${stats.outOfStockProducts})"),
                            selected: filterState.stockFilter == AdminStockFilter.outOfStock,
                            selectedColor: AppColors.danger.withValues(alpha: 0.1),
                            labelStyle: TextStyle(
                              fontSize: 12.5,
                              fontWeight: filterState.stockFilter == AdminStockFilter.outOfStock
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: filterState.stockFilter == AdminStockFilter.outOfStock
                                  ? AppColors.danger
                                  : AppColors.textPrimary,
                            ),
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: filterState.stockFilter == AdminStockFilter.outOfStock
                                    ? AppColors.danger
                                    : AppColors.border,
                                width: filterState.stockFilter == AdminStockFilter.outOfStock
                                    ? 1.2
                                    : 1.0,
                              ),
                            ),
                            onSelected: (_) => filterNotifier.setStockFilter(
                              filterState.stockFilter == AdminStockFilter.outOfStock
                                  ? AdminStockFilter.all
                                  : AdminStockFilter.outOfStock,
                            ),
                          ),
                          ChoiceChip(
                            label: const Text("Stock faible (≤ 5)"),
                            selected: filterState.stockFilter == AdminStockFilter.lowStock,
                            selectedColor: AppColors.warning.withValues(alpha: 0.1),
                            labelStyle: TextStyle(
                              fontSize: 12.5,
                              fontWeight: filterState.stockFilter == AdminStockFilter.lowStock
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: filterState.stockFilter == AdminStockFilter.lowStock
                                  ? AppColors.warning
                                  : AppColors.textPrimary,
                            ),
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: filterState.stockFilter == AdminStockFilter.lowStock
                                    ? AppColors.warning
                                    : AppColors.border,
                                width: filterState.stockFilter == AdminStockFilter.lowStock
                                    ? 1.2
                                    : 1.0,
                              ),
                            ),
                            onSelected: (_) => filterNotifier.setStockFilter(
                              filterState.stockFilter == AdminStockFilter.lowStock
                                  ? AdminStockFilter.all
                                  : AdminStockFilter.lowStock,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 3. Catégories
                      const Text(
                        "Catégories",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text("Toutes"),
                            selected: filterState.selectedCategoryId == null,
                            selectedColor: AppColors.primary.withValues(alpha: 0.1),
                            labelStyle: TextStyle(
                              fontSize: 12.5,
                              fontWeight: filterState.selectedCategoryId == null
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: filterState.selectedCategoryId == null
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: filterState.selectedCategoryId == null
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: filterState.selectedCategoryId == null
                                    ? 1.2
                                    : 1.0,
                              ),
                            ),
                            onSelected: (_) => filterNotifier.setCategory(null),
                          ),
                          ...categories.map(
                            (cat) {
                              final isSelected =
                                  filterState.selectedCategoryId == cat.categorieId;
                              return ChoiceChip(
                                label: Text(cat.nom),
                                selected: isSelected,
                                selectedColor: AppColors.primary.withValues(alpha: 0.1),
                                labelStyle: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight:
                                      isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: isSelected ? 1.2 : 1.0,
                                  ),
                                ),
                                onSelected: (_) {
                                  filterNotifier.setCategory(
                                    isSelected ? null : cat.categorieId,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Bouton d'application
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            "Appliquer les filtres",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
