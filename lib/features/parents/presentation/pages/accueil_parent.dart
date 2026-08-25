// lib/features/parents/presentation/pages/accueil_parent.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/email_verification_banner.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../jouets/models/jouet.dart';
import '../../../jouets/presentation/page/jouet_detail_screen.dart';
import '../../../jouets/providers/jouet_provider.dart';
import '../../../auth/models/utilisateur.dart';
import '../../../../core/provider/bottom_nav_bar_provider.dart';
import '../../../categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import '../../providers/parent_provider.dart';
import 'ajouter_enfant.dart';
import 'detail_enfant.dart';
import 'liste_enfants.dart';
import 'notification_settings_page.dart';

class AccueilParentPage extends ConsumerWidget {
  final ValueChanged<int>? onNavigateTab;

  const AccueilParentPage({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final isEmailVerified = authState.isEmailVerified;
    final isFullyVerified = isAuthenticated && isEmailVerified;
    final parentAsync = ref.watch(parentNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, ref, isFullyVerified, isAuthenticated),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () async {
          if (isAuthenticated) {
            ref.invalidate(parentNotifierProvider);
            ref.read(authProvider.notifier).reloadAndCheckEmailVerified();
          }
          ref.invalidate(jouetsProvider);
          ref.invalidate(categoriesStreamProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppPadding.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.verticalSm,

              // ── BANNIÈRE DE VÉRIFICATION EMAIL (SI CONNECTÉ ET NON VÉRIFIÉ) ──
              if (isAuthenticated && !isEmailVerified) ...[
                const EmailVerificationBanner(),
                AppSpacing.verticalLg,
              ],

              // ── EN-TÊTE OU BANNIÈRE HERO SELON L'ÉTAT DE VÉRIFICATION ──
              if (isFullyVerified) ...[
                parentAsync.when(
                  data: (parent) => _buildConnectedHeader(context, parent),
                  loading: () => _buildHeaderSkeleton(context),
                  error: (_, _) => _buildConnectedHeader(
                    context,
                    Utilisateur(
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

              // ── SECTION ENFANTS (UNIQUEMENT SI COMPTE PLEINEMENT VÉRIFIÉ) ──
              if (isFullyVerified) ...[
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
                            context: context,
                            title: 'Mes enfants',
                            actionText: 'Voir tout',
                            onActionPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ListeEnfantsPage(),
                                ),
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
                  loading: () => _buildChildrenSkeleton(context),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],

              // ── CATÉGORIES DE JOUETS (Rendu réaliste et coloré) ──
              _buildSectionHeader(
                context: context,
                title: 'Catégories de jouets',
                actionText: 'Voir tout',
                onActionPressed: () {
                  ref.read(selectedCategoryFilterProvider.notifier).clear();
                  ref.read(bottomIndexProvider.notifier).setIndex(1);
                  context.go(AppRoutes.jouetscreen);
                },
              ),
              AppSpacing.verticalMd,
              _buildRealisticCategoriesGrid(context, ref),
              AppSpacing.verticalXxl,

              // ── BANNIÈRE DÉCOUVERTE (POUR PARENT CONNECTÉ) ──
              if (isAuthenticated) ...[
                _buildDiscoveryBanner(context, ref),
                AppSpacing.verticalXxl,
              ],

              // ── JOUETS POPULAIRES ──
              _buildSectionHeader(
                context: context,
                title: 'Jouets populaires',
                actionText: 'Voir tout',
                onActionPressed: () {
                  if (onNavigateTab != null) {
                    onNavigateTab!(1); // Onglet Jouets
                  } else {
                    ref.read(bottomIndexProvider.notifier).setIndex(1);
                    context.go(AppRoutes.jouetscreen);
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
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    bool isFullyVerified,
    bool isAuthenticated,
  ) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          SvgPicture.asset(
            'assets/images/logo.svg',
            width: 32,
            height: 32,
            placeholderBuilder: (_) => Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.child_care_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
          AppSpacing.horizontalSm,
          Text(
            'Éveil Kid',
            style: AppTextStyles.headingSmall.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        if (isFullyVerified)
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
              size: 26,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsPage(),
                ),
              );
            },
          )
        else if (isAuthenticated)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextButton.icon(
              onPressed: () async {
                final confirmed = await AppDialogs.showConfirmDialog(
                  context: context,
                  title: 'Déconnexion',
                  message: 'Voulez-vous vous déconnecter ?',
                  confirmText: 'Se déconnecter',
                  cancelText: 'Annuler',
                  isDanger: true,
                );
                if (confirmed == true && context.mounted) {
                  final authNotifier = ref.read(authProvider.notifier);
                  ref.invalidate(parentNotifierProvider);
                  await authNotifier.logout();
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
                foregroundColor: theme.colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'Déconnexion',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextButton.icon(
              onPressed: () => context.go(AppRoutes.login),
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                foregroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text(
                'Connexion',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        AppSpacing.horizontalSm,
      ],
    );
  }

  Widget _buildConnectedHeader(BuildContext context, Utilisateur parent) {
    final theme = Theme.of(context);
    final hasChildren = parent.enfants.isNotEmpty;
    final displayName = parent.name.isNotEmpty ? parent.name : 'Parent';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasChildren ? 'Bonjour, $displayName 👋' : 'Bienvenue !',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        AppSpacing.verticalXs,
        Text(
          hasChildren
              ? 'Ravi de vous revoir parmi nous !'
              : 'Ajoutez votre enfant pour personnaliser son expérience et ses recommandations.',
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
                AppColors.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSkeleton(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeletonLoader(width: 180, height: 24, borderRadius: 8),
        AppSpacing.verticalSm,
        AppSkeletonLoader(width: 260, height: 16, borderRadius: 8),
      ],
    );
  }

  Widget _buildVisitorHeroBanner(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2E1065), const Color(0xFF1E1B4B)]
              : [const Color(0xFFF3E8FF), const Color(0xFFEDE9FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFF6B21A8).withValues(alpha: 0.5)
              : const Color(0xFFDDD6FE).withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF7C3AED))
                .withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Découvrez le monde du jeu intelligent',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                    height: 1.25,
                  ),
                ),
                AppSpacing.verticalXs,
                Text(
                  'Des jouets éducatifs et amusants pour accompagner chaque étape de développement de votre enfant.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFFE9D5FF).withValues(alpha: 0.85)
                        : const Color(0xFF4C1D95).withValues(alpha: 0.8),
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppSpacing.verticalMd,
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.register),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? theme.colorScheme.primary
                        : const Color(0xFF381272),
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Créer un compte',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -4,
                right: 8,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBCFE8).withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA7F3D0).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Positioned(
                bottom: 22,
                right: -6,
                child: Container(
                  width: 14,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBAE6FD).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              SizedBox(
                width: 105,
                height: 105,
                child: Image.asset(
                  'assets/images/teddy_bear.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surface.withValues(alpha: 0.9)
                          : AppColors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.smart_toy_rounded,
                      size: 48,
                      color: isDark
                          ? theme.colorScheme.primary
                          : const Color(0xFF381272),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryBanner(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDark
              ? theme.dividerColor.withValues(alpha: 0.25)
              : const Color(0xFFBFDBFE),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF2563EB))
                .withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Des jouets pour chaque étape de leur croissance',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color ??
                        (isDark ? Colors.white : AppColors.textPrimary),
                  ),
                ),
                AppSpacing.verticalMd,
                ElevatedButton(
                  onPressed: () {
                    if (onNavigateTab != null) {
                      onNavigateTab!(1);
                    } else {
                      ref.read(bottomIndexProvider.notifier).setIndex(1);
                      context.go(AppRoutes.jouetscreen);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
              color: isDark
                  ? theme.colorScheme.surface.withValues(alpha: 0.9)
                  : AppColors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              size: 38,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddChildBigCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.4 : 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : theme.colorScheme.primary)
                .withValues(alpha: isDark ? 0.25 : 0.04),
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
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.onPrimary,
                  size: 26,
                ),
              ),
              AppSpacing.verticalSm,
              Text(
                'Ajouter un enfant',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              AppSpacing.verticalXs,
              Text(
                'Personnalisez son catalogue et ses défis',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                      AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildrenSkeleton(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => Container(
          width: 120,
          margin: const EdgeInsets.only(right: AppSpacing.md),
          child: const AppSkeletonLoader(
            width: 120,
            height: 180,
            borderRadius: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildChildrenHorizontalList(
    BuildContext context,
    List<EnfantModel> children,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
          final isGirl = child.genre.toLowerCase() == 'fille';

          final Color avatarBg = isGirl
              ? (isDark
                  ? const Color(0xFF880E4F).withValues(alpha: 0.25)
                  : const Color(0xFFFCE4EC))
              : (isDark
                  ? const Color(0xFF0D47A1).withValues(alpha: 0.25)
                  : const Color(0xFFE3F2FD));

          final Color badgeBg = isGirl
              ? (isDark
                  ? const Color(0xFF880E4F).withValues(alpha: 0.35)
                  : const Color(0xFFFCE4EC))
              : (isDark
                  ? const Color(0xFF0D47A1).withValues(alpha: 0.35)
                  : const Color(0xFFE3F2FD));

          final Color badgeText = isGirl
              ? (isDark ? const Color(0xFFF48FB1) : const Color(0xFFD81B60))
              : (isDark ? const Color(0xFF90CAF9) : const Color(0xFF1976D2));

          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadius.card,
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.black)
                      .withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailEnfantPage(enfant: child),
                  ),
                );
              },
              borderRadius: AppRadius.card,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: avatarBg,
                      child: ClipOval(
                        child: child.avatarUrl != null &&
                                child.avatarUrl!.isNotEmpty
                            ? Image.network(
                                child.avatarUrl!,
                                fit: BoxFit.cover,
                                width: 56,
                                height: 56,
                                errorBuilder: (_, _, _) => Icon(
                                  isGirl
                                      ? Icons.face_3_rounded
                                      : Icons.face_rounded,
                                  color: badgeText,
                                  size: 34,
                                ),
                              )
                            : Icon(
                                isGirl
                                    ? Icons.face_3_rounded
                                    : Icons.face_rounded,
                                color: badgeText,
                                size: 34,
                              ),
                      ),
                    ),
                    AppSpacing.verticalSm,
                    Text(
                      child.nom,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleSmall?.color ??
                            theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${child.age} an${child.age > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.7) ??
                            AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AppSpacing.verticalXs,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: AppRadius.badge,
                      ),
                      child: Text(
                        isGirl ? 'Fille' : 'Garçon',
                        style: TextStyle(
                          color: badgeText,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddChildMiniCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
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
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, size: 24, color: theme.colorScheme.primary),
            ),
            AppSpacing.verticalSm,
            Text(
              'Ajouter\nun enfant',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8) ??
                    AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealisticCategoriesGrid(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    final defaultPalettes = [
      {
        'bgGradientLight': [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
        'bgGradientDark': [const Color(0xFF1E293B), const Color(0xFF0F172A)],
        'iconColor': const Color(0xFF2563EB),
        'borderColor': const Color(0xFFBFDBFE),
        'defaultIcon': Icons.auto_stories_rounded,
      },
      {
        'bgGradientLight': [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
        'bgGradientDark': [const Color(0xFF1E293B), const Color(0xFF0F172A)],
        'iconColor': const Color(0xFFD97706),
        'borderColor': const Color(0xFFFDE68A),
        'defaultIcon': Icons.view_in_ar_rounded,
      },
      {
        'bgGradientLight': [const Color(0xFFFAF5FF), const Color(0xFFF3E8FF)],
        'bgGradientDark': [const Color(0xFF1E293B), const Color(0xFF0F172A)],
        'iconColor': const Color(0xFF9333EA),
        'borderColor': const Color(0xFFE9D5FF),
        'defaultIcon': Icons.theater_comedy_rounded,
      },
      {
        'bgGradientLight': [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)],
        'bgGradientDark': [const Color(0xFF1E293B), const Color(0xFF0F172A)],
        'iconColor': const Color(0xFFEA580C),
        'borderColor': const Color(0xFFFED7AA),
        'defaultIcon': Icons.palette_rounded,
      },
      {
        'bgGradientLight': [const Color(0xFFFEF2F2), const Color(0xFFFEE2E2)],
        'bgGradientDark': [const Color(0xFF1E293B), const Color(0xFF0F172A)],
        'iconColor': const Color(0xFFDC2626),
        'borderColor': const Color(0xFFFECACA),
        'defaultIcon': Icons.sports_soccer_rounded,
      },
      {
        'bgGradientLight': [const Color(0xFFFDF2F8), const Color(0xFFFCE7F3)],
        'bgGradientDark': [const Color(0xFF1E293B), const Color(0xFF0F172A)],
        'iconColor': const Color(0xFFDB2777),
        'borderColor': const Color(0xFFFBCFE8),
        'defaultIcon': Icons.cruelty_free_rounded,
      },
      {
        'bgGradientLight': [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
        'bgGradientDark': [const Color(0xFF1E293B), const Color(0xFF0F172A)],
        'iconColor': const Color(0xFF0284C7),
        'borderColor': const Color(0xFFBAE6FD),
        'defaultIcon': Icons.extension_rounded,
      },
      {
        'bgGradientLight': [const Color(0xFFF0FDFA), const Color(0xFFCCFBF1)],
        'bgGradientDark': [const Color(0xFF1E293B), const Color(0xFF0F172A)],
        'iconColor': const Color(0xFF0D9488),
        'borderColor': const Color(0xFF99F6E4),
        'defaultIcon': Icons.smart_toy_rounded,
      },
      {
        'bgGradientLight': [const Color(0xFFFFFBEB), const Color(0xFFFEF08A)],
        'bgGradientDark': [const Color(0xFF1E293B), const Color(0xFF0F172A)],
        'iconColor': const Color(0xFFCA8A04),
        'borderColor': const Color(0xFFFDE047),
        'defaultIcon': Icons.music_note_rounded,
      },
    ];

    IconData getIconForCategory(String nom, IconData fallback) {
      final n = nom.toLowerCase();
      if (n.contains('éveil') || n.contains('livre') || n.contains('appr')) {
        return Icons.auto_stories_rounded;
      }
      if (n.contains('const') || n.contains('bloc') || n.contains('lego')) {
        return Icons.view_in_ar_rounded;
      }
      if (n.contains('rôle') ||
          n.contains('théâtre') ||
          n.contains('imitation')) {
        return Icons.theater_comedy_rounded;
      }
      if (n.contains('art') || n.contains('créat') || n.contains('dessin')) {
        return Icons.palette_rounded;
      }
      if (n.contains('sport') || n.contains('air') || n.contains('ballon')) {
        return Icons.sports_soccer_rounded;
      }
      if (n.contains('poup') || n.contains('peluche') || n.contains('bébé')) {
        return Icons.cruelty_free_rounded;
      }
      if (n.contains('société') || n.contains('puzzle') || n.contains('jeu')) {
        return Icons.extension_rounded;
      }
      if (n.contains('tech') || n.contains('robot') || n.contains('interact')) {
        return Icons.smart_toy_rounded;
      }
      if (n.contains('musi') || n.contains('son') || n.contains('audio')) {
        return Icons.music_note_rounded;
      }
      return fallback;
    }

    return categoriesAsync.when(
      data: (categoriesFirestore) {
        final List<Map<String, dynamic>> items;

        if (categoriesFirestore.isNotEmpty) {
          items = categoriesFirestore.asMap().entries.map((entry) {
            final idx = entry.key;
            final cat = entry.value;
            final palette = defaultPalettes[idx % defaultPalettes.length];
            final gradient = isDark
                ? (palette['bgGradientDark'] as List<Color>)
                : (palette['bgGradientLight'] as List<Color>);

            return {
              'id': cat.categorieId,
              'title': cat.nom,
              'icon': getIconForCategory(
                cat.nom,
                palette['defaultIcon'] as IconData,
              ),
              'imageUrl': cat.imageUrl,
              'bgGradient': gradient,
              'iconColor': palette['iconColor'] as Color,
              'borderColor': isDark
                  ? (palette['iconColor'] as Color).withValues(alpha: 0.25)
                  : (palette['borderColor'] as Color),
            };
          }).toList();
        } else {
          items = [
            {
              'id': '1',
              'title': 'Éveil &\nApprentissage',
              'icon': Icons.auto_stories_rounded,
              'bgGradient': isDark
                  ? (defaultPalettes[0]['bgGradientDark'] as List<Color>)
                  : (defaultPalettes[0]['bgGradientLight'] as List<Color>),
              'iconColor': defaultPalettes[0]['iconColor'] as Color,
              'borderColor': isDark
                  ? (defaultPalettes[0]['iconColor'] as Color).withValues(alpha: 0.25)
                  : (defaultPalettes[0]['borderColor'] as Color),
            },
            {
              'id': '2',
              'title': 'Construction\n& Blocs',
              'icon': Icons.view_in_ar_rounded,
              'bgGradient': isDark
                  ? (defaultPalettes[1]['bgGradientDark'] as List<Color>)
                  : (defaultPalettes[1]['bgGradientLight'] as List<Color>),
              'iconColor': defaultPalettes[1]['iconColor'] as Color,
              'borderColor': isDark
                  ? (defaultPalettes[1]['iconColor'] as Color).withValues(alpha: 0.25)
                  : (defaultPalettes[1]['borderColor'] as Color),
            },
            {
              'id': '3',
              'title': 'Jeux de Rôle\n& Imitation',
              'icon': Icons.theater_comedy_rounded,
              'bgGradient': isDark
                  ? (defaultPalettes[2]['bgGradientDark'] as List<Color>)
                  : (defaultPalettes[2]['bgGradientLight'] as List<Color>),
              'iconColor': defaultPalettes[2]['iconColor'] as Color,
              'borderColor': isDark
                  ? (defaultPalettes[2]['iconColor'] as Color).withValues(alpha: 0.25)
                  : (defaultPalettes[2]['borderColor'] as Color),
            },
            {
              'id': '4',
              'title': 'Créatif &\nArtistique',
              'icon': Icons.palette_rounded,
              'bgGradient': isDark
                  ? (defaultPalettes[3]['bgGradientDark'] as List<Color>)
                  : (defaultPalettes[3]['bgGradientLight'] as List<Color>),
              'iconColor': defaultPalettes[3]['iconColor'] as Color,
              'borderColor': isDark
                  ? (defaultPalettes[3]['iconColor'] as Color).withValues(alpha: 0.25)
                  : (defaultPalettes[3]['borderColor'] as Color),
            },
            {
              'id': '5',
              'title': 'Plein air &\nSport',
              'icon': Icons.sports_soccer_rounded,
              'bgGradient': isDark
                  ? (defaultPalettes[4]['bgGradientDark'] as List<Color>)
                  : (defaultPalettes[4]['bgGradientLight'] as List<Color>),
              'iconColor': defaultPalettes[4]['iconColor'] as Color,
              'borderColor': isDark
                  ? (defaultPalettes[4]['iconColor'] as Color).withValues(alpha: 0.25)
                  : (defaultPalettes[4]['borderColor'] as Color),
            },
            {
              'id': '6',
              'title': 'Poupées &\nPeluches',
              'icon': Icons.cruelty_free_rounded,
              'bgGradient': isDark
                  ? (defaultPalettes[5]['bgGradientDark'] as List<Color>)
                  : (defaultPalettes[5]['bgGradientLight'] as List<Color>),
              'iconColor': defaultPalettes[5]['iconColor'] as Color,
              'borderColor': isDark
                  ? (defaultPalettes[5]['iconColor'] as Color).withValues(alpha: 0.25)
                  : (defaultPalettes[5]['borderColor'] as Color),
            },
            {
              'id': '7',
              'title': 'Jeux de société\n& Puzzles',
              'icon': Icons.extension_rounded,
              'bgGradient': isDark
                  ? (defaultPalettes[6]['bgGradientDark'] as List<Color>)
                  : (defaultPalettes[6]['bgGradientLight'] as List<Color>),
              'iconColor': defaultPalettes[6]['iconColor'] as Color,
              'borderColor': isDark
                  ? (defaultPalettes[6]['iconColor'] as Color).withValues(alpha: 0.25)
                  : (defaultPalettes[6]['borderColor'] as Color),
            },
            {
              'id': '8',
              'title': 'Technologie\n& Robotique',
              'icon': Icons.smart_toy_rounded,
              'bgGradient': isDark
                  ? (defaultPalettes[7]['bgGradientDark'] as List<Color>)
                  : (defaultPalettes[7]['bgGradientLight'] as List<Color>),
              'iconColor': defaultPalettes[7]['iconColor'] as Color,
              'borderColor': isDark
                  ? (defaultPalettes[7]['iconColor'] as Color).withValues(alpha: 0.25)
                  : (defaultPalettes[7]['borderColor'] as Color),
            },
            {
              'id': '9',
              'title': 'Musique &\nÉveil Sonore',
              'icon': Icons.music_note_rounded,
              'bgGradient': isDark
                  ? (defaultPalettes[8]['bgGradientDark'] as List<Color>)
                  : (defaultPalettes[8]['bgGradientLight'] as List<Color>),
              'iconColor': defaultPalettes[8]['iconColor'] as Color,
              'borderColor': isDark
                  ? (defaultPalettes[8]['iconColor'] as Color).withValues(alpha: 0.25)
                  : (defaultPalettes[8]['borderColor'] as Color),
            },
          ];
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.90,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final cat = items[index];
            final gradientColors = cat['bgGradient'] as List<Color>;
            final iconColor = cat['iconColor'] as Color;
            final borderColor = cat['borderColor'] as Color;
            final imageUrl = cat['imageUrl'] as String?;

            return InkWell(
              onTap: () {
                ref
                    .read(selectedCategoryFilterProvider.notifier)
                    .selectCategory(cat['id'] as String?);
                ref.read(bottomIndexProvider.notifier).setIndex(1);
                context.go(AppRoutes.jouetscreen);
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : iconColor)
                          .withValues(alpha: isDark ? 0.2 : 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surface
                            : AppColors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withValues(alpha: isDark ? 0.25 : 0.18),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                imageUrl,
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  cat['icon'] as IconData,
                                  size: 28,
                                  color: iconColor,
                                ),
                              ),
                            )
                          : Icon(
                              cat['icon'] as IconData,
                              size: 28,
                              color: iconColor,
                            ),
                    ),
                    AppSpacing.verticalSm,
                    Text(
                      cat['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.92)
                            : AppColors.textPrimary,
                        height: 1.2,
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
      },
      loading: () => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.90,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const AppSkeletonLoader(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 18,
        ),
      ),
      error: (_, _) => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Erreur lors du chargement des catégories'),
        ),
      ),
    );
  }

  Widget _buildPopularToysList(BuildContext context, WidgetRef ref) {
    final jouetsAsync = ref.watch(jouetsProvider);

    return SizedBox(
      height: 215,
      child: jouetsAsync.when(
        data: (jouets) {
          final items = jouets.isNotEmpty
              ? jouets.take(6).toList()
              : [
                  Jouet(
                    jouetId: '1',
                    categorieId: 'const',
                    createurId: 'admin',
                    nom: 'Blocs de construction bois',
                    description: 'Jeu d\'éveil créatif',
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
                    description: 'Apprentissage ludique',
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
                    description: 'Technologie pour enfants',
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
            child: const AppSkeletonLoader(
              width: 175,
              height: 215,
              borderRadius: 18,
            ),
          ),
        ),
        error: (_, _) => const Center(child: Text('Erreur chargement jouets')),
      ),
    );
  }

  Widget _buildToyCard(BuildContext context, Jouet jouet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.textPrimary)
                .withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          try {
            context.push(AppRoutes.jouetdetail, extra: jouet);
          } catch (_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JouetDetailScreen(
                  jouet: jouet,
                  utilisateurId: '0FCX2CD3IlcC2tPxiOujc0b0N9v1',
                ),
              ),
            );
          }
        },
        borderRadius: AppRadius.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surfaceContainerHighest
                      : const Color(0xFFF8F7FC),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                ),
                child: Center(
                  child: jouet.images.isNotEmpty
                      ? Image.network(
                          jouet.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.smart_toy_outlined,
                            color: theme.colorScheme.primary,
                            size: 44,
                          ),
                        )
                      : Icon(
                          Icons.smart_toy_outlined,
                          color: theme.colorScheme.primary,
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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleSmall?.color ??
                          theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalXs,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${jouet.prix.toInt()} ${jouet.devise.isNotEmpty ? jouet.devise : 'CFA'}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            jouet.noteMoyenneDenormalise > 0
                                ? jouet.noteMoyenneDenormalise.toStringAsFixed(1)
                                : '4.8',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.7) ??
                                  AppColors.textSecondary,
                            ),
                          ),
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
    required BuildContext context,
    required String title,
    required String actionText,
    required VoidCallback onActionPressed,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: theme.textTheme.titleMedium?.color ??
                theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: onActionPressed,
          child: Text(
            actionText,
            style: TextStyle(
              fontSize: 13.5,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
