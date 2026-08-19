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
            // --- BANNIÈRE D'ACCUEIL VISITEUR ---
            _buildHeroBanner(),
            AppSpacing.verticalXxl,

            // --- CATÉGORIES DE JOUETS ---
            _buildSectionHeader(title: 'Catégories de jouets', onSeeAll: () {}),
            AppSpacing.verticalMd,
            _buildCategoriesGrid(),
            AppSpacing.verticalXxl,

            // --- BANNIÈRE INVITATION CRÉATION DE COMPTE ---
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
      backgroundColor: AppColors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: AppPadding.allXs,
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.child_care, color: AppColors.primary, size: 24),
          ),
          AppSpacing.horizontalSm,
          Text(
            'Eveil Enfant',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.icon, size: 28),
          onPressed: () {},
        ),
        AppSpacing.horizontalSm,
      ],
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: AppPadding.cardLarge,
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Découvrez le monde du jeu intelligent',
                  style: AppTextStyles.headingSmall,
                ),
                AppSpacing.verticalXs,
                Text(
                  'Des jouets éducatifs et amusants pour accompagner chaque étape.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                AppSpacing.verticalMd,
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: AppPadding.buttonSmall,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonSmall),
                  ),
                  child: const Text('Explorer les jouets', style: AppTextStyles.buttonLarge),
                ),
              ],
            ),
          ),
          AppSpacing.horizontalSm,
          const Icon(Icons.smart_toy, size: 70, color: AppColors.primaryLight),
        ],
      ),
    );
  }

  Widget _buildRegisterCtaBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.2),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rejoignez Éveil Enfant', style: AppTextStyles.headingSmall),
                AppSpacing.verticalXs,
                Text(
                  'Créez un compte pour personnaliser l\'expérience de votre enfant.',
                  style: AppTextStyles.bodySmall,
                ),
                AppSpacing.verticalMd,
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: AppPadding.buttonSmall,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonSmall),
                  ),
                  child: const Text('Créer un compte', style: AppTextStyles.buttonLarge),
                ),
              ],
            ),
          ),
          const Icon(Icons.people_alt, size: 60, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headingSmall),
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
      'Éveil &\nApprentissage',
      'Construction\n& Assemblage',
      'Jeux d\'imitation\n& Rôle',
      'Créatif &\nArtistique',
      'Plein air &\nSport',
      'Poupées &\nPeluches',
      'Jeux de société\n& Puzzles',
      'Technologie\n& Électronique',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.75,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Container(
          padding: AppPadding.allXs,
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadius.card,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.toys_outlined, size: 28, color: AppColors.primary),
              AppSpacing.verticalXs,
              Text(
                categories[index],
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.card,
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
                    child: const Center(
                      child: Icon(Icons.image, color: AppColors.disabled, size: 40),
                    ),
                  ),
                ),
                Padding(
                  padding: AppPadding.cardSmall,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nom du jouet',
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.verticalXs,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '5000 CFA',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: const [
                              Icon(Icons.star, size: 12, color: AppColors.warning),
                              AppSpacing.horizontalXs,
                              Text('0.0', style: AppTextStyles.bodySmall),
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