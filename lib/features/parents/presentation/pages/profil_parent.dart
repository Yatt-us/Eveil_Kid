// lib/features/parents/presentation/pages/profil_parent.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_avatars.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/email_verification_banner.dart';
import '../../../auth/models/utilisateur.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/parent_provider.dart';
import 'liste_enfants.dart';
import 'modifier_profil.dart';
import 'notification_settings_page.dart';
import 'parametre_page.dart';
import '../../../commandes/presentation/pages/mes_commandes_page.dart';

import '../../../../core/provider/bottom_nav_bar_provider.dart';

class ProfilParentPage extends ConsumerWidget {
  const ProfilParentPage({super.key});

  static const List<String> _presetAvatars = AppAvatars.parentPresets;

  Future<void> _updatePhoto(
    BuildContext context,
    WidgetRef ref,
    Utilisateur parent,
    String? newPhotoUrl,
  ) async {
    try {
      final updated = parent.copyWith(photoUrl: newPhotoUrl);
      await ref
          .read(parentNotifierProvider.notifier)
          .updateParentProfile(updated);
      ref.read(authProvider.notifier).updateLocalUtilisateur(updated);
      if (context.mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: newPhotoUrl == null
              ? 'Photo de profil supprimée.'
              : 'Photo de profil mise à jour !',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Erreur lors de la mise à jour: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    Utilisateur parent,
    ImageSource source,
  ) async {
    Navigator.pop(context);

    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 360,
        maxHeight: 360,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        if (context.mounted) {
          await _updatePhoto(context, ref, parent, base64String);
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Impossible de charger l\'image: $e',
          isError: true,
        );
      }
    }
  }

