import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:eveilkid/features/admin/presentation/widgets/tutoriel_card.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/tutoriels/enums/tutoriel_status.enum.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

enum AdminTutorielSortOption { newest, oldest, longest, shortest, titleAsc }

class TutorielsListScreen extends ConsumerStatefulWidget {
  const TutorielsListScreen({super.key});

  @override
  ConsumerState<TutorielsListScreen> createState() =>
      _TutorielsListScreenState();
}

class _TutorielsListScreenState extends ConsumerState<TutorielsListScreen> {
  String _searchQuery = '';
  String? _selectedStatus; // null = tous, 'publie', 'brouillon'
  String? _selectedCategoryId;
  AdminTutorielSortOption _sortOption = AdminTutorielSortOption.newest;

  bool get _hasActiveFilters =>
      _selectedStatus != null ||
      _selectedCategoryId != null ||
      _sortOption != AdminTutorielSortOption.newest;

  @override
  Widget build(BuildContext context) {
    final tutorielsAsync = ref.watch(adminTutorielsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mapping ID Catégorie -> Nom
    final categoriesMap = <String, String>{};
    categoriesAsync.whenData((cats) {
      for (final c in cats) {
        categoriesMap[c.categorieId] = c.nom;
      }
    });

    return AdminScaffold(
      currentRoute: AdminNavRoute.tutoriels,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Tutoriels Vidéo',
          style:
              theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ) ??
              TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: theme.colorScheme.onSurface,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(adminTutorielsProvider);
              ref.invalidate(categoriesProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.adminAddTutoriel);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nouveau tutoriel',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminTutorielsProvider);
          ref.invalidate(categoriesProvider);
        },
        child: tutorielsAsync.when(
          loading: () => _buildAdminSkeleton(theme, isDark),
          error: (err, _) => AppErrorState(
            message: 'Erreur lors du chargement des tutoriels: $err',
            onRetry: () => ref.invalidate(adminTutorielsProvider),
          ),
          data: (allTutoriels) {
            final totalCount = allTutoriels.length;
            final publishedCount = allTutoriels
                .where((t) => t.statut == TutorielStatus.publie)
                .length;
            final draftCount = allTutoriels
                .where((t) => t.statut == TutorielStatus.brouillon)
                .length;

            final filteredList = _applyFilters(allTutoriels);

            return CustomScrollView(
              slivers: [
                // Cartes Statistiques
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: AdminStatCard(
                            title: 'Total',
                            value: '$totalCount',
                            icon: Icons.video_library_rounded,
                            color: AppColors.primary,
                            onTap: () => setState(() => _selectedStatus = null),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AdminStatCard(
                            title: 'Publiés',
                            value: '$publishedCount',
                            icon: Icons.check_circle_rounded,
                            color: AppColors.success,
                            onTap: () =>
                                setState(() => _selectedStatus = 'publie'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AdminStatCard(
                            title: 'Brouillons',
                            value: '$draftCount',
                            icon: Icons.edit_note_rounded,
                            color: AppColors.warning,
                            onTap: () =>
                                setState(() => _selectedStatus = 'brouillon'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Barre de recherche & Bouton Filtre
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppSearchBar(
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                            hintText: 'Rechercher par titre ou description...',
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Bouton Filtre modal
                        GestureDetector(
                          onTap: () => _showFilterBottomSheet(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _hasActiveFilters
                                  ? AppColors.primary
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _hasActiveFilters
                                    ? AppColors.primary
                                    : (isDark
                                          ? Colors.white12
                                          : Colors.grey.shade300),
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  color: _hasActiveFilters
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white70
                                            : AppColors.textPrimary),
                                  size: 20,
                                ),
                                if (_hasActiveFilters)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
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

                // Chips d'état rapide (Tous, Publiés, Brouillons)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickStatusChip(
                            label: 'Tous ($totalCount)',
                            statusValue: null,
                          ),
                          const SizedBox(width: 8),
                          _buildQuickStatusChip(
                            label: 'Publiés ($publishedCount)',
                            statusValue: 'publie',
                          ),
                          const SizedBox(width: 8),
                          _buildQuickStatusChip(
                            label: 'Brouillons ($draftCount)',
                            statusValue: 'brouillon',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Liste des cartes ou état vide
                if (filteredList.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.video_library_outlined,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun tutoriel trouvé',
                              style:
                                  theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 17,
                                  ) ??
                                  TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                    color: theme.colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty || _hasActiveFilters
                                  ? 'Essayez de modifier vos critères de recherche ou de filtre.'
                                  : 'Commencez par ajouter votre premier tutoriel vidéo.',
                              style:
                                  theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ) ??
                                  TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            if (!_hasActiveFilters && _searchQuery.isEmpty)
                              AppButton(
                                text: 'Créer un tutoriel',
                                icon: Icons.add_rounded,
                                onPressed: () =>
                                    context.push(AppRoutes.adminAddTutoriel),
                              )
                            else
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedStatus = null;
                                    _selectedCategoryId = null;
                                    _sortOption =
                                        AdminTutorielSortOption.newest;
                                  });
                                },
                                icon: const Icon(Icons.clear_all_rounded),
                                label: const Text('Réinitialiser les filtres'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final tutoriel = filteredList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TutorielCard(
                            tutoriel: tutoriel,
                            categorieNom: categoriesMap[tutoriel.categorieId],
                            onTap: () {
                              if (tutoriel.tutorielId != null) {
                                context.push(
                                  AppRoutes.adminDetailTutorielPath(
                                    tutoriel.tutorielId!,
                                  ),
                                  extra: tutoriel,
                                );
                              }
                            },
                            onEdit: () {
                              context.push(
                                AppRoutes.adminEditTutorielPath(
                                  tutoriel.tutorielId ?? '',
                                ),
                                extra: tutoriel,
                              );
                            },
                            onDelete: () => _confirmDelete(tutoriel),
                            onPublish: () => _publishTutoriel(tutoriel),
                            onUnpublish: () => _unpublishTutoriel(tutoriel),
                          ),
                        );
                      }, childCount: filteredList.length),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickStatusChip({
    required String label,
    required String? statusValue,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedStatus == statusValue;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : AppColors.textPrimary),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (_) {
        setState(() => _selectedStatus = statusValue);
      },
    );
  }

  List<Tutoriel> _applyFilters(List<Tutoriel> tutoriels) {
    List<Tutoriel> list = List.from(tutoriels);

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((t) {
        return t.titre.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query);
      }).toList();
    }

    if (_selectedStatus != null) {
      list = list.where((t) => t.statut.value == _selectedStatus).toList();
    }

    if (_selectedCategoryId != null) {
      list = list.where((t) => t.categorieId == _selectedCategoryId).toList();
    }

    switch (_sortOption) {
      case AdminTutorielSortOption.newest:
        list.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        break;
      case AdminTutorielSortOption.oldest:
        list.sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
        break;
      case AdminTutorielSortOption.longest:
        list.sort((a, b) => b.duree.compareTo(a.duree));
        break;
      case AdminTutorielSortOption.shortest:
        list.sort((a, b) => a.duree.compareTo(b.duree));
        break;
      case AdminTutorielSortOption.titleAsc:
        list.sort(
          (a, b) => a.titre.toLowerCase().compareTo(b.titre.toLowerCase()),
        );
        break;
    }

    return list;
  }

  void _showFilterBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoriesAsync = ref.read(categoriesProvider);
    final categories = categoriesAsync.value ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtres & Tri',
                      style:
                          theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: theme.colorScheme.onSurface,
                          ) ??
                          TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: theme.colorScheme.onSurface,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedStatus = null;
                          _selectedCategoryId = null;
                          _sortOption = AdminTutorielSortOption.newest;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Réinitialiser'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tri
                Text(
                  'Trier par',
                  style:
                      theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ) ??
                      TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSortChip(
                      'Plus récents',
                      AdminTutorielSortOption.newest,
                      setModalState,
                    ),
                    _buildSortChip(
                      'Plus anciens',
                      AdminTutorielSortOption.oldest,
                      setModalState,
                    ),
                    _buildSortChip(
                      'Plus longs',
                      AdminTutorielSortOption.longest,
                      setModalState,
                    ),
                    _buildSortChip(
                      'Plus courts',
                      AdminTutorielSortOption.shortest,
                      setModalState,
                    ),
                    _buildSortChip(
                      'Titre (A-Z)',
                      AdminTutorielSortOption.titleAsc,
                      setModalState,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Filtre par catégorie
                if (categories.isNotEmpty) ...[
                  Text(
                    'Catégorie',
                    style:
                        theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                        ) ??
                        TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedCategoryId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Toutes les catégories'),
                      ),
                      ...categories.map(
                        (c) => DropdownMenuItem(
                          value: c.categorieId,
                          child: Text(c.nom),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setModalState(() => _selectedCategoryId = val);
                      setState(() => _selectedCategoryId = val);
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: 'Appliquer',
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(
    String label,
    AdminTutorielSortOption option,
    StateSetter setModalState,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _sortOption == option;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : theme.colorScheme.onSurface),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (_) {
        setModalState(() => _sortOption = option);
        setState(() => _sortOption = option);
      },
    );
  }

  Future<void> _confirmDelete(Tutoriel tutoriel) async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Supprimer le tutoriel',
      message:
          'Voulez-vous vraiment supprimer "${tutoriel.titre}" ? Cette action est irréversible.',
      confirmText: 'Supprimer',
      isDanger: true,
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(tutorielRepositoryProvider);
        await repository.deleteTutoriel(tutoriel.tutorielId!);
        ref.invalidate(adminTutorielsProvider);
        ref.invalidate(tutorielsProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tutoriel supprimé avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  Future<void> _publishTutoriel(Tutoriel tutoriel) async {
    try {
      final repository = ref.read(tutorielRepositoryProvider);
      await repository.publierTutoriel(tutoriel.tutorielId!);
      ref.invalidate(adminTutorielsProvider);
      ref.invalidate(tutorielsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tutoriel publié avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _unpublishTutoriel(Tutoriel tutoriel) async {
    try {
      final repository = ref.read(tutorielRepositoryProvider);
      await repository.depublierTutoriel(tutoriel.tutorielId!);
      ref.invalidate(adminTutorielsProvider);
      ref.invalidate(tutorielsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tutoriel repassé en brouillon'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Widget _buildAdminSkeleton(ThemeData theme, bool isDark) {
    return CustomScrollView(
      slivers: [
        // Cartes Statistiques Skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: const [
                Expanded(
                  child: AppSkeletonLoader(height: 75, borderRadius: 14),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: AppSkeletonLoader(height: 75, borderRadius: 14),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: AppSkeletonLoader(height: 75, borderRadius: 14),
                ),
              ],
            ),
          ),
        ),

        // Recherche Skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Expanded(
                  child: AppSkeletonLoader(height: 44, borderRadius: 12),
                ),
                SizedBox(width: 10),
                AppSkeletonLoader(width: 44, height: 44, borderRadius: 12),
              ],
            ),
          ),
        ),

        // Chips Skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: const [
                AppSkeletonLoader(width: 75, height: 32, borderRadius: 10),
                SizedBox(width: 8),
                AppSkeletonLoader(width: 85, height: 32, borderRadius: 10),
                SizedBox(width: 8),
                AppSkeletonLoader(width: 90, height: 32, borderRadius: 10),
              ],
            ),
          ),
        ),

        // Liste Skeleton Cards
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: AppSkeletonLoader(height: 110, borderRadius: 16),
              ),
              childCount: 5,
            ),
          ),
        ),
      ],
    );
  }
}
