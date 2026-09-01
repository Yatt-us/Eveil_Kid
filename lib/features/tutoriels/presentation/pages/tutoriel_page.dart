import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/provider/bottom_nav_bar_provider.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/panier/presentation/widgets/panier_app_bar_action.dart';
import 'package:eveilkid/features/panier/presentation/widgets/panier_floating_button.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/pages/tutoriel_detail_page.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/tutoriel_card.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/tutoriel_card_skeleton.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';
import 'package:eveilkid/shared/widgets/app_bottom_nav_bar.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

enum TutorielSortOption {
  newest,
  shortest,
  longest,
  nameAsc,
}

class TutorielPage extends ConsumerStatefulWidget {
  const TutorielPage({super.key});

  @override
  ConsumerState<TutorielPage> createState() => _TutorielPageState();
}

class _TutorielPageState extends ConsumerState<TutorielPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  TutorielSortOption _sortOption = TutorielSortOption.newest;
  int? _selectedAgeFilter; // null = all, 2 = 0-2 ans, 5 = 3-5 ans, 8 = 6+ ans

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _selectedCategoryId != 'all' ||
      _sortOption != TutorielSortOption.newest ||
      _selectedAgeFilter != null;

  List<Tutoriel> _filterAndSortTutoriels(List<Tutoriel> tutoriels) {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = tutoriels.where((tutoriel) {
      final matchesQuery = query.isEmpty ||
          tutoriel.titre.toLowerCase().contains(query) ||
          tutoriel.description.toLowerCase().contains(query);

      final matchesCategory = _selectedCategoryId == 'all' ||
          tutoriel.categorieId == _selectedCategoryId;

      bool matchesAge = true;
      if (_selectedAgeFilter == 2) {
        matchesAge = tutoriel.ageMinimum <= 2;
      } else if (_selectedAgeFilter == 5) {
        matchesAge = tutoriel.ageMinimum <= 5 && tutoriel.ageMaximum >= 3;
      } else if (_selectedAgeFilter == 8) {
        matchesAge = tutoriel.ageMaximum >= 6;
      }

      return matchesQuery && matchesCategory && matchesAge;
    }).toList();

    switch (_sortOption) {
      case TutorielSortOption.newest:
        filtered.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
      case TutorielSortOption.shortest:
        filtered.sort((a, b) => a.duree.compareTo(b.duree));
      case TutorielSortOption.longest:
        filtered.sort((a, b) => b.duree.compareTo(a.duree));
      case TutorielSortOption.nameAsc:
        filtered.sort((a, b) => a.titre.toLowerCase().compareTo(b.titre.toLowerCase()));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final tutorielsAsync = ref.watch(tutorielsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

    // Mapping ID Catégorie -> Nom
    final categoriesMap = <String, String>{};
    categoriesAsync.whenData((categories) {
      for (final cat in categories) {
        categoriesMap[cat.categorieId] = cat.nom;
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              ref.read(bottomIndexProvider.notifier).setIndex(0);
              context.go(AppRoutes.home);
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 16,
          title: Text(
            'Tutoriels',
            style: AppTextStyles.headingSmall.copyWith(
              color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          actions: const [
            PanierAppBarAction(),
            SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            color: theme.colorScheme.primary,
            onRefresh: () async {
              ref.invalidate(tutorielsProvider);
              ref.invalidate(categoriesProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── BARRE DE RECHERCHE + BOUTON FILTRE (STYLE ADMIN) ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: AppSearchBar(
                            controller: _searchController,
                            hintText: 'Rechercher un tutoriel...',
                            onChanged: (value) => setState(() => _searchQuery = value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _showFilterBottomSheet(context, categoriesAsync),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              color: _hasActiveFilters
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: isDark ? 0.25 : 0.12)
                                  : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _hasActiveFilters
                                    ? theme.colorScheme.primary
                                    : dividerColor,
                                width: _hasActiveFilters ? 1.2 : 1.0,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  size: 19,
                                  color: _hasActiveFilters
                                      ? theme.colorScheme.primary
                                      : (theme.iconTheme.color?.withValues(alpha: 0.7) ??
                                          AppColors.icon),
                                ),
                                if (_hasActiveFilters)
                                  Positioned(
                                    top: 9,
                                    right: 9,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
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
                ),

                // ── LISTE DES VIDÉOS ÉPURÉES ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  sliver: tutorielsAsync.when(
                    data: (tutoriels) {
                      final filtered = _filterAndSortTutoriels(tutoriels);

                      if (filtered.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppEmptyState(
                            title: _hasActiveFilters || _searchQuery.isNotEmpty
                                ? 'Aucun tutoriel correspondant'
                                : 'Aucun tutoriel disponible',
                            description: _hasActiveFilters || _searchQuery.isNotEmpty
                                ? 'Essayez de modifier votre recherche ou vos filtres.'
                                : 'De nouveaux tutoriels vidéo seront bientôt ajoutés.',
                            icon: Icons.video_library_outlined,
                            actionText: _hasActiveFilters || _searchQuery.isNotEmpty
                                ? 'Réinitialiser les filtres'
                                : null,
                            onActionPressed: _hasActiveFilters || _searchQuery.isNotEmpty
                                ? () {
                                    setState(() {
                                      _selectedCategoryId = 'all';
                                      _searchQuery = '';
                                      _sortOption = TutorielSortOption.newest;
                                      _selectedAgeFilter = null;
                                      _searchController.clear();
                                    });
                                  }
                                : null,
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = filtered[index];
                            final catName = categoriesMap[item.categorieId];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TutorielCard(
                                tutoriel: item,
                                categoryName: catName,
                                onTap: () => _openDetail(context, item.tutorielId!),
                              ),
                            );
                          },
                          childCount: filtered.length,
                        ),
                      );
                    },
                    loading: () => SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: TutorielCardSkeleton(),
                        ),
                        childCount: 4,
                      ),
                    ),
                    error: (error, _) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppErrorState(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(tutorielsProvider),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: const PanierFloatingButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: const AppBottomNavBar(),
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    AsyncValue<List<Categorie>> categoriesAsync,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);
    final titleColor = theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final activeCategories = categoriesAsync.maybeWhen(
              data: (cats) => cats.where((c) => c.estActive == true).toList(),
              orElse: () => <Categorie>[],
            );

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
                      // Poignée centrale
                      Center(
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Titre & Bouton Reset
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filtres des tutoriels',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (_hasActiveFilters)
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                setModalState(() {
                                  _selectedCategoryId = 'all';
                                  _sortOption = TutorielSortOption.newest;
                                  _selectedAgeFilter = null;
                                });
                                setState(() {});
                              },
                              child: Text(
                                'Réinitialiser',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Divider(height: 20, color: dividerColor),

                      // 1. Catégories
                      Text(
                        'CATÉGORIES',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                              AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChoiceChip(
                            label: 'Toutes les catégories',
                            isSelected: _selectedCategoryId == 'all',
                            theme: theme,
                            isDark: isDark,
                            onTap: () {
                              setModalState(() => _selectedCategoryId = 'all');
                              setState(() {});
                            },
                          ),
                          ...activeCategories.map(
                            (cat) => _buildChoiceChip(
                              label: cat.nom,
                              isSelected: _selectedCategoryId == cat.categorieId,
                              theme: theme,
                              isDark: isDark,
                              onTap: () {
                                setModalState(() => _selectedCategoryId = cat.categorieId);
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 2. Tranche d'âge
                      Text(
                        'TRANCHE D\'ÂGE',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                              AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChoiceChip(
                            label: 'Tous les âges',
                            isSelected: _selectedAgeFilter == null,
                            theme: theme,
                            isDark: isDark,
                            onTap: () {
                              setModalState(() => _selectedAgeFilter = null);
                              setState(() {});
                            },
                          ),
                          _buildChoiceChip(
                            label: '0 - 2 ans',
                            isSelected: _selectedAgeFilter == 2,
                            theme: theme,
                            isDark: isDark,
                            onTap: () {
                              setModalState(() => _selectedAgeFilter = 2);
                              setState(() {});
                            },
                          ),
                          _buildChoiceChip(
                            label: '3 - 5 ans',
                            isSelected: _selectedAgeFilter == 5,
                            theme: theme,
                            isDark: isDark,
                            onTap: () {
                              setModalState(() => _selectedAgeFilter = 5);
                              setState(() {});
                            },
                          ),
                          _buildChoiceChip(
                            label: '6 ans et plus',
                            isSelected: _selectedAgeFilter == 8,
                            theme: theme,
                            isDark: isDark,
                            onTap: () {
                              setModalState(() => _selectedAgeFilter = 8);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 3. Tri
                      Text(
                        'TRIER PAR',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                              AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChoiceChip(
                            label: 'Plus récents',
                            isSelected: _sortOption == TutorielSortOption.newest,
                            theme: theme,
                            isDark: isDark,
                            onTap: () {
                              setModalState(() => _sortOption = TutorielSortOption.newest);
                              setState(() {});
                            },
                          ),
                          _buildChoiceChip(
                            label: 'Plus courts',
                            isSelected: _sortOption == TutorielSortOption.shortest,
                            theme: theme,
                            isDark: isDark,
                            onTap: () {
                              setModalState(() => _sortOption = TutorielSortOption.shortest);
                              setState(() {});
                            },
                          ),
                          _buildChoiceChip(
                            label: 'Plus longs',
                            isSelected: _sortOption == TutorielSortOption.longest,
                            theme: theme,
                            isDark: isDark,
                            onTap: () {
                              setModalState(() => _sortOption = TutorielSortOption.longest);
                              setState(() {});
                            },
                          ),
                          _buildChoiceChip(
                            label: 'Titre (A - Z)',
                            isSelected: _sortOption == TutorielSortOption.nameAsc,
                            theme: theme,
                            isDark: isDark,
                            onTap: () {
                              setModalState(() => _sortOption = TutorielSortOption.nameAsc);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Bouton Appliquer
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text(
                            'Appliquer',
                            style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required ThemeData theme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.12)
              : (isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : AppColors.surfaceVariant.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withValues(alpha: 0.2),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primary
                : (theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface),
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, String tutorielId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TutorielDetailPage(tutorielId: tutorielId),
      ),
    );
  }
}
