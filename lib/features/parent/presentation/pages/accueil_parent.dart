// lib/features/parent/presentation/pages/accueil_parent.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';

class AccueilParentPage extends StatelessWidget {
  final String parentName;
  final List<Map<String, String>> enfants; // Transmis par le Provider Riverpod plus tard

  const AccueilParentPage({
    super.key,
    this.parentName = 'Aissata',
    this.enfants = const [
      {'name': 'Nour', 'age': '5 ans', 'level': 'Niveau 3'},
      {'name': 'Ilyas', 'age': '7 ans', 'level': 'Niveau 4'},
      {'name': 'Mariam', 'age': '4 ans', 'level': 'Niveau 2'},
    ], // Modifier par [] pour tester l'état "sans enfant"
  });

  @override
  Widget build(BuildContext context) {
    final bool aDesEnfants = enfants.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(unreadNotifs: 3),
      body: SingleChildScrollView(
        padding: AppPadding.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalSm,

            // --- EN-TÊTE DYNAMIQUE ---
            Text(
              aDesEnfants ? 'Bonjour, $parentName' : 'Bienvenue !',
              style: AppTextStyles.headingLarge,
            ),
            AppSpacing.verticalXs,
            Text(
              aDesEnfants
                  ? 'Ravie de vous revoir !'
                  : 'Ajouter un enfant pour personnaliser son expérience.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.verticalLg,

            // --- SECTION ENFANTS (CONDITIONNELLE) ---
            if (!aDesEnfants) ...[
              _buildAddChildDottedCard(context),
            ] else ...[
              _buildSectionHeader(title: 'Mes enfants', onSeeAll: () {}),
              AppSpacing.verticalMd,
              _buildChildrenHorizontalList(enfants),
            ],
            AppSpacing.verticalXxl,

            // --- CATÉGORIES DE JOUETS ---
            _buildSectionHeader(title: 'Catégories de jouets', onSeeAll: () {}),
            AppSpacing.verticalMd,
            _buildCategoriesGrid(),
            AppSpacing.verticalXxl,

            // --- BANNIÈRE PROMOTIONNELLE ---
            if (!aDesEnfants) ...[
              _buildPromoBanner(),
              AppSpacing.verticalXxl,
            ],

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

  PreferredSizeWidget _buildAppBar({required int unreadNotifs}) {
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
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.icon, size: 28),
              onPressed: () {},
            ),
            if (unreadNotifs > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: AppPadding.allXs,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$unreadNotifs',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        AppSpacing.horizontalSm,
      ],
    );
  }

  Widget _buildAddChildDottedCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.primaryLight, width: 1.5),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: AppRadius.card,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppPadding.allSm,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.white, size: 24),
            ),
            AppSpacing.verticalSm,
            Text(
              'Ajouter un enfant',
              style: AppTextStyles.buttonMedium.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenHorizontalList(List<Map<String, String>> children) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: children.length + 1,
        itemBuilder: (context, index) {
          if (index == children.length) {
            return _buildAddChildMiniCard();
          }

          final child = children[index];
          return Container(
            width: 110,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: AppPadding.cardSmall,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.childCard,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.surfaceVariant,
                  child: Icon(Icons.person, color: AppColors.primary, size: 30),
                ),
                AppSpacing.verticalSm,
                Text(
                  child['name']!,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(child['age']!, style: AppTextStyles.bodySmall),
                AppSpacing.verticalXs,
                Container(
                  padding: AppPadding.horizontalSm,
                  decoration: const BoxDecoration(
                    color: AppColors.childSurfaceVariant,
                    borderRadius: AppRadius.badge,
                  ),
                  child: Text(
                    child['level']!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.childTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddChildMiniCard() {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.childCard,
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: AppRadius.childCard,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 32, color: AppColors.primary),
            AppSpacing.verticalSm,
            Text(
              'Ajouter\nun enfant',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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

  Widget _buildPromoBanner() {
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
                  'Des jouets pour chaque étape de leur croissance',
                  style: AppTextStyles.headingSmall,
                ),
                AppSpacing.verticalMd,
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: AppPadding.buttonSmall,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonSmall),
                  ),
                  child: const Text('Découvrir', style: AppTextStyles.buttonLarge),
                ),
              ],
            ),
          ),
          AppSpacing.horizontalMd,
          const Icon(Icons.smart_toy, size: 60, color: AppColors.warning),
        ],
      ),
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