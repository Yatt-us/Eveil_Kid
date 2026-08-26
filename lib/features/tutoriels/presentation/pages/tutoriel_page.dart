import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/provider/bottom_nav_bar_provider.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/pages/tutoriel_detail_page.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/category_filter.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/tutoriel_card.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/tutoriel_search.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';
import 'package:eveilkid/shared/widgets/app_bottom_nav_bar.dart';

class TutorielPage extends ConsumerStatefulWidget {
  const TutorielPage({super.key});

  @override
  ConsumerState<TutorielPage> createState() => _TutorielPageState();
}

class _TutorielPageState extends ConsumerState<TutorielPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryId = 'all';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Tutoriel> _filterTutoriels(List<Tutoriel> tutoriels) {
    final query = _searchQuery.trim().toLowerCase();

    return tutoriels.where((tutoriel) {
      final matchesQuery = query.isEmpty ||
          tutoriel.titre.toLowerCase().contains(query) ||
          tutoriel.description.toLowerCase().contains(query);

      final matchesCategory = _selectedCategoryId == 'all' ||
          tutoriel.categorieId == _selectedCategoryId;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tutorielsAsync = ref.watch(tutorielsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    // Mapping ID Catégorie -> Nom
    final categoriesMap = <String, String>{};
    categoriesAsync.whenData((categories) {
      for (final cat in categories) {
        categoriesMap[cat.categorieId] = cat.nom;
      }
    });

    final totalCount = tutorielsAsync.asData?.value.length ?? 0;
    final allTutoriels = tutorielsAsync.asData?.value ?? [];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ref.read(bottomIndexProvider.notifier).setIndex(0);
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
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
                // ── EN-TÊTE ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  sliver: SliverToBoxAdapter(
                    child: _buildHeader(context, totalCount),
                  ),
                ),

                // ── BARRE DE RECHERCHE ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                  sliver: SliverToBoxAdapter(
                    child: TutorielSearchField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      onClear: () => setState(() => _searchQuery = ''),
                    ),
                  ),
                ),

                // ── FILTRES CATÉGORIES ──
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildCategoryFilters(context, categoriesAsync, allTutoriels),
                  ),
                ),

                // ── LISTE DES TUTORIELS ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  sliver: tutorielsAsync.when(
                    data: (tutoriels) {
                      final filtered = _filterTutoriels(tutoriels);

                      if (filtered.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(context),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = filtered[index];
                            final catName = categoriesMap[item.categorieId];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
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
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildSkeletonCard(context),
                        ),
                        childCount: 4,
                      ),
                    ),
                    error: (error, _) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildErrorState(context, error.toString()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const AppBottomNavBar(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int totalCount) {
    final theme = Theme.of(context);

    return Row(
      children: [
        IconButton(
          onPressed: () {
            ref.read(bottomIndexProvider.notifier).setIndex(0);
            context.go(AppRoutes.home);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: theme.colorScheme.onSurface,
          tooltip: 'Retour',
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Tutoriels',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (totalCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalCount vidéos',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Guides et vidéos pour accompagner vos enfants',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters(
    BuildContext context,
    AsyncValue<List<dynamic>> categoriesAsync,
    List<Tutoriel> tutoriels,
  ) {
    final chips = <Widget>[];

    // Chip "Tous"
    chips.add(
      CategoryFilterChip(
        label: 'Tous',
        count: tutoriels.length,
        isSelected: _selectedCategoryId == 'all',
        onTap: () => setState(() => _selectedCategoryId = 'all'),
      ),
    );

    categoriesAsync.whenData((categories) {
      for (final cat in categories) {
        if (cat.estActive == true) {
          final count = tutoriels.where((t) => t.categorieId == cat.categorieId).length;
          chips.add(
            CategoryFilterChip(
              label: cat.nom,
              count: count,
              isSelected: _selectedCategoryId == cat.categorieId,
              onTap: () => setState(() => _selectedCategoryId = cat.categorieId),
            ),
          );
        }
      }
    });

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (_, index) => chips[index],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilter = _selectedCategoryId != 'all' || _searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.video_library_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'Aucun tutoriel correspondant' : 'Aucun tutoriel disponible',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Essayez de modifier votre recherche ou de sélectionner une autre catégorie.'
                  : 'De nouveaux tutoriels vidéo seront bientôt ajoutés.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (hasFilter) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedCategoryId = 'all';
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Réinitialiser les filtres'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Impossible de charger les tutoriels',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(tutorielsProvider),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 115,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 130,
            height: 95,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 18,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
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