  void _showAvatarGalleryModal(
    BuildContext context,
    WidgetRef ref,
    Utilisateur parent,
  ) {
    Navigator.pop(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                AppSpacing.verticalMd,
                Text(
                  'Choisir un avatar prédéfini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        theme.textTheme.titleMedium?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                AppSpacing.verticalMd,
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetAvatars.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (ctx, index) {
                      final url = _presetAvatars[index];
                      final isSelected = parent.photoUrl == url;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _updatePhoto(context, ref, parent, url);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 34,
                            backgroundImage: NetworkImage(url),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                AppSpacing.verticalMd,
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPhotoOptionsSheet(
    BuildContext context,
    WidgetRef ref,
    Utilisateur parent,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                AppSpacing.verticalMd,
                Text(
                  'Modifier la photo de profil',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color:
                        theme.textTheme.titleMedium?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                AppSpacing.verticalMd,
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: const Text(
                    'Prendre une photo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => _pickImage(ctx, ref, parent, ImageSource.camera),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  title: const Text(
                    'Choisir depuis la galerie',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () =>
                      _pickImage(ctx, ref, parent, ImageSource.gallery),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.face_retouching_natural_rounded,
                      color: Colors.amber,
                    ),
                  ),
                  title: const Text(
                    'Choisir parmi les avatars prédéfinis',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => _showAvatarGalleryModal(ctx, ref, parent),
                ),
                if (parent.photoUrl != null && parent.photoUrl!.isNotEmpty) ...[
                  const Divider(),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.error.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    title: Text(
                      'Supprimer la photo actuelle',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _updatePhoto(context, ref, parent, null);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Déconnexion',
      message: 'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?',
      confirmText: 'Se déconnecter',
      cancelText: 'Annuler',
      isDanger: true,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
      ref.invalidate(parentNotifierProvider);
      if (context.mounted) {
        ref.read(bottomIndexProvider.notifier).setIndex(0);
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final isEmailVerified = authState.isEmailVerified;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 1. Si non connecté (mode visiteur)
    if (!isAuthenticated) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            ref.read(bottomIndexProvider.notifier).setIndex(0);
            context.go(AppRoutes.home);
          }
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Mon Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    theme.textTheme.titleMedium?.color ??
                    theme.colorScheme.onSurface,
              ),
            ),
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding: AppPadding.screenLarge,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 54,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  AppSpacing.verticalLg,
                  Text(
                    'Connexion requise',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          theme.textTheme.titleLarge?.color ??
                          theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.verticalSm,
                  Text(
                    'Connectez-vous pour accéder à votre espace, gérer vos enfants et vos favoris.',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.7,
                          ) ??
                          AppColors.textSecondary,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.verticalXl,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go(AppRoutes.login),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.button,
                        ),
                      ),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text(
                        'Se connecter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const AppBottomNavBar(),
        ),
      );
    }

    // 2. Si connecté mais email NON vérifié
    if (!isEmailVerified) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            ref.read(bottomIndexProvider.notifier).setIndex(0);
            context.go(AppRoutes.home);
          }
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Mon Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    theme.textTheme.titleMedium?.color ??
                    theme.colorScheme.onSurface,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.logout_rounded,
                  color: theme.colorScheme.error,
                ),
                tooltip: 'Se déconnecter',
                onPressed: () => _logout(context, ref),
              ),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: AppPadding.screen,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const EmailVerificationBanner(),
                  AppSpacing.verticalXl,
                  OutlinedButton.icon(
                    onPressed: () => _logout(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text(
                      'Se déconnecter',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const AppBottomNavBar(),
        ),
      );
    }

    final parentAsync = ref.watch(parentNotifierProvider);
    final userFromAuth = authState.utilisateur;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ref.read(bottomIndexProvider.notifier).setIndex(0);
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'Mon Profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  theme.textTheme.titleMedium?.color ??
                  theme.colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
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
            ),
            AppSpacing.horizontalSm,
          ],
        ),
        body: parentAsync.when(
          data: (parent) {
            final effectiveRole = parent.role != UserRole.parent
                ? parent.role
                : (userFromAuth?.role ?? UserRole.parent);

            final isAdminOrManager =
                effectiveRole == UserRole.admin ||
                effectiveRole == UserRole.manager;

            final displayName = parent.name.isNotEmpty
                ? parent.name
                : (userFromAuth?.nom.isNotEmpty == true
                      ? userFromAuth!.nom
                      : 'Utilisateur');

            final displayEmail = parent.email.isNotEmpty
                ? parent.email
                : (userFromAuth?.email ?? '');

            return SingleChildScrollView(
              padding: AppPadding.screen,
              child: Column(
                children: [
                  AppSpacing.verticalSm,

                  // --- AVATAR DU PROFIL AVEC BADGE ---
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AppAvatar(
                              imageUrl: parent.photoUrl,
                              name: displayName,
                              radius: 50,
                              onTap: () =>
                                  _showPhotoOptionsSheet(context, ref, parent),
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: GestureDetector(
                                onTap: () => _showPhotoOptionsSheet(
                                  context,
                                  ref,
                                  parent,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.scaffoldBackgroundColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 16,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.verticalMd,
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color:
                                theme.textTheme.titleMedium?.color ??
                                theme.colorScheme.onSurface,
                          ),
                        ),
                        if (displayEmail.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            displayEmail,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  theme.textTheme.bodySmall?.color?.withValues(
                                    alpha: 0.7,
                                  ) ??
                                  AppColors.textSecondary,
                            ),
                          ),
                        ],
                        if (parent.adresse != null &&
                            parent.adresse!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  parent.adresse!.trim(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        theme.textTheme.bodySmall?.color
                                            ?.withValues(alpha: 0.75) ??
                                        AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        AppSpacing.verticalSm,
                        _buildRoleBadge(context, effectiveRole),
                      ],
                    ),
                  ),
                  AppSpacing.verticalXl,

                  // --- BANNIÈRE D'ACCÈS RAPIDE ESPACE ADMIN SI ADMIN/MANAGER ---
                  if (isAdminOrManager) ...[
                    _buildAdminBanner(context, effectiveRole),
                    AppSpacing.verticalLg,
                  ],

                  // --- CARTE DU MENU PRINCIPAL ---
                  Container(
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
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context: context,
                          icon: Icons.edit_outlined,
                          title: 'Modifier mon profil',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ModifierProfilPage(parent: parent),
                              ),
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          color: theme.dividerColor.withValues(alpha: 0.2),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.child_care_outlined,
                          title: 'Mes enfants',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ListeEnfantsPage(),
                              ),
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          color: theme.dividerColor.withValues(alpha: 0.2),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.favorite_border_rounded,
                          title: 'Mes favoris',
                          onTap: () {
                            context.push(AppRoutes.favoris);
                          },
                        ),
                        Divider(
                          height: 1,
                          color: theme.dividerColor.withValues(alpha: 0.2),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.shopping_cart_outlined,
                          title: 'Mes commandes',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MesCommandesPage(
                                  parentId: parent.utilisateurId,
                                ),
                              ),
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          color: theme.dividerColor.withValues(alpha: 0.2),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.settings_outlined,
                          title: 'Paramètres',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ParametresPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.verticalXl,

                  // --- BOUTON SE DÉCONNECTER ---
                  InkWell(
                    onTap: () => _logout(context, ref),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: theme.colorScheme.error,
                            size: 22,
                          ),
                          AppSpacing.horizontalSm,
                          Text(
                            'Se déconnecter',
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.verticalXxl,
                ],
              ),
            );
          },
          loading: () => Center(
            child: SingleChildScrollView(
              padding: AppPadding.screen,
              child: Column(
                children: [
                  const AppSkeletonLoader(
                    width: 100,
                    height: 100,
                    borderRadius: 50,
                  ),
                  AppSpacing.verticalMd,
                  const AppSkeletonLoader(
                    width: 160,
                    height: 20,
                    borderRadius: 6,
                  ),
                  AppSpacing.verticalSm,
                  const AppSkeletonLoader(
                    width: 100,
                    height: 24,
                    borderRadius: 12,
                  ),
                  AppSpacing.verticalXl,
                  const AppSkeletonLoader(
                    width: double.infinity,
                    height: 380,
                    borderRadius: 18,
                  ),
                ],
              ),
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Erreur de chargement: $err',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        bottomNavigationBar: const AppBottomNavBar(),
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context, UserRole role) {
    final theme = Theme.of(context);

    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (role) {
      case UserRole.admin:
        bg = const Color(0xFFEF4444).withValues(alpha: 0.15);
        fg = const Color(0xFFEF4444);
        label = 'Administrateur';
        icon = Icons.security_rounded;
        break;
      case UserRole.manager:
        bg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
        fg = const Color(0xFFD97706);
        label = 'Manager';
        icon = Icons.business_center_rounded;
        break;
      case UserRole.parent:
        bg = theme.colorScheme.primary.withValues(alpha: 0.1);
        fg = theme.colorScheme.primary;
        label = 'Compte Parent';
        icon = Icons.family_restroom_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminBanner(BuildContext context, UserRole role) {
    final isRoleAdmin = role == UserRole.admin;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRoleAdmin
              ? [const Color(0xFF4338CA), const Color(0xFF312E81)]
              : [const Color(0xFFD97706), const Color(0xFFB45309)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color:
                (isRoleAdmin
                        ? const Color(0xFF4338CA)
                        : const Color(0xFFD97706))
                    .withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isRoleAdmin
                      ? Icons.admin_panel_settings_rounded
                      : Icons.business_center_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRoleAdmin
                          ? 'Espace Administration'
                          : 'Espace Gestion Manager',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Gestion du catalogue, catégories et commandes',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalMd,
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.admin),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: isRoleAdmin
                  ? const Color(0xFF312E81)
                  : const Color(0xFFB45309),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(double.infinity, 42),
              elevation: 0,
            ),
            icon: const Icon(Icons.dashboard_rounded, size: 18),
            label: const Text(
              'Ouvrir le Tableau de Bord Admin',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            AppSpacing.horizontalMd,
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color:
                      theme.textTheme.bodyLarge?.color ??
                      theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color:
                  theme.iconTheme.color?.withValues(alpha: 0.5) ??
                  AppColors.icon,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
