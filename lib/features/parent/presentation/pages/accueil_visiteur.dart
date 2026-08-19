// lib/features/parent/presentation/pages/accueil_visiteur.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';

class AccueilVisiteurPage extends StatelessWidget {
  const AccueilVisiteurPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: AppPadding.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalSm,
            // --- BANNIÈRE HERO ---
            _buildHeroBanner(context),
            AppSpacing.verticalXxl,

            // --- CATÉGORIES DE JOUETS ---
            _buildSectionHeader(title: 'Categories de jouets', onSeeAll: () {}),
            AppSpacing.verticalMd,
            _buildCategoriesGrid(),
            AppSpacing.verticalXxl,

            // --- BANNIÈRE CRÉATION DE COMPTE ---
            _buildRegisterCtaBanner(context),
            AppSpacing.verticalXxl,

            // --- JOUETS POPULAIRES ---
            _buildSectionHeader(title: 'Jouets populaires', onSeeAll: () {}),
            AppSpacing.verticalMd,
            _buildPopularToysList(),
            AppSpacing.verticalXxl,
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.child_care_rounded, color: AppColors.primary, size: 24),
          ),
          AppSpacing.horizontalSm,
          Text(
            'Eveil Enfant',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary, size: 28),
          onPressed: () {},
        ),
        AppSpacing.horizontalSm,
      ],
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F0),
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Decouvrez le monde du jeu intelligent',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                AppSpacing.verticalSm,
                Text(
                  'Des jouets éducatifs et amusants pour accompagner chaque étape de développement de votre enfant.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                AppSpacing.verticalMd,
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.indigo,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'Explorer les jouets',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.horizontalSm,
          const Icon(Icons.smart_toy, size: 64, color: AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildRegisterCtaBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EC),
        borderRadius: AppRadius.card,
        border: Border.all(color: const Color(0xFFFFD5CC)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rejoignez Éveil Enfant',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                AppSpacing.verticalXs,
                Text(
                  'Créez un compte pour personnaliser l\'expérience de votre enfant.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                AppSpacing.verticalMd,
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'Créer un compte',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.people_alt_rounded, size: 54, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'Voir tout',
            style: AppTextStyles.buttonMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      {
        'title': 'Éveil &\nApprentissage',
        'icon': Icons.menu_book_rounded,
        'bg': const Color(0xFFFFF9E6),
        'color': const Color(0xFF358CED),
      },
      {
        'title': 'Construction\n& Assemblage',
        'icon': Icons.view_in_ar_rounded,
        'bg': const Color(0xFFFFF7E6),
        'color': const Color(0xFFFFA000),
      },
      {
        'title': 'Jeux d\'imitation\n& Rôle',
        'icon': Icons.soup_kitchen_rounded,
        'bg': const Color(0xFFFBF4FF),
        'color': const Color(0xFF9C27B0),
      },
      {
        'title': 'Créatif &\nArtistique',
        'icon': Icons.palette_rounded,
        'bg': const Color(0xFFFFF9E6),
        'color': const Color(0xFFFFB300),
      },
      {
        'title': 'Plein air &\nSport',
        'icon': Icons.sports_soccer_rounded,
        'bg': const Color(0xFFF2FBF6),
        'color': const Color(0xFFE53935),
      },
      {
        'title': 'Poupées &\nPeluches',
        'icon': Icons.pets_rounded,
        'bg': const Color(0xFFFFF4F7),
        'color': const Color(0xFFEC407A),
      },
      {
        'title': 'Jeux de société\n& Puzzles',
        'icon': Icons.extension_rounded,
        'bg': const Color(0xFFF3F7FF),
        'color': const Color(0xFF1E88E5),
      },
      {
        'title': 'Technologie\n& Électronique',
        'icon': Icons.smart_toy_rounded,
        'bg': const Color(0xFFF0F9FF),
        'color': const Color(0xFF00ACC1),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.78,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: cat['bg'] as Color,
            borderRadius: AppRadius.card,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                cat['icon'] as IconData,
                size: 30,
                color: cat['color'] as Color,
              ),
              AppSpacing.verticalXs,
              Text(
                cat['title'] as String,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPopularToysList() {
    return SizedBox(
      height: 195,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.smart_toy_outlined,
                        color: AppColors.primary.withValues(alpha: 0.6),
                        size: 44,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nom du jouet - contenu cccc',
                        style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.verticalXs,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '5000 CFA',
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.star, size: 13, color: AppColors.warning),
                              SizedBox(width: 2),
                              Text('0.0', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}