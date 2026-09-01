import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/ActivityCategorie/models/activity_category_model.dart';
import 'package:eveilkid/features/ActivityCategorie/providers/activity_category_provider.dart';
import 'package:eveilkid/features/activites/enums/publication_status.enum.dart';
import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_card.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

/// Écran d'administration des activités avec onglets épurés, recherche, bouton filtre modal theme-aware et affichage responsive.
class ActivitiesListScreen extends ConsumerStatefulWidget {
  const ActivitiesListScreen({super.key});

  @override
  ConsumerState<ActivitiesListScreen> createState() =>
      _ActivitiesListScreenState();
}

class _ActivitiesListScreenState extends ConsumerState<ActivitiesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategoryId = 'all';
  String _selectedDifficulty = 'all'; // 'all', 'facile', 'moyen', 'difficile'
  String _selectedAgeGroup = 'all'; // 'all', '3-5', '6-8', '9-12'

  bool get _hasActiveFilters =>
      _selectedCategoryId != 'all' ||
      _selectedDifficulty != 'all' ||
      _selectedAgeGroup != 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    final activitiesAsync = ref.watch(adminActivitesProvider);
    final categoriesAsync = ref.watch(categoriesActivesProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(
      alpha: isDark ? 0.25 : 0.12,
    );
    final textSecondary =
        theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    final categoriesList = categoriesAsync.value ?? [];

    return AdminScaffold(
      currentRoute: AdminNavRoute.activites,
      appBar: AppBar(
        title: Text(
          "Gestion des Activités",
          style: TextStyle(
            color:
                theme.textTheme.titleMedium?.color ??
                theme.colorScheme.onSurface,
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
            onPressed: () => ref.invalidate(adminActivitesProvider),
          ),
        ],
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
              border: Border.all(color: dividerColor, width: 1),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: dividerColor, width: 0.8),
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
              tabs: const [
                Tab(text: 'Toutes'),
                Tab(text: 'Publiées'),
                Tab(text: 'Brouillons'),
                Tab(text: 'Archivées'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle Activité'),
        onPressed: () => context.push(AppRoutes.adminAddActivity),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 950;
          final isDesktop = constraints.maxWidth >= 950;
          final horizontalPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Barre de recherche + Bouton de Filtres modal
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppSearchBar(
                            hintText: 'Rechercher une activité...',
                            onChanged: (val) {
                              setState(() => _searchQuery = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterButton(
                          theme,
                          isDark,
                          dividerColor,
                          categoriesList,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Liste / Grille responsive des activités
                  Expanded(
                    child: activitiesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(
                        child: AppErrorState(
                          title: 'Impossible de charger les activités',
                          message: '$err',
                          onRetry: () => ref.invalidate(adminActivitesProvider),
                        ),
                      ),
                      data: (activities) {
                        final filtered = _getFilteredActivities(activities);

                        if (filtered.isEmpty) {
                          return Center(
                            child: AppEmptyState(
                              icon: Icons.extension_outlined,
                              title:
                                  _searchQuery.isNotEmpty || _hasActiveFilters
                                  ? 'Aucune activité correspondante'
                                  : 'Aucune activité trouvée',
                              description:
                                  _searchQuery.isNotEmpty || _hasActiveFilters
                                  ? 'Essayez de modifier vos critères de recherche ou vos filtres.'
                                  : 'Créez votre première activité ludique pour les enfants.',
                              actionText: _hasActiveFilters
                                  ? 'Réinitialiser les filtres'
                                  : 'Nouvelle Activité',
                              onActionPressed: () {
                                if (_hasActiveFilters) {
                                  setState(() {
                                    _selectedCategoryId = 'all';
                                    _selectedDifficulty = 'all';
                                    _selectedAgeGroup = 'all';
                                    _searchQuery = '';
                                  });
                                } else {
                                  context.push(AppRoutes.adminAddActivity);
                                }
                              },
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(adminActivitesProvider);
                          },
                          child: _buildResponsiveActivityView(
                            filtered: filtered,
                            isTablet: isTablet,
                            isDesktop: isDesktop,
                            horizontalPadding: horizontalPadding,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterButton(
    ThemeData theme,
    bool isDark,
    Color dividerColor,
    List<ActiviteCategorie> categories,
  ) {
    return InkWell(
      onTap: () => _showFilterBottomSheet(context, categories),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: _hasActiveFilters
              ? theme.colorScheme.primary.withValues(
                  alpha: isDark ? 0.25 : 0.12,
                )
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasActiveFilters ? theme.colorScheme.primary : dividerColor,
            width: _hasActiveFilters ? 1.4 : 1.0,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 20,
              color: _hasActiveFilters
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            if (_hasActiveFilters)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveActivityView({
    required List<Activite> filtered,
    required bool isTablet,
    required bool isDesktop,
    required double horizontalPadding,
  }) {
    if (isDesktop || isTablet) {
      final crossAxisCount = isDesktop ? 3 : 2;
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          6,
          horizontalPadding,
          85,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 14,
          mainAxisSpacing: 12,
          mainAxisExtent: 165,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final activity = filtered[index];
          return ActivityCard(
            activity: activity,
            onTap: () {
              if (activity.id != null) {
                context.push('/admin/activites/${activity.id}/questions');
              }
            },
            onEdit: () {
              if (activity.id != null) {
                context.push('/admin/activites/edit/${activity.id}');
              }
            },
            onDelete: () => _confirmDeleteActivity(activity),
            onPublish: () =>
                _togglePublicationStatus(activity, PublicationStatus.publie),
            onUnpublish: () =>
                _togglePublicationStatus(activity, PublicationStatus.brouillon),
          );
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 85),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final activity = filtered[index];
        return ActivityCard(
          activity: activity,
          onTap: () {
            if (activity.id != null) {
              context.push('/admin/activites/${activity.id}/questions');
            }
          },
          onEdit: () {
            if (activity.id != null) {
              context.push('/admin/activites/edit/${activity.id}');
            }
          },
          onDelete: () => _confirmDeleteActivity(activity),
          onPublish: () =>
              _togglePublicationStatus(activity, PublicationStatus.publie),
          onUnpublish: () =>
              _togglePublicationStatus(activity, PublicationStatus.brouillon),
        );
      },
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    List<ActiviteCategorie> categories,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String tempCategory = _selectedCategoryId;
    String tempDifficulty = _selectedDifficulty;
    String tempAgeGroup = _selectedAgeGroup;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poignée de glissement
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // En-tête
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filtres des Activités',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 1. SECTION CATÉGORIE
                Text(
                  'Catégorie d\'univers',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildModalChip(
                      label: 'Toutes',
                      isSelected: tempCategory == 'all',
                      onSelected: () =>
                          setModalState(() => tempCategory = 'all'),
                      theme: theme,
                      isDark: isDark,
                    ),
                    ...categories.map((cat) {
                      final catId = cat.id ?? '';
                      return _buildModalChip(
                        label: cat.nom,
                        isSelected: tempCategory == catId,
                        onSelected: () =>
                            setModalState(() => tempCategory = catId),
                        theme: theme,
                        isDark: isDark,
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 16),

                // 2. SECTION DIFFICULTÉ
                Text(
                  'Niveau de difficulté',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildModalChip(
                      label: 'Toutes',
                      isSelected: tempDifficulty == 'all',
                      onSelected: () =>
                          setModalState(() => tempDifficulty = 'all'),
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildModalChip(
                      label: 'Facile',
                      isSelected: tempDifficulty == 'facile',
                      onSelected: () =>
                          setModalState(() => tempDifficulty = 'facile'),
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildModalChip(
                      label: 'Moyen',
                      isSelected: tempDifficulty == 'moyen',
                      onSelected: () =>
                          setModalState(() => tempDifficulty = 'moyen'),
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildModalChip(
                      label: 'Difficile',
                      isSelected: tempDifficulty == 'difficile',
                      onSelected: () =>
                          setModalState(() => tempDifficulty = 'difficile'),
                      theme: theme,
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 3. SECTION TRANCHE D'ÂGE
                Text(
                  'Tranche d\'âge',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildModalChip(
                      label: 'Tous les âges',
                      isSelected: tempAgeGroup == 'all',
                      onSelected: () =>
                          setModalState(() => tempAgeGroup = 'all'),
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildModalChip(
                      label: '3 - 5 ans',
                      isSelected: tempAgeGroup == '3-5',
                      onSelected: () =>
                          setModalState(() => tempAgeGroup = '3-5'),
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildModalChip(
                      label: '6 - 8 ans',
                      isSelected: tempAgeGroup == '6-8',
                      onSelected: () =>
                          setModalState(() => tempAgeGroup = '6-8'),
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildModalChip(
                      label: '9 - 12 ans',
                      isSelected: tempAgeGroup == '9-12',
                      onSelected: () =>
                          setModalState(() => tempAgeGroup = '9-12'),
                      theme: theme,
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 4. BOUTONS D'ACTION (RÉINITIALISER / APPLIQUER)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(() {
                            tempCategory = 'all';
                            tempDifficulty = 'all';
                            tempAgeGroup = 'all';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurfaceVariant,
                          side: BorderSide(
                            color: theme.dividerColor.withValues(
                              alpha: isDark ? 0.3 : 0.2,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Réinitialiser'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategoryId = tempCategory;
                            _selectedDifficulty = tempDifficulty;
                            _selectedAgeGroup = tempAgeGroup;
                          });
                          Navigator.pop(bottomSheetContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Appliquer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required ThemeData theme,
    required bool isDark,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: theme.colorScheme.primary.withValues(
        alpha: isDark ? 0.25 : 0.12,
      ),
      backgroundColor: isDark
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
          : theme.colorScheme.surface,
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.dividerColor.withValues(alpha: isDark ? 0.3 : 0.15),
        width: isSelected ? 1.4 : 1.0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }

  List<Activite> _getFilteredActivities(List<Activite> list) {
    final query = _searchQuery.trim().toLowerCase();

    return list.where((activity) {
      // Filtre d'onglet (statut)
      if (_tabController.index == 1 &&
          activity.statut != PublicationStatus.publie) {
        return false;
      }
      if (_tabController.index == 2 &&
          activity.statut != PublicationStatus.brouillon) {
        return false;
      }
      if (_tabController.index == 3 &&
          activity.statut != PublicationStatus.archive) {
        return false;
      }

      // Filtre catégorie
      if (_selectedCategoryId != 'all' &&
          activity.categorieId != _selectedCategoryId) {
        return false;
      }

      // Filtre difficulté
      if (_selectedDifficulty != 'all' &&
          activity.difficulte.toLowerCase() != _selectedDifficulty) {
        return false;
      }

      // Filtre tranche d'âge
      if (_selectedAgeGroup != 'all') {
        switch (_selectedAgeGroup) {
          case '3-5':
            if (activity.ageMaximum < 3 || activity.ageMinimum > 5)
              return false;
            break;
          case '6-8':
            if (activity.ageMaximum < 6 || activity.ageMinimum > 8)
              return false;
            break;
          case '9-12':
            if (activity.ageMaximum < 9 || activity.ageMinimum > 12)
              return false;
            break;
        }
      }

      // Recherche texte
      if (query.isNotEmpty) {
        final matchesTitle = activity.titre.toLowerCase().contains(query);
        final matchesDesc = activity.description.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _togglePublicationStatus(
    Activite activity,
    PublicationStatus newStatus,
  ) async {
    if (activity.id == null) return;
    try {
      final notifier = ref.read(activityNotifierProvider.notifier);
      if (newStatus == PublicationStatus.publie) {
        await notifier.publierActivity(activity.id!);
      } else {
        await notifier.depublierActivity(activity.id!);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == PublicationStatus.publie
                  ? 'Activité publiée avec succès'
                  : 'Activité passée en brouillon',
            ),
            backgroundColor: newStatus == PublicationStatus.publie
                ? const Color(0xFF16A34A)
                : const Color(0xFFD97706),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _confirmDeleteActivity(Activite activity) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Supprimer l\'activité'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${activity.titre}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                final notifier = ref.read(activityNotifierProvider.notifier);
                await notifier.deleteActivity(activity.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Activité supprimée avec succès'),
                      backgroundColor: Color(0xFF16A34A),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
