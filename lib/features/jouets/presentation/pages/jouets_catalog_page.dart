// lib/features/jouets/presentation/pages/jouets_catalog_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_search_bar.dart';
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
            child: AppSearchBar(
              hintText: 'Rechercher un jouet...',
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
                          categorieId: 'const',
                          createurId: 'admin',
                          nom: 'Blocs de construction bois',
                          description: 'Développe la motricité et l\'imagination',
                          nomCategorieDenormalise: 'Construction',
                          images: const [],
                          imagePrincipaleUrl: '',
                          ageMinimum: 3,
                          ageMaximum: 6,
                          prix: 6500,
                          devise: 'FCFA',
                          stock: 5,
                          stockDisponible: 5,
                          noteMoyenneDenormalise: 4.8,
                          nombreAvisDenormalise: 12,
                          nbTutorielsAssocies: 1,
                          estActif: true,
                          dateCreation: Timestamp.now(),
                          dateModification: Timestamp.now(),
                        ),
                        Jouet(
                          jouetId: '2',
                          categorieId: 'puzz',
                          createurId: 'admin',
                          nom: 'Puzzle chiffres et animaux',
                          description: 'Apprentissage ludique des chiffres',
                          nomCategorieDenormalise: 'Puzzles',
                          images: const [],
                          imagePrincipaleUrl: '',
                          ageMinimum: 2,
                          ageMaximum: 5,
                          prix: 4500,
                          devise: 'FCFA',
                          stock: 8,
                          stockDisponible: 8,
                          noteMoyenneDenormalise: 4.9,
                          nombreAvisDenormalise: 24,
                          nbTutorielsAssocies: 2,
                          estActif: true,
                          dateCreation: Timestamp.now(),
                          dateModification: Timestamp.now(),
                        ),
                        Jouet(
                          jouetId: '3',
                          categorieId: 'tech',
                          createurId: 'admin',
                          nom: 'Robot éducatif interactif',
                          description: 'Initiation à la logique et aux sons',
                          nomCategorieDenormalise: 'Technologie',
                          images: const [],
                          imagePrincipaleUrl: '',
                          ageMinimum: 4,
                          ageMaximum: 8,
                          prix: 12000,
                          devise: 'FCFA',
                          stock: 3,
                          stockDisponible: 3,
                          noteMoyenneDenormalise: 4.7,
                          nombreAvisDenormalise: 8,
                          nbTutorielsAssocies: 3,
                          estActif: true,
                          dateCreation: Timestamp.now(),
                          dateModification: Timestamp.now(),
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
                    '${jouet.ageMinimum}-${jouet.ageMaximum} ans',
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
