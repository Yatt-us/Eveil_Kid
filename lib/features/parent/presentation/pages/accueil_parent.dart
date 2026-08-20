// lib/features/parent/presentation/pages/accueil_parent.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../jouets/models/jouet.dart';
import '../../../jouets/providers/jouet_provider.dart';
import '../../models/parent_model.dart';
import '../../providers/parent_provider.dart';
import 'ajouter_enfant.dart';
import 'liste_enfants.dart';
import 'notification_settings_page.dart';

class AccueilParentPage extends ConsumerWidget {
  final ValueChanged<int>? onNavigateTab;

  const AccueilParentPage({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final parentAsync = ref.watch(parentNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, isAuthenticated),
      body: RefreshIndicator(
        onRefresh: () async {
          if (isAuthenticated) {
            ref.invalidate(parentNotifierProvider);
          }
          ref.invalidate(jouetsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppPadding.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.verticalSm,

              // ── EN-TÊTE OU BANNIÈRE HERO SELON L'ÉTAT DE CONNEXION ──
              if (isAuthenticated) ...[
                parentAsync.when(
                  data: (parent) => _buildConnectedHeader(context, parent),
                  loading: () => _buildHeaderSkeleton(),
                  error: (_, __) => _buildConnectedHeader(
                    context,
                    UtilisateurModel(
                      utilisateurId: '',
                      email: authState.utilisateur?.email ?? '',
                      nom: authState.utilisateur?.nom ?? 'Parent',
                    ),
                  ),
                ),
              ] else ...[
                _buildVisitorHeroBanner(context),
              ],
              AppSpacing.verticalXxl,

              // ── SECTION ENFANTS (SI CONNECTÉ) ──
              if (isAuthenticated) ...[
                parentAsync.when(
                  data: (parent) {
                    if (parent.enfants.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAddChildBigCard(context),
                          AppSpacing.verticalXxl,
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            title: 'Mes enfants',
                            actionText: 'Voir tout',
                            onActionPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ListeEnfantsPage()),
                              );
                            },
                          ),
                          AppSpacing.verticalMd,
                          _buildChildrenHorizontalList(context, parent.enfants),
                          AppSpacing.verticalXxl,
                        ],
                      );
                    }
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],

              // ── CATÉGORIES DE JOUETS (Rendu réaliste et coloré) ──
              _buildSectionHeader(
                title: 'Catégories de jouets',
                actionText: 'Voir tout',
                onActionPressed: () {
                  if (onNavigateTab != null) {
                    onNavigateTab!(1); // Onglet Jouets
                  } else {
                    AppDialogs.showSnackBar(
                      context: context,
                      message: 'Explorez nos catégories dans l\'onglet Jouets.',
                    );
                  }
                },
              ),
              AppSpacing.verticalMd,
              _buildRealisticCategoriesGrid(context),
              AppSpacing.verticalXxl,

              // ── BANNIÈRE CRÉATION DE COMPTE (POUR VISITEUR) ──
              if (!isAuthenticated) ...[
                _buildVisitorRegisterBanner(context),
                AppSpacing.verticalXxl,
              ] else ...[
                _buildDiscoveryBanner(context),
                AppSpacing.verticalXxl,
              ],

              // ── JOUETS POPULAIRES ──
              _buildSectionHeader(
                title: 'Jouets populaires',
                actionText: 'Voir tout',
                onActionPressed: () {
                  if (onNavigateTab != null) {
                    onNavigateTab!(1); // Onglet Jouets
                  } else {
                    AppDialogs.showSnackBar(
                      context: context,
                      message: 'Découvrez toute la collection dans l\'onglet Jouets.',
                    );
                  }
                },
              ),
              AppSpacing.verticalMd,
              _buildPopularToysList(context, ref),
              AppSpacing.verticalXxl,
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isAuthenticated) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E54E9), AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.child_care_rounded, color: AppColors.white, size: 22),
          ),
          AppSpacing.horizontalSm,
          Text(
            'Éveil Kid',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 26),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationSettingsPage()),
            );
          },
        ),
        AppSpacing.horizontalSm,
      ],
    );
  }

  Widget _buildConnectedHeader(BuildContext context, ParentModel parent) {
    final hasChildren = parent.enfants.isNotEmpty;
    final displayName = parent.name.isNotEmpty ? parent.name : 'Parent';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasChildren ? 'Bonjour, $displayName 👋' : 'Bienvenue !',
          style: AppTextStyles.headingLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        AppSpacing.verticalXs,
        Text(
          hasChildren
              ? 'Ravi de vous revoir parmi nous !'
              : 'Ajoutez votre enfant pour personnaliser son expérience et ses recommandations.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 180,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        AppSpacing.verticalSm,
        Container(
          width: 260,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitorHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Découvrez le monde du jeu intelligent 🚀',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF78350F),
                    height: 1.25,
                  ),
                ),
                AppSpacing.verticalSm,
                const Text(
                  'Des jouets éducatifs et interactifs pour accompagner chaque étape d\'éveil de votre enfant.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF92400E),
                    height: 1.3,
                  ),
                ),
                AppSpacing.verticalMd,
                ElevatedButton(
                  onPressed: () {
                    if (onNavigateTab != null) {
                      onNavigateTab!(1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Explorer les jouets',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.horizontalSm,
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              size: 52,
              color: Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorRegisterBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rejoignez Éveil Kid 🌟',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.verticalXs,
                const Text(
                  'Créez un compte gratuit pour enregistrer vos enfants et suivre leurs progrès.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                AppSpacing.verticalMd,
                ElevatedButton(
                  onPressed: () {
                    try {
                      context.push(AppRoutes.register);
                    } catch (_) {
                      Navigator.pushNamed(context, '/register');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'Créer un compte',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.horizontalMd,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.family_restroom_rounded,
              size: 42,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        border: Border.all(color: const Color(0xFFBFDBFE)),
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.verticalMd,
                ElevatedButton(
                  onPressed: () {
                    if (onNavigateTab != null) {
                      onNavigateTab!(1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'Découvrir',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.horizontalMd,
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars_rounded, size: 42, color: AppColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildAddChildBigCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AjouterEnfantPage()),
          );
        },
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppColors.white, size: 26),
              ),
              AppSpacing.verticalSm,
              Text(
                'Ajouter un enfant',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.verticalXs,
              const Text(
                'Personnalisez son catalogue et ses défis',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildrenHorizontalList(BuildContext context, List<EnfantModel> children) {
    final displayChildren = children.take(4).toList();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayChildren.length + 1,
        itemBuilder: (context, index) {
          if (index == displayChildren.length) {
            return _buildAddChildMiniCard(context);
          }

          final child = displayChildren[index];

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
            width: 120,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: badgeBg,
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
        border: Border.all(color: AppColors.border),
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
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 24, color: AppColors.primary),
            ),
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

  Widget _buildRealisticCategoriesGrid(BuildContext context) {
    final categories = [
      {
        'title': 'Éveil &\nApprentissage',
        'icon': Icons.auto_stories_rounded,
        'bgGradient': [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
        'iconColor': const Color(0xFF2563EB),
        'borderColor': const Color(0xFFBFDBFE),
      },
      {
        'title': 'Construction\n& Assemblage',
        'icon': Icons.view_in_ar_rounded,
        'bgGradient': [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
        'iconColor': const Color(0xFFD97706),
        'borderColor': const Color(0xFFFDE68A),
      },
      {
        'title': 'Jeux d\'imitation\n& Rôle',
        'icon': Icons.theater_comedy_rounded,
        'bgGradient': [const Color(0xFFFAF5FF), const Color(0xFFF3E8FF)],
        'iconColor': const Color(0xFF9333EA),
        'borderColor': const Color(0xFFE9D5FF),
      },
      {
        'title': 'Créatif &\nArtistique',
        'icon': Icons.palette_rounded,
        'bgGradient': [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)],
        'iconColor': const Color(0xFFEA580C),
        'borderColor': const Color(0xFFFED7AA),
      },
      {
        'title': 'Plein air &\nSport',
        'icon': Icons.sports_soccer_rounded,
        'bgGradient': [const Color(0xFFFEF2F2), const Color(0xFFFEE2E2)],
        'iconColor': const Color(0xFFDC2626),
        'borderColor': const Color(0xFFFECACA),
      },
      {
        'title': 'Poupées &\nPeluches',
        'icon': Icons.cruelty_free_rounded,
        'bgGradient': [const Color(0xFFFDF2F8), const Color(0xFFFCE7F3)],
        'iconColor': const Color(0xFFDB2777),
        'borderColor': const Color(0xFFFBCFE8),
      },
      {
        'title': 'Jeux de société\n& Puzzles',
        'icon': Icons.extension_rounded,
        'bgGradient': [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
        'iconColor': const Color(0xFF0284C7),
        'borderColor': const Color(0xFFBAE6FD),
      },
      {
        'title': 'Technologie\n& Électronique',
        'icon': Icons.smart_toy_rounded,
        'bgGradient': [const Color(0xFFF0FDFA), const Color(0xFFCCFBF1)],
        'iconColor': const Color(0xFF0D9488),
        'borderColor': const Color(0xFF99F6E4),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.76,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final gradientColors = cat['bgGradient'] as List<Color>;
        final iconColor = cat['iconColor'] as Color;
        final borderColor = cat['borderColor'] as Color;

        return InkWell(
          onTap: () {
            if (onNavigateTab != null) {
              onNavigateTab!(1);
            } else {
              AppDialogs.showSnackBar(
                context: context,
                message: 'Catégorie sélectionnée : ${cat['title'].toString().replaceAll('\n', ' ')}',
              );
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    cat['icon'] as IconData,
                    size: 24,
                    color: iconColor,
                  ),
                ),
                AppSpacing.verticalSm,
                Text(
                  cat['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularToysList(BuildContext context, WidgetRef ref) {
    final jouetsAsync = ref.watch(jouetsProvider);

    return SizedBox(
      height: 205,
      child: jouetsAsync.when(
        data: (jouets) {
          final items = jouets.isNotEmpty
              ? jouets.take(5).toList()
              : [
                  Jouet(
                    jouetId: '1',
                    nom: 'Blocs de construction bois',
                    description: 'Jeu d\'éveil créatif',
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
                    description: 'Apprentissage ludique',
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
                    description: 'Technologie pour enfants',
                    prix: 12000,
                    categorieId: 'tech',
                    stock: 3,
                    ageMin: 4,
                    ageMax: 8,
                    estActif: true,
                    dateCreation: DateTime.now(),
                    dateModification: DateTime.now(),
                  ),
                ];

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final jouet = items[index];
              return _buildToyCard(context, jouet);
            },
          );
        },
        loading: () => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, index) => Container(
            width: 175,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadius.card,
            ),
          ),
        ),
        error: (_, __) => const Center(child: Text('Erreur chargement jouets')),
      ),
    );
  }

  Widget _buildToyCard(BuildContext context, Jouet jouet) {
    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: AppSpacing.md),
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
                  child: jouet.images.isNotEmpty
                      ? Image.network(
                          jouet.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.smart_toy_outlined,
                            color: AppColors.primary,
                            size: 44,
                          ),
                        )
                      : const Icon(
                          Icons.smart_toy_outlined,
                          color: AppColors.primary,
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
                  AppSpacing.verticalXs,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${jouet.prix.toInt()} CFA',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                          SizedBox(width: 2),
                          Text('4.8', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        ],
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

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onActionPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: onActionPressed,
          child: Text(
            actionText,
            style: AppTextStyles.buttonMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
