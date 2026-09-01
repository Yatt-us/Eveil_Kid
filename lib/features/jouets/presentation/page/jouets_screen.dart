import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/core/provider/bottom_nav_bar_provider.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/presentation/page/jouet_card.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/features/panier/presentation/widgets/panier_app_bar_action.dart';
import 'package:eveilkid/features/panier/presentation/widgets/panier_floating_button.dart';
import 'package:eveilkid/shared/widgets/app_bottom_nav_bar.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

class JouetsScreen extends ConsumerStatefulWidget {
  final String utilisateurId;

  const JouetsScreen({super.key, required this.utilisateurId});

  @override
  ConsumerState<JouetsScreen> createState() => _JouetsScreenState();
}

class _JouetsScreenState extends ConsumerState<JouetsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _recherche = '';

  // Filtres avancés
  String? _tri; // 'prix_asc', 'prix_desc', 'nom_asc', 'populaire'
  int? _ageMin;
  int? _ageMax;
  bool _enStockSeulement = false;

  bool get _hasActiveFilters =>
      _tri != null || _ageMin != null || _ageMax != null || _enStockSeulement;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Jouet> _filtrerEtTrierJouets(
    List<Jouet> jouets,
    String? selectedCategory,
  ) {
    var liste = jouets.where((jouet) {
      final rechercheLower = _recherche.trim().toLowerCase();

      final correspondRecherche = rechercheLower.isEmpty ||
          jouet.nom.toLowerCase().contains(rechercheLower) ||
          jouet.description.toLowerCase().contains(rechercheLower);

      final correspondCategorie =
          selectedCategory == null || jouet.categorieId == selectedCategory;

      final correspondStock =
          !_enStockSeulement || jouet.stockDisponible > 0;

      final correspondAge = (_ageMin == null || jouet.ageMaximum >= _ageMin!) &&
          (_ageMax == null || jouet.ageMinimum <= _ageMax!);

      return correspondRecherche &&
          correspondCategorie &&
          correspondStock &&
          correspondAge;
    }).toList();

    // Tri
    if (_tri == 'prix_asc') {
      liste.sort((a, b) => a.prix.compareTo(b.prix));
    } else if (_tri == 'prix_desc') {
      liste.sort((a, b) => b.prix.compareTo(a.prix));
    } else if (_tri == 'nom_asc') {
      liste.sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
    } else if (_tri == 'populaire') {
      liste.sort((a, b) =>
          b.nombreAvisDenormalise.compareTo(a.nombreAvisDenormalise));
    }

    return liste;
  }

  void _openFilterBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.read(categoriesStreamProvider);
    final currentCat = ref.read(selectedCategoryFilterProvider);

    String? tempTri = _tri;
    int? tempAgeMin = _ageMin;
    int? tempAgeMax = _ageMax;
    bool tempStock = _enStockSeulement;
    String? tempCat = currentCat;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Poignée de glissement
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // En-tête avec Titre & Réinitialiser
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              color: theme.colorScheme.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Filtres & Tri',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ) ??
                              const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              tempTri = null;
                              tempAgeMin = null;
                              tempAgeMax = null;
                              tempStock = false;
                              tempCat = null;
                            });
                          },
                          child: Text(
                            'Réinitialiser',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.15)),

                  // Contenu des filtres
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECTION 1: TRI
                          _buildFilterSectionTitle(theme, 'Trier par'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildChoiceChip(
                                label: 'Par défaut',
                                isSelected: tempTri == null,
                                theme: theme,
                                onTap: () => setSheetState(() => tempTri = null),
                              ),
                              _buildChoiceChip(
                                label: 'Prix croissant ↗',
                                isSelected: tempTri == 'prix_asc',
                                theme: theme,
                                onTap: () => setSheetState(() => tempTri = 'prix_asc'),
                              ),
                              _buildChoiceChip(
                                label: 'Prix décroissant ↘',
                                isSelected: tempTri == 'prix_desc',
                                theme: theme,
                                onTap: () => setSheetState(() => tempTri = 'prix_desc'),
                              ),
                              _buildChoiceChip(
                                label: 'Nom A à Z',
                                isSelected: tempTri == 'nom_asc',
                                theme: theme,
                                onTap: () => setSheetState(() => tempTri = 'nom_asc'),
                              ),
                              _buildChoiceChip(
                                label: 'Popularité ⭐',
                                isSelected: tempTri == 'populaire',
                                theme: theme,
                                onTap: () => setSheetState(() => tempTri = 'populaire'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // SECTION 2: TRANCHE D'ÂGE
                          _buildFilterSectionTitle(theme, 'Âge de l\'enfant'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildChoiceChip(
                                label: 'Tous les âges',
                                isSelected: tempAgeMin == null && tempAgeMax == null,
                                theme: theme,
                                onTap: () => setSheetState(() {
                                  tempAgeMin = null;
                                  tempAgeMax = null;
                                }),
                              ),
                              _buildChoiceChip(
                                label: '0 - 2 ans',
                                isSelected: tempAgeMin == 0 && tempAgeMax == 2,
                                theme: theme,
                                onTap: () => setSheetState(() {
                                  tempAgeMin = 0;
                                  tempAgeMax = 2;
                                }),
                              ),
                              _buildChoiceChip(
                                label: '3 - 5 ans',
                                isSelected: tempAgeMin == 3 && tempAgeMax == 5,
                                theme: theme,
                                onTap: () => setSheetState(() {
                                  tempAgeMin = 3;
                                  tempAgeMax = 5;
                                }),
                              ),
                              _buildChoiceChip(
                                label: '6 - 8 ans',
                                isSelected: tempAgeMin == 6 && tempAgeMax == 8,
                                theme: theme,
                                onTap: () => setSheetState(() {
                                  tempAgeMin = 6;
                                  tempAgeMax = 8;
                                }),
                              ),
                              _buildChoiceChip(
                                label: '9 ans et +',
                                isSelected: tempAgeMin == 9 && tempAgeMax == null,
                                theme: theme,
                                onTap: () => setSheetState(() {
                                  tempAgeMin = 9;
                                  tempAgeMax = null;
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // SECTION 3: CATÉGORIE
                          _buildFilterSectionTitle(theme, 'Catégorie'),
                          const SizedBox(height: 10),
                          categoriesAsync.when(
                            loading: () => const LinearProgressIndicator(minHeight: 2),
                            error: (_, _) => const SizedBox.shrink(),
                            data: (cats) {
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildChoiceChip(
                                    label: 'Toutes',
                                    isSelected: tempCat == null,
                                    theme: theme,
                                    onTap: () => setSheetState(() => tempCat = null),
                                  ),
                                  ...cats.map((cat) {
                                    return _buildChoiceChip(
                                      label: cat.nom,
                                      isSelected: tempCat == cat.categorieId,
                                      theme: theme,
                                      onTap: () => setSheetState(() => tempCat = cat.categorieId),
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 22),

                          // SECTION 4: DISPONIBILITÉ
                          _buildFilterSectionTitle(theme, 'Disponibilité'),
                          const SizedBox(height: 8),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'En stock uniquement',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              'Masquer les articles momentanément indisponibles',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            value: tempStock,
                            activeTrackColor: theme.colorScheme.primary,
                            onChanged: (val) => setSheetState(() => tempStock = val),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bouton d'application
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: AppButton(
                      text: 'Appliquer les filtres',
                      icon: Icons.check_rounded,
                      onPressed: () {
                        setState(() {
                          _tri = tempTri;
                          _ageMin = tempAgeMin;
                          _ageMax = tempAgeMax;
                          _enStockSeulement = tempStock;
                        });
                        ref
                            .read(selectedCategoryFilterProvider.notifier)
                            .selectCategory(tempCat);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? theme.colorScheme.primary
          : (isDark
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
              : theme.colorScheme.surface),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.15),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : (theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jouetsAsync = ref.watch(jouetsProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // HEADER
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: _buildHeader(theme),
                      ),
                    ),

                    // RECHERCHE + BOUTON FILTRE
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Expanded(
                              child: AppSearchBar(
                                hintText: 'Rechercher un jouet...',
                                controller: _searchController,
                                onChanged: (value) => setState(() => _recherche = value),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Material(
                              color: _hasActiveFilters
                                  ? theme.colorScheme.primary
                                  : (isDark
                                      ? theme.colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.4)
                                      : theme.colorScheme.surface),
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () => _openFilterBottomSheet(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _hasActiveFilters
                                          ? theme.colorScheme.primary
                                          : theme.dividerColor
                                              .withValues(alpha: isDark ? 0.25 : 0.15),
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.tune_rounded,
                                        color: _hasActiveFilters
                                            ? theme.colorScheme.onPrimary
                                            : (theme.iconTheme.color ??
                                                theme.colorScheme.onSurface),
                                        size: 22,
                                      ),
                                      if (_hasActiveFilters)
                                        Positioned(
                                          top: 9,
                                          right: 9,
                                          child: Container(
                                            width: 7,
                                            height: 7,
                                            decoration: const BoxDecoration(
                                              color: Colors.amber,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // HERO BANNER SANS OVERFLOW
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: _buildHero(theme),
                      ),
                    ),

                    // BARRE DES CATÉGORIES
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      sliver: SliverToBoxAdapter(
                        child: _buildCategoriesBar(theme),
                      ),
                    ),

                    // GRILLE DE JOUETS
                    jouetsAsync.when(
                      loading: () => const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: AppLoadingIndicator(
                            message: 'Chargement des jouets...',
                          ),
                        ),
                      ),
                      error: (error, _) => SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppErrorState(
                          title: 'Impossible de charger la boutique',
                          message: '$error',
                          onRetry: () => ref.invalidate(jouetsProvider),
                        ),
                      ),
                      data: (jouets) {
                        final jouetsFiltres = _filtrerEtTrierJouets(
                          jouets,
                          selectedCategory,
                        );

                        if (jouetsFiltres.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: AppEmptyState(
                              icon: Icons.toys_outlined,
                              title: 'Aucun jouet trouvé',
                              description: _recherche.isNotEmpty
                                  ? 'Aucun résultat pour "$_recherche". Essayez d\'autres termes de recherche.'
                                  : 'Aucun jouet ne correspond aux critères sélectionnés.',
                              actionText: (_recherche.isNotEmpty || _hasActiveFilters)
                                  ? 'Réinitialiser les filtres'
                                  : null,
                              onActionPressed: (_recherche.isNotEmpty || _hasActiveFilters)
                                  ? () {
                                      _searchController.clear();
                                      setState(() {
                                        _recherche = '';
                                        _tri = null;
                                        _ageMin = null;
                                        _ageMax = null;
                                        _enStockSeulement = false;
                                      });
                                      ref
                                          .read(selectedCategoryFilterProvider.notifier)
                                          .selectCategory(null);
                                    }
                                  : null,
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final jouet = jouetsFiltres[index];
                                return JouetCard(
                                  jouet: jouet,
                                  onTap: () {
                                    context.push(
                                      AppRoutes.jouetdetail,
                                      extra: jouet,
                                    );
                                  },
                                );
                              },
                              childCount: jouetsFiltres.length,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: const PanierFloatingButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: const AppBottomNavBar(),
      ),
    );
  }

  // HEADER THÉMATIQUE
  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Text(
          'Boutique',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: theme.colorScheme.onSurface,
          ) ??
          TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        const PanierAppBarAction(),
      ],
    );
  }

  // BANNIÈRE HERO ADAPTATIVE (SANS OVERFLOW)
  Widget _buildHero(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(minHeight: 130),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  theme.colorScheme.primary.withValues(alpha: 0.22),
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                ]
              : [
                  theme.colorScheme.primary.withValues(alpha: 0.12),
                  theme.colorScheme.secondary.withValues(alpha: 0.08),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.2 : 0.1),
        ),
      ),
      child: Stack(
        children: [
          // Image d'illustration sur le côté droit
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            width: 120,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.asset(
                'assets/images/teddy_bear.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.toys_outlined,
                  size: 56,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          // Contenu textuel et action sur la gauche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 120, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Apprendre en jouant',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ) ??
                  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Des jouets éducatifs pour grandir chaque jour 🧒',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    height: 1.25,
                    color: theme.colorScheme.onSurfaceVariant,
                  ) ??
                  TextStyle(
                    fontSize: 12,
                    height: 1.25,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Material(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(selectedCategoryFilterProvider.notifier)
                          .selectCategory(null);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Découvrir',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: theme.colorScheme.onPrimary,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BARRE DE CATÉGORIES DYNAMIQUES
  Widget _buildCategoriesBar(ThemeData theme) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final selectedCategoryId = ref.watch(selectedCategoryFilterProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox(
        height: 38,
        child: Center(child: AppLoadingIndicator(isCompact: true)),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (categories) {
        return SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1, // +1 pour "Tous"
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isTous = index == 0;
              final selected = isTous
                  ? selectedCategoryId == null
                  : selectedCategoryId == categories[index - 1].categorieId;

              final nomCategorie = isTous ? 'Tous' : categories[index - 1].nom;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ref
                        .read(selectedCategoryFilterProvider.notifier)
                        .selectCategory(
                          isTous ? null : categories[index - 1].categorieId,
                        );
                  },
                  borderRadius: AppRadius.circularRadius,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      borderRadius: AppRadius.circularRadius,
                      border: Border.all(
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.dividerColor.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      nomCategorie,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? theme.colorScheme.onPrimary
                            : (theme.textTheme.bodyMedium?.color ??
                                theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
