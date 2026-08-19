import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/admin/providers/admin_catalog_controller.dart';
import 'admin_category_list_page.dart';
import 'admin_product_form_page.dart';
import 'admin_product_list_page.dart';
import '../../widgets/admin_category_form_dialog.dart';

class AdminCatalogPage extends ConsumerStatefulWidget {
  const AdminCatalogPage({super.key});

  @override
  ConsumerState<AdminCatalogPage> createState() => _AdminCatalogPageState();
}

class _AdminCatalogPageState extends ConsumerState<AdminCatalogPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(adminCatalogStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Gestion du Catalogue",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Indicateurs statistiques rapides
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    _buildKpiChip(
                      label: "Produits",
                      value: "${stats.totalProducts}",
                      color: AppColors.primary,
                      icon: Icons.inventory_2_outlined,
                    ),
                    const SizedBox(width: 8),
                    _buildKpiChip(
                      label: "Actifs",
                      value: "${stats.activeProducts}",
                      color: AppColors.success,
                      icon: Icons.check_circle_outline,
                    ),
                    const SizedBox(width: 8),
                    _buildKpiChip(
                      label: "Rupture",
                      value: "${stats.outOfStockProducts}",
                      color: stats.outOfStockProducts > 0
                          ? AppColors.danger
                          : AppColors.textSecondary,
                      icon: Icons.warning_amber_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildKpiChip(
                      label: "Populaires",
                      value: "${stats.popularProducts}",
                      color: AppColors.accent,
                      icon: Icons.star_border,
                    ),
                  ],
                ),
              ),
              // Onglets
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.toys_outlined, size: 18),
                        const SizedBox(width: 6),
                        Text("Produits (${stats.totalProducts})"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.category_outlined, size: 18),
                        const SizedBox(width: 6),
                        Text("Catégories (${stats.totalCategories})"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminProductListPage(),
          AdminCategoryListPage(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: Text(
          _tabController.index == 0 ? "Nouveau Produit" : "Nouvelle Catégorie",
        ),
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const AdminProductFormPage(),
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (ctx) => const AdminCategoryFormDialog(),
            );
          }
        },
      ),
    );
  }

  Widget _buildKpiChip({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
