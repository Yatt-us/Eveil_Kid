import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_category_tile.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

/// Page d'administration des catégories avec onglets Actives / Inactives.
class AdminCategoryListPage extends ConsumerStatefulWidget {
  const AdminCategoryListPage({super.key});

  @override
  ConsumerState<AdminCategoryListPage> createState() =>
      _AdminCategoryListPageState();
}

class _AdminCategoryListPageState extends ConsumerState<AdminCategoryListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesAdminStreamProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);
    final titleColor = theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    final allCategories = categoriesAsync.value ?? [];
    final activeCategoriesCount = allCategories.where((c) => c.estActive).length;
    final inactiveCategoriesCount = allCategories.where((c) => !c.estActive).length;

    return AdminScaffold(
      currentRoute: AdminNavRoute.categories,
      appBar: AppBar(
        title: Text(
          "Gestion des Catégories",
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            padding: const EdgeInsets.all(3),
            height: 38,
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : AppColors.surfaceVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: dividerColor,
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: dividerColor,
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: textSecondary,
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
                      const Text("Actives"),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: _tabController.index == 0
                              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.12)
                              : (isDark ? theme.colorScheme.surface : AppColors.surfaceVariant),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "$activeCategoriesCount",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _tabController.index == 0
                                ? theme.colorScheme.primary
                                : textSecondary,
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
                      const Text("Inactives"),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: _tabController.index == 1
                              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.12)
                              : (isDark ? theme.colorScheme.surface : AppColors.surfaceVariant),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "$inactiveCategoriesCount",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _tabController.index == 1
                                ? theme.colorScheme.primary
                                : textSecondary,
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
          // Barre de recherche compacte
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: AppSearchBar(
              hintText: "Rechercher une catégorie...",
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Liste des catégories
          Expanded(
            child: categoriesAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
              error: (err, stack) => AppErrorState(
                title: "Erreur de chargement",
                message: "Impossible de charger les catégories : $err",
                onRetry: () => ref.refresh(categoriesAdminStreamProvider),
              ),
              data: (categories) {
                final isViewingActive = _tabController.index == 0;
                var list = categories.where((c) => c.estActive == isViewingActive).toList();

                // Filtrage par recherche
                if (_searchQuery.trim().isNotEmpty) {
                  final q = _searchQuery.toLowerCase().trim();
                  list = list
                      .where((c) => c.nom.toLowerCase().contains(q))
                      .toList();
                }

                if (list.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.category_outlined,
                    title: isViewingActive
                        ? (_searchQuery.isNotEmpty
                            ? "Aucune catégorie correspondante"
                            : "Aucune catégorie active")
                        : "Aucune catégorie inactive",
                    description: isViewingActive
                        ? (_searchQuery.isNotEmpty
                            ? "Essayez d'autres mots-clés."
                            : "Créez votre première catégorie pour organiser les produits.")
                        : "Toutes vos catégories sont actuellement actives.",
                    actionText: isViewingActive && _searchQuery.isEmpty
                        ? "Ajouter une catégorie"
                        : null,
                    onActionPressed: isViewingActive && _searchQuery.isEmpty
                        ? () => context.push(AppRoutes.adminCategoryForm)
                        : null,
                  );
                }

                return RefreshIndicator(
                  color: theme.colorScheme.primary,
                  onRefresh: () async {
                    ref.invalidate(categoriesAdminStreamProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final cat = list[index];
                      return AdminCategoryTile(
                        categorie: cat,
                        onEdit: () {
                          context.push(
                            AppRoutes.adminCategoryForm,
                            extra: cat,
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
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          "Nouvelle Catégorie",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
        onPressed: () => context.push(AppRoutes.adminCategoryForm),
      ),
    );
  }
}
