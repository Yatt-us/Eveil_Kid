// lib/features/parent/presentation/pages/accueil_parent.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../models/parent_model.dart';
import '../../providers/parent_provider.dart';
import 'ajouter_enfant.dart';
import 'liste_enfants.dart';

class AccueilParentPage extends ConsumerWidget {
  const AccueilParentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentAsync = ref.watch(parentNotifierProvider);

    return parentAsync.when(
      data: (parent) => _buildScaffold(context, parent),
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: SingleChildScrollView(
            padding: AppPadding.screen,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
                AppSpacing.verticalMd,
                Text('Erreur lors du chargement', style: AppTextStyles.headingSmall),
                AppSpacing.verticalSm,
                Text(
                  '$err',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.verticalLg,
                ElevatedButton(
                  onPressed: () => ref.invalidate(parentNotifierProvider),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, ParentModel parent) {
    final bool aDesEnfants = parent.enfants.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(unreadNotifs: 3),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppPadding.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.verticalSm,

              // --- EN-TÊTE DYNAMIQUE ---
              Text(
                aDesEnfants ? 'Bonjour, ${parent.name}' : 'Bienvenue !',
                style: AppTextStyles.headingLarge.copyWith(fontWeight: FontWeight.w800),
              ),
              AppSpacing.verticalXs,
              Text(
                aDesEnfants
                    ? 'Ravie de vous revoir !'
                    : 'Ajouter un enfant pour personnalise\nson experiance.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              AppSpacing.verticalLg,

              // --- SECTION ENFANTS (CONDITIONNELLE) ---
              if (!aDesEnfants) ...[
                _buildAddChildBigDottedCard(context),
              ] else ...[
                _buildSectionHeader(
                  title: 'Mes enfants',
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ListeEnfantsPage()),
                    );
                  },
                ),
                AppSpacing.verticalMd,
                _buildChildrenHorizontalList(context, parent.enfants),
              ],
              AppSpacing.verticalXxl,

              // --- CATÉGORIES DE JOUETS ---
              _buildSectionHeader(title: 'Categories de jouets', onSeeAll: () {}),
              AppSpacing.verticalMd,
              _buildCategoriesGrid(),
              AppSpacing.verticalXxl,

              // --- BANNIÈRE PROMOTIONNELLE (SI PAS D'ENFANTS) ---
              if (!aDesEnfants) ...[
                _buildPromoBanner(context),
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({required int unreadNotifs}) {
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
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary, size: 28),
              onPressed: () {},
            ),
            if (unreadNotifs > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$unreadNotifs',
                    style: const TextStyle(
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

  Widget _buildAddChildBigDottedCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AjouterEnfantPage()),
          );
        },
        borderRadius: AppRadius.card,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.white, size: 24),
            ),
            AppSpacing.verticalSm,
            Text(
              'Ajouter un enfant',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenHorizontalList(BuildContext context, List<EnfantModel> children) {
    final displayChildren = children.take(3).toList();

    return SizedBox(
      height: 175,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayChildren.length + 1,
        itemBuilder: (context, index) {
          if (index == displayChildren.length) {
            return _buildAddChildMiniCard(context);
          }

          final child = displayChildren[index];

          // Badges colorés selon le niveau comme sur l'image
          Color badgeBg;
          Color badgeText;

          if (child.level.contains('3')) {
            badgeBg = const Color(0xFFEDE7F6);
            badgeText = const Color(0xFF7E57C2);
          } else if (child.level.contains('4')) {
            badgeBg = const Color(0xFFE0F2F1);
            badgeText = const Color(0xFF00897B);
          } else {
            badgeBg = const Color(0xFFFFF3E0);
            badgeText = const Color(0xFFFB8C00);
          }

          return Container(
            width: 115,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.surfaceVariant,
                  child: Icon(
                    Icons.face_rounded,
                    color: badgeText,
                    size: 36,
                  ),
                ),
                AppSpacing.verticalSm,
                Text(
                  child.name,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${child.age} ans',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                AppSpacing.verticalXs,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: AppRadius.badge,
                  ),
                  child: Text(
                    child.level,
                    style: TextStyle(
                      color: badgeText,
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

  Widget _buildAddChildMiniCard(BuildContext context) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AjouterEnfantPage()),
          );
        },
        borderRadius: AppRadius.card,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 36, color: AppColors.textPrimary),
            AppSpacing.verticalSm,
            Text(
              'Ajouter\nun enfant',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
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

  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: const Color(0xFFF1EEFA),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.verticalMd,
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'Découvrir',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.horizontalMd,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, size: 48, color: AppColors.warning),
          ),
        ],
      ),
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
