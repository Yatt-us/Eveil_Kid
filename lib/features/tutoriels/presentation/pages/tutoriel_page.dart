import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/pages/tutoriel_detail_page.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/category_filter.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/tutoriel_card.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/tutoriel_search.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';
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

    final tutoriels = tutorielsAsync.asData?.value ?? const <Tutoriel>[];
    final categories = categoriesAsync.asData?.value ?? const <Categorie>[];
    final filteredTutoriels = _filterTutoriels(tutoriels, _searchQuery, _selectedCategoryId);

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
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const SizedBox(height: 18),
              TutorielSearchField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryFilterChip(
                        label: 'Tous',
                        isSelected: _selectedCategoryId == null,
                        onTap: () => setState(() => _selectedCategoryId = null),
                      ),
                    ),
                    ...categories.map((categorie) {
                      final selected = _selectedCategoryId == categorie.categorieId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryFilterChip(
                          label: categorie.nom,
                          isSelected: selected,
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = selected ? null : categorie.categorieId;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: tutorielsAsync.when(
                  data: (_) {
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
                      itemCount: filteredTutoriels.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final tutoriel = filteredTutoriels[index];
                        return TutorielCard(
                          tutoriel: tutoriel,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TutorielDetailPage(
                                  tutorielId: tutoriel.tutorielId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 44, color: AppColors.danger),
                        const SizedBox(height: 12),
                        const Text(
                          'Impossible de charger les tutoriels.',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(tutorielsProvider),
                          child: const Text('Réessayer'),
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
    );
  }

  List<Tutoriel> _filterTutoriels(
    List<Tutoriel> tutoriels,
    String query,
    String? categoryId,
  ) {
    final normalizedQuery = query.trim().toLowerCase();

    return tutoriels.where((tutoriel) {
      final matchesQuery = normalizedQuery.isEmpty ||
          tutoriel.titre.toLowerCase().contains(normalizedQuery) ||
          tutoriel.description.toLowerCase().contains(normalizedQuery);

      final matchesCategory = categoryId == null ||
          tutoriel.categorieId == categoryId;

      return matchesQuery && matchesCategory;
    }).toList();
  }
}