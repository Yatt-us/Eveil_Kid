// lib/features/parent/presentation/pages/profil_parent.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/parent_provider.dart';
import 'liste_enfants.dart';
import 'modifier_profil.dart';
import 'notification_settings_page.dart';
import 'parametres_page.dart';

class ProfilParentPage extends ConsumerWidget {
  const ProfilParentPage({super.key});

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
      Navigator.of(context).popUntil((route) => route.isFirst);
      await ref.read(authProvider.notifier).logout();
      ref.invalidate(parentNotifierProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;

    // Si non connecté (mode visiteur)
    if (!isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Mon Profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 54,
                    color: AppColors.primary,
                  ),
                ),
                AppSpacing.verticalLg,
                const Text(
                  'Connexion requise',
                  style: AppTextStyles.headingMedium,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalSm,
                Text(
                  'Connectez-vous pour accéder à votre espace parent, gérer vos enfants et vos favoris.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalXl,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text(
                      'Se connecter',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final parentAsync = ref.watch(parentNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Pas de menu hamburger
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
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
        data: (parent) => SingleChildScrollView(
          padding: AppPadding.screen,
          child: Column(
            children: [
              AppSpacing.verticalSm,

              // --- AVATAR DU PARENT AVEC BADGE CAMÉRA ---
              Center(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceVariant,
                            border: Border.all(
                              color: AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child:
                                parent.photoUrl != null &&
                                    parent.photoUrl!.isNotEmpty
                                ? Image.network(
                                    parent.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person_rounded,
                                      size: 55,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    size: 55,
                                    color: AppColors.primary,
                                  ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ModifierProfilPage(parent: parent),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalMd,
                    Text(
                      parent.name.isNotEmpty
                          ? parent.name
                          : (authState.utilisateur?.nom.isNotEmpty == true
                                ? authState.utilisateur!.nom
                                : 'Aminata DIARRA'),
                      style: AppTextStyles.headingMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.verticalXs,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Compte Parent',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalXl,

              // --- CARTE DU MENU PRINCIPAL ---
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.edit_outlined,
                      title: 'Modifier mon profil',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ModifierProfilPage(parent: parent),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _buildMenuItem(
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
                    const Divider(height: 1, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.favorite_border_rounded,
                      title: 'Mes favoris',
                      onTap: () {
                        AppDialogs.showSnackBar(
                          context: context,
                          message:
                              '${parent.nombreFavoris} favori(s) enregistré(s).',
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.shopping_cart_outlined,
                      title: 'Mes commandes',
                      onTap: () {
                        AppDialogs.showSnackBar(
                          context: context,
                          message:
                              'Vos commandes et réservations d\'emprunt seront affichées ici.',
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationSettingsPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _buildMenuItem(
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
                    const Divider(height: 1, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Aide et support',
                      onTap: () {
                        AppDialogs.showSnackBar(
                          context: context,
                          message: 'Support client : support@eveilkid.com',
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.info_outline_rounded,
                      title: 'À propos',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Éveil Kid',
                          applicationVersion: '1.0.0',
                          applicationLegalese:
                              '© 2026 Éveil Kid. Tous droits réservés.',
                        );
                      },
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalXl,

              // --- BOUTON SE DÉCONNECTER (OU SE CONNECTER SI VISITEUR) ---
              if (isAuthenticated) ...[
                InkWell(
                  onTap: () => _logout(context, ref),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: AppColors.danger,
                          size: 24,
                        ),
                        AppSpacing.horizontalMd,
                        Text(
                          'Se déconnecter',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                InkWell(
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.login_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        AppSpacing.horizontalMd,
                        Text(
                          'Se connecter / S\'inscrire',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              AppSpacing.verticalXxl,
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            AppSpacing.horizontalMd,
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.icon, size: 22),
          ],
        ),
      ),
    );
  }
}
