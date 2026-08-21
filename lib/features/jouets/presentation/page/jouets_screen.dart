// import 'package:eveilkid/features/jouets/presentation/jouet_detail_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:eveilkid/core/constants/AppPadding.dart';
// import 'package:eveilkid/core/constants/AppRadius.dart';
// import 'package:eveilkid/core/constants/AppTextStyles.dart';
// import 'package:eveilkid/core/constants/app_colors.dart';

// import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
// import 'package:eveilkid/features/jouets/models/jouet.dart';
// import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
// import 'package:eveilkid/features/jouets/presentation/page/jouet_card.dart';
// import 'package:eveilkid/features/panier/providers/panier_provider.dart';

// import 'package:eveilkid/shared/widgets/jouet_bottom_navigation.dart';

// class JouetsScreen extends ConsumerStatefulWidget {
//   final String utilisateurId;

//   const JouetsScreen({
//     super.key,
//     required this.utilisateurId,
//   });

//   @override
//   ConsumerState<JouetsScreen> createState() => _JouetsScreenState();
// }

// class _JouetsScreenState extends ConsumerState<JouetsScreen> {
//   final TextEditingController _searchController = TextEditingController();

//   int _currentIndex = 1;
//   String _recherche = '';
//   String? _categorieIdSelectionnee; // null pour "Tous"

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   List<Jouet> _filtrerJouets(List<Jouet> jouets) {
//     return jouets.where((jouet) {
//       final rechercheLower = _recherche.trim().toLowerCase();

//       final correspondRecherche = rechercheLower.isEmpty ||
//           jouet.nom.toLowerCase().contains(rechercheLower) ||
//           jouet.description.toLowerCase().contains(rechercheLower);

//       final correspondCategorie = _categorieIdSelectionnee == null ||
//           jouet.categorieId == _categorieIdSelectionnee;

//       return correspondRecherche && correspondCategorie;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final jouetsAsync = ref.watch(jouetsProvider);

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: CustomScrollView(
//                 slivers: [
//                   // HEADER
//                   SliverPadding(
//                     padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//                     sliver: SliverToBoxAdapter(
//                       child: _buildHeader(),
//                     ),
//                   ),

//                   // RECHERCHE
//                   SliverPadding(
//                     padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//                     sliver: SliverToBoxAdapter(
//                       child: _buildSearchBar(),
//                     ),
//                   ),

//                   // HERO
//                   SliverPadding(
//                     padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//                     sliver: SliverToBoxAdapter(
//                       child: _buildHero(),
//                     ),
//                   ),

//                   // CATEGORIES
//                   SliverPadding(
//                     padding: const EdgeInsets.only(top: 16, bottom: 8),
//                     sliver: SliverToBoxAdapter(
//                       child: _buildCategoriesBar(),
//                     ),
//                   ),

//                   // JOUETS
//                   jouetsAsync.when(
//                     loading: () => const SliverFillRemaining(
//                       hasScrollBody: false,
//                       child: Center(child: CircularProgressIndicator()),
//                     ),
//                     error: (error, stack) => SliverFillRemaining(
//                       hasScrollBody: false,
//                       child: _buildError(error),
//                     ),
//                     data: (jouets) {
//                       final jouetsFiltres = _filtrerJouets(jouets);

//                       if (jouetsFiltres.isEmpty) {
//                         return SliverFillRemaining(
//                           hasScrollBody: false,
//                           child: _buildEmpty(),
//                         );
//                       }

//                       return SliverPadding(
//                         padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
//                         sliver: SliverGrid(
//                           delegate: SliverChildBuilderDelegate(
//                             (context, index) {
//                               final jouet = jouetsFiltres[index];
//                               return JouetCard(
//                                 jouet: jouet,
//                                 onTap: () {
//                                Navigator.of(context).push(
//                                MaterialPageRoute(
//                                 builder: (context) => JouetDetailScreen( jouet: jouet,
//                                  utilisateurId: widget.utilisateurId,
//                                ),
//                               ),
//                              );
//                              },
//                               );
//                             },
//                             childCount: jouetsFiltres.length,
//                           ),
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 12,
//                             mainAxisSpacing: 12,
//                             childAspectRatio: 0.75,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             // NAVIGATION
//             JouetBottomNavigation(
//               currentIndex: _currentIndex,
//               onTap: _onNavigationTap,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _onNavigationTap(int index) {
//     if (index == _currentIndex) return;

//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   // HEADER DYNAMIQUE (Compteur du panier via Riverpod)
//   Widget _buildHeader() {
//     final panierAsync = ref.watch(panierProvider(widget.utilisateurId));

//     final totalArticles = panierAsync.when(
//       data: (articles) => articles.fold<int>(
//         0,
//         (sum, item) => sum + item.quantite,
//       ),
//       loading: () => 0,
//       error: (_, __) => 0,
//     );

//     return Row(
//       children: [
//         Text(
//           'Catalogue',
//           style: AppTextStyles.headingSmall.copyWith(
//             fontSize: 22,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         const Spacer(),
//         Stack(
//           clipBehavior: Clip.none,
//           children: [
//             IconButton(
//               onPressed: () {},
//               icon: const Icon(
//                 Icons.shopping_cart_outlined,
//                 size: 26,
//               ),
//               color: AppColors.textPrimary,
//               padding: EdgeInsets.zero,
//               constraints: const BoxConstraints(),
//             ),
//             if (totalArticles > 0)
//               Positioned(
//                 right: -4,
//                 top: -4,
//                 child: Container(
//                   width: 18,
//                   height: 18,
//                   decoration: const BoxDecoration(
//                     color: AppColors.primary,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: Text(
//                       '$totalArticles',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }

//   // BARRE DE RECHERCHE
//   Widget _buildSearchBar() {
//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             height: 48,
//             decoration: BoxDecoration(
//               color: AppColors.surface,
//               borderRadius: AppRadius.circularRadius,
//               border: Border.all(color: AppColors.border),
//             ),
//             child: TextField(
//               controller: _searchController,
//               onChanged: (value) => setState(() => _recherche = value),
//               style: const TextStyle(fontSize: 14),
//               decoration: const InputDecoration(
//                 hintText: 'Rechercher un jouet...',
//                 hintStyle: TextStyle(
//                   fontSize: 14,
//                   color: AppColors.textSecondary,
//                 ),
//                 prefixIcon: Icon(
//                   Icons.search,
//                   size: 22,
//                   color: AppColors.icon,
//                 ),
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.symmetric(vertical: 12),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             color: AppColors.surface,
//             borderRadius: AppRadius.circularRadius,
//             border: Border.all(color: AppColors.border),
//           ),
//           child: IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.tune, size: 22),
//             color: AppColors.icon,
//           ),
//         ),
//       ],
//     );
//   }

//   // BANIÈRE HERO
//   Widget _buildHero() {
//     return Container(
//       height: 140,
//       decoration: BoxDecoration(
//         color: AppColors.surfaceVariant,
//         borderRadius: AppRadius.card,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 6,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'Apprendre en jouant',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   const Text(
//                     'Des jouets éducatifs pour\ngrandir chaque jour 🧒',
//                     style: TextStyle(
//                       fontSize: 12,
//                       height: 1.3,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     height: 32,
//                     width: 140,
//                     child: ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primary,
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: AppRadius.circularRadius,
//                         ),
//                       ),
//                       child: const Text(
//                         'Découvrir',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 4,
//             child: ClipRRect(
//               borderRadius: const BorderRadius.only(
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//               child: Image.asset(
//                 'assets/images/teddy_bear.png',
//                 fit: BoxFit.contain,
//                 errorBuilder: (context, error, stackTrace) => const Icon(
//                   Icons.toys,
//                   size: 60,
//                   color: AppColors.accent,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // CATEGORIES DYNAMIQUES
//   Widget _buildCategoriesBar() {
//     final categoriesAsync = ref.watch(categoriesPrincipalesProvider);

//     return categoriesAsync.when(
//       loading: () => const SizedBox(
//         height: 40,
//         child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
//       ),
//       error: (_, __) => const SizedBox.shrink(),
//       data: (categories) {
//         return SizedBox(
//           height: 40,
//           child: ListView.separated(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             scrollDirection: Axis.horizontal,
//             itemCount: categories.length + 1, // +1 pour l'option "Tous"
//             separatorBuilder: (_, __) => const SizedBox(width: 8),
//             itemBuilder: (context, index) {
//               final isTous = index == 0;
//               final selected = isTous
//                   ? _categorieIdSelectionnee == null
//                   : _categorieIdSelectionnee == categories[index - 1].categorieId;

//               final nomCategorie = isTous ? 'Tous' : categories[index - 1].nom;

//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _categorieIdSelectionnee =
//                         isTous ? null : categories[index - 1].categorieId;
//                   });
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: selected ? AppColors.primary : AppColors.surface,
//                     borderRadius: AppRadius.circularRadius,
//                     border: selected ? null : Border.all(color: AppColors.border),
//                   ),
//                   child: Text(
//                     nomCategorie,
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
//                       color: selected ? Colors.white : AppColors.textPrimary,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmpty() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.toys_outlined, size: 64, color: AppColors.disabled),
//           SizedBox(height: 12),
//           Text(
//             'Aucun jouet trouvé',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildError(Object error) {
//     return Center(
//       child: Padding(
//         padding: AppPadding.screen,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
//             const SizedBox(height: 12),
//             const Text(
//               'Impossible de charger les jouets',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               '$error',
//               textAlign: TextAlign.center,
//               style: AppTextStyles.bodySmall,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => ref.invalidate(jouetsProvider),
//               child: const Text('Réessayer'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:eveilkid/core/constants/AppPadding.dart';
import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';

import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/features/jouets/presentation/page/jouet_card.dart';
import 'package:eveilkid/features/panier/providers/panier_provider.dart';

import 'package:eveilkid/shared/widgets/jouet_bottom_navigation.dart';

class JouetsScreen extends ConsumerStatefulWidget {
  final String utilisateurId;

  const JouetsScreen({
    super.key,
    required this.utilisateurId,
  });

  @override
  ConsumerState<JouetsScreen> createState() => _JouetsScreenState();
}

class _JouetsScreenState extends ConsumerState<JouetsScreen> {
  final TextEditingController _searchController = TextEditingController();

  int _currentIndex = 1;
  String _recherche = '';
  String? _categorieIdSelectionnee; // null pour "Tous"

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Jouet> _filtrerJouets(List<Jouet> jouets) {
    return jouets.where((jouet) {
      final rechercheLower = _recherche.trim().toLowerCase();

      final correspondRecherche = rechercheLower.isEmpty ||
          jouet.nom.toLowerCase().contains(rechercheLower) ||
          jouet.description.toLowerCase().contains(rechercheLower);

      final correspondCategorie = _categorieIdSelectionnee == null ||
          jouet.categorieId == _categorieIdSelectionnee;

      return correspondRecherche && correspondCategorie;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final jouetsAsync = ref.watch(jouetsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                      child: _buildHeader(),
                    ),
                  ),

                  // RECHERCHE
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: _buildSearchBar(),
                    ),
                  ),

                  // HERO
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: _buildHero(),
                    ),
                  ),

                  // CATEGORIES
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    sliver: SliverToBoxAdapter(
                      child: _buildCategoriesBar(),
                    ),
                  ),

                  // JOUETS
                  jouetsAsync.when(
                    loading: () => const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stack) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildError(error),
                    ),
                    data: (jouets) {
                      final jouetsFiltres = _filtrerJouets(jouets);

                      if (jouetsFiltres.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmpty(),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final jouet = jouetsFiltres[index];
                              return JouetCard(
                                jouet: jouet,
                                onTap: () {
                                  // Utilisation de context.push pour ajouter l'écran au-dessus
                                  // et conserver la flèche Retour (back) native dans JouetDetailScreen.
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

            // NAVIGATION BAS DE PAGE
            JouetBottomNavigation(
              currentIndex: _currentIndex,
              onTap: _onNavigationTap,
            ),
          ],
        ),
      ),
    );
  }

  void _onNavigationTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // Exemple de routage bas de page selon l'onglet cliqué :
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        // Déjà sur le catalogue (JouetsScreen)
        break;
      case 2:
        context.go(AppRoutes.activites);
        break;
      case 3:
        context.go(AppRoutes.tutoriels);
        break;
    }
  }

  // HEADER DYNAMIQUE (Compteur du panier via Riverpod)
  Widget _buildHeader() {
    final panierAsync = ref.watch(panierProvider(widget.utilisateurId));

    final totalArticles = panierAsync.when(
      data: (articles) => articles.fold<int>(
        0,
        (sum, item) => sum + item.quantite,
      ),
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Row(
      children: [
        Text(
          'Catalogue',
          style: AppTextStyles.headingSmall.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                // Naviguer vers la page Panier si elle existe
              },
              icon: const Icon(
                Icons.shopping_cart_outlined,
                size: 26,
              ),
              color: AppColors.textPrimary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            if (totalArticles > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$totalArticles',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // BARRE DE RECHERCHE
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.circularRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _recherche = value),
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Rechercher un jouet...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 22,
                  color: AppColors.icon,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.circularRadius,
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune, size: 22),
            color: AppColors.icon,
          ),
        ),
      ],
    );
  }

  // BANNIÈRE HERO
  Widget _buildHero() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Apprendre en jouant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Des jouets éducatifs pour\ngrandir chaque jour 🧒',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 32,
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.circularRadius,
                        ),
                      ),
                      child: const Text(
                        'Découvrir',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.asset(
                'assets/images/teddy_bear.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.toys,
                  size: 60,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CATEGORIES DYNAMIQUES
  Widget _buildCategoriesBar() {
    final categoriesAsync = ref.watch(categoriesPrincipalesProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) {
        return SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1, // +1 pour l'option "Tous"
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isTous = index == 0;
              final selected = isTous
                  ? _categorieIdSelectionnee == null
                  : _categorieIdSelectionnee == categories[index - 1].categorieId;

              final nomCategorie = isTous ? 'Tous' : categories[index - 1].nom;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _categorieIdSelectionnee =
                        isTous ? null : categories[index - 1].categorieId;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    borderRadius: AppRadius.circularRadius,
                    border: selected ? null : Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    nomCategorie,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? Colors.white : AppColors.textPrimary,
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

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.toys_outlined, size: 64, color: AppColors.disabled),
          SizedBox(height: 12),
          Text(
            'Aucun jouet trouvé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: AppPadding.screen,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Impossible de charger les jouets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(jouetsProvider),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}