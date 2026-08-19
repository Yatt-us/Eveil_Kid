import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_category_form_dialog.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_category_tile.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/features/admin/providers/admin_catalog_controller.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

class AdminCategoryListPage extends ConsumerStatefulWidget {
  const AdminCategoryListPage({super.key});

  @override
  ConsumerState<AdminCategoryListPage> createState() =>
      _AdminCategoryListPageState();
}

class _AdminCategoryListPageState extends ConsumerState<AdminCategoryListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesAdminStreamProvider);
    final stats = ref.watch(adminCatalogStatsProvider);

    return AdminScaffold(
      currentRoute: AdminNavRoute.categories,
      appBar: AppBar(
        title: const Text(
          "Gestion des Catégories",
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
                  label: "Total Catégories",
                  value: "${stats.totalCategories}",
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _buildKpiBadge(
                  label: "Produits associés",
                  value: "${stats.totalProducts}",
                  color: AppColors.teal,
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
              hintText: "Rechercher une catégorie...",
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Liste des catégories
          Expanded(
            child: categoriesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => AppErrorState(
                title: "Erreur de chargement",
                message: "Impossible de charger les catégories : $err",
                onRetry: () => ref.refresh(categoriesAdminStreamProvider),
              ),
              data: (categories) {
                // Filtrage par recherche
                var list = categories;
                if (_searchQuery.trim().isNotEmpty) {
                  final q = _searchQuery.toLowerCase().trim();
                  list = list
                      .where((c) => c.nom.toLowerCase().contains(q))
                      .toList();
                }

                if (list.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.category_outlined,
                    title: "Aucune catégorie trouvée",
                    description: _searchQuery.isNotEmpty
                        ? "Aucune catégorie ne correspond à votre recherche."
                        : "Créez votre première catégorie pour organiser les produits.",
                    actionText: "Ajouter une catégorie",
                    onActionPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const AdminCategoryFormDialog(),
                      );
                    },
                  );
                }

                // Organiser les catégories principales et sous-catégories
                final rootCategories =
                    list.where((c) => c.parentId == null || c.parentId!.isEmpty).toList();
                final subCategories =
                    list.where((c) => c.parentId != null && c.parentId!.isNotEmpty).toList();

                // Map pour retrouver le nom du parent
                final categoryMap = {for (var c in categories) c.categorieId: c.nom};

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(categoriesAdminStreamProvider);
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    children: [
                      if (rootCategories.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8, top: 4),
                          child: Text(
                            "Catégories Principales",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        ...rootCategories.map(
                          (cat) => AdminCategoryTile(
                            categorie: cat,
                            onEdit: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AdminCategoryFormDialog(
                                  categorieToEdit: cat,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      if (subCategories.isNotEmpty) ...[
                        AppSpacing.verticalMd,
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            "Sous-Catégories",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        ...subCategories.map(
                          (cat) => AdminCategoryTile(
                            categorie: cat,
                            parentCategoryName: categoryMap[cat.parentId],
                            onEdit: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AdminCategoryFormDialog(
                                  categorieToEdit: cat,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
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
        label: const Text("Nouvelle Catégorie"),
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => const AdminCategoryFormDialog(),
          );
        },
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
