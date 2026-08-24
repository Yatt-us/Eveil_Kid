import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/category_filter.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/tutoriel_card.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/tutoriel_search.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';
import 'package:eveilkid/shared/widgets/app_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TutorielPage extends ConsumerStatefulWidget {
  const TutorielPage({super.key});

  @override
  ConsumerState<TutorielPage> createState() => _TutorielPageState();
}

class _TutorielPageState extends ConsumerState<TutorielPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tutorielsAsync = ref.watch(tutorielsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,

        title: const Text(
          'Tutoriels',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),

        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // =========================
              // RECHERCHE
              // =========================
              const SizedBox(height: 18),

              TutorielSearchField(
                controller: _searchController,

                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              // =========================
              // FILTRE CATÉGORIES
              // =========================
              SizedBox(
                height: 42,

                child: categoriesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),

                  error: (_, __) => const SizedBox(),

                  data: (categories) {
                    return ListView(
                      scrollDirection: Axis.horizontal,

                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),

                          child: CategoryFilterChip(
                            label: 'Tous',

                            isSelected: _selectedCategoryId == null,

                            onTap: () {
                              setState(() {
                                _selectedCategoryId = null;
                              });
                            },
                          ),
                        ),

                        ...categories.map((categorie) {
                          final isSelected =
                              _selectedCategoryId ==
                              categorie.categorieId;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),

                            child: CategoryFilterChip(
                              label: categorie.nom,

                              isSelected: isSelected,

                              onTap: () {
                                setState(() {
                                  _selectedCategoryId =
                                      isSelected
                                          ? null
                                          : categorie.categorieId;
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // LISTE DES TUTORIELS
              // =========================
              Expanded(
                child: tutorielsAsync.when(

                  // -------------------------
                  // DONNÉES
                  // -------------------------
                  data: (tutoriels) {
                    final filteredTutoriels =
                        _filterTutoriels(
                          tutoriels,
                          _searchQuery,
                          _selectedCategoryId,
                        );

                    if (filteredTutoriels.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aucun tutoriel ne correspond à votre recherche.',

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(
                        bottom: 20,
                      ),

                      itemCount: filteredTutoriels.length,

                      separatorBuilder: (_, __) {
                        return const SizedBox(height: 16);
                      },

                      itemBuilder: (context, index) {
                        final tutoriel =
                            filteredTutoriels[index];

                        return TutorielCard(
                          tutoriel: tutoriel,
                        );
                      },
                    );
                  },

                  // -------------------------
                  // CHARGEMENT
                  // -------------------------
                  loading: () {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },

                  // -------------------------
                  // ERREUR
                  // -------------------------
                  error: (error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          const Icon(
                            Icons.error_outline_rounded,

                            size: 44,

                            color: AppColors.danger,
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Impossible de charger les tutoriels.',

                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            error.toString(),

                            textAlign: TextAlign.center,

                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),

                          const SizedBox(height: 12),

                          ElevatedButton(
                            onPressed: () {
                              ref.invalidate(
                                tutorielsProvider,
                              );
                            },

                            child: const Text(
                              'Réessayer',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: AppBottomNavBar(),
    );
  }

  // =====================================================
  // FILTRAGE DES TUTORIELS
  // =====================================================

  List<Tutoriel> _filterTutoriels(
    List<Tutoriel> tutoriels,
    String query,
    String? categoryId,
  ) {
    final normalizedQuery =
        query.trim().toLowerCase();

    return tutoriels.where((tutoriel) {
      // Recherche par titre ou description
      final matchesQuery =
          normalizedQuery.isEmpty ||
          tutoriel.titre
              .toLowerCase()
              .contains(normalizedQuery) ||
          tutoriel.description
              .toLowerCase()
              .contains(normalizedQuery);

      // Filtre par catégorie
      final matchesCategory =
          categoryId == null ||
          tutoriel.categorieId == categoryId;

      return matchesQuery && matchesCategory;
    }).toList();
  }
}