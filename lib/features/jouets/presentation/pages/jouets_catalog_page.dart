// lib/features/jouets/presentation/pages/jouets_catalog_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../models/jouet.dart';
import '../../providers/jouet_provider.dart';

class JouetsCatalogPage extends ConsumerStatefulWidget {
  const JouetsCatalogPage({super.key});

  @override
  ConsumerState<JouetsCatalogPage> createState() => _JouetsCatalogPageState();
}

class _JouetsCatalogPageState extends ConsumerState<JouetsCatalogPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Tous';

  final List<String> _categories = [
    'Tous',
    'Éveil & Apprentissage',
    'Construction',
    'Jeux d\'imitation',
    'Créatif',
    'Plein air',
    'Puzzles',
    'Technologie',
  ];

  @override
  Widget build(BuildContext context) {
    final jouetsAsync = ref.watch(jouetsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Catalogue de Jouets',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── BARRE DE RECHERCHE ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un jouet...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.icon),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fillColor: AppColors.surface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.input,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.input,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // ── FILTRES CATÉGORIES (CHIPS) ──
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              },
            ),
          ),
          AppSpacing.verticalSm,

          // ── GRILLE DES JOUETS ──
          Expanded(
            child: jouetsAsync.when(
              data: (jouets) {
                var list = jouets.isNotEmpty
                    ? jouets
                    : [
                        Jouet(
                          jouetId: '1',
                          nom: 'Blocs de construction bois',
                          description: 'Développe la motricité et l\'imagination',
                          prix: 6500,
                          categorieId: 'const',
                          stock: 5,
                          ageMin: 3,
                          ageMax: 6,
                          estActif: true,
                          dateCreation: DateTime.now(),
                          dateModification: DateTime.now(),
                        ),
                        Jouet(
                          jouetId: '2',
                          nom: 'Puzzle chiffres et animaux',
                          description: 'Apprentissage ludique des chiffres',
                          prix: 4500,
                          categorieId: 'puzz',
                          stock: 8,
                          ageMin: 2,
                          ageMax: 5,
                          estActif: true,
                          dateCreation: DateTime.now(),
                          dateModification: DateTime.now(),
                        ),
                        Jouet(
                          jouetId: '3',
                          nom: 'Robot éducatif interactif',
                          description: 'Initiation à la logique et aux sons',
                          prix: 12000,
                          categorieId: 'tech',
                          stock: 3,
                          ageMin: 4,
                          ageMax: 8,
                          estActif: true,
                          dateCreation: DateTime.now(),
                          dateModification: DateTime.now(),
                        ),
                        Jouet(
                          jouetId: '4',
                          nom: 'Set de peinture à doigts bio',
                          description: 'Couleurs lavables non toxiques',
                          prix: 3800,
                          categorieId: 'art',
                          stock: 12,
                          ageMin: 2,
                          ageMax: 7,
                          estActif: true,
                          dateCreation: DateTime.now(),
                          dateModification: DateTime.now(),
                        ),
                        Jouet(
                          jouetId: '5',
                          nom: 'Jeu d\'éveil musical xylophone',
                          description: 'Éveil aux rythmes et mélodies',
                          prix: 5500,
                          categorieId: 'mus',
                          stock: 6,
                          ageMin: 1,
                          ageMax: 4,
                          estActif: true,
                          dateCreation: DateTime.now(),
                          dateModification: DateTime.now(),
                        ),
                        Jouet(
                          jouetId: '6',
                          nom: 'Cuisine miniature en bois',
                          description: 'Jeux d\'imitation et de partage',
                          prix: 18500,
                          categorieId: 'role',
                          stock: 2,
                          ageMin: 3,
                          ageMax: 8,
                          estActif: true,
                          dateCreation: DateTime.now(),
                          dateModification: DateTime.now(),
                        ),
                      ];

                if (_searchQuery.isNotEmpty) {
                  list = list.where((j) => j.nom.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                }

                if (list.isEmpty) {
                  return const Center(child: Text('Aucun jouet trouvé'));
                }

                return GridView.builder(
                  padding: AppPadding.screen,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final jouet = list[index];
                    return _buildJouetGridCard(context, jouet);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('Erreur: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJouetGridCard(BuildContext context, Jouet jouet) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          AppDialogs.showSnackBar(
            context: context,
            message: '${jouet.nom} - ${jouet.prix.toInt()} CFA',
          );
        },
        borderRadius: AppRadius.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF8F7FC), Color(0xFFEDE9FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                ),
                child: Center(
                  child: const Icon(
                    Icons.smart_toy_outlined,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jouet.nom,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${jouet.ageMin}-${jouet.ageMax} ans',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${jouet.prix.toInt()} CFA',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart_rounded,
                          color: AppColors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
