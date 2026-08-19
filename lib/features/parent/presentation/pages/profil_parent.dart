// lib/features/parent/presentation/pages/profil_parent.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../providers/parent_provider.dart';
import 'liste_enfants.dart';
import 'modifier_profil.dart';

class ProfilParentPage extends ConsumerWidget {
  const ProfilParentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentAsync = ref.watch(parentNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary, size: 28),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary, size: 28),
            onPressed: () {},
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
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.surfaceVariant,
                          child: const Icon(Icons.person, size: 60, color: AppColors.primary),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
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
                      ],
                    ),
                    AppSpacing.verticalMd,
                    Text(
                      parent.name.isNotEmpty ? parent.name : 'Awa Diarra',
                      style: AppTextStyles.headingMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    AppSpacing.verticalXs,
                    Text(
                      'Parent',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
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
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.edit_outlined,
                      title: 'Modifier mon profil',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ModifierProfilPage(parent: parent)),
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
                          MaterialPageRoute(builder: (_) => const ListeEnfantsPage()),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.favorite_border_rounded,
                      title: 'Mes favoris',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.shopping_cart_outlined,
                      title: 'Mes commandes',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Paramètres',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Aide et support',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.info_outline_rounded,
                      title: 'À propos',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalXl,

              // --- BOUTON SE DÉCONNECTER ---
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Déconnexion effectuée.')),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded, color: AppColors.danger, size: 24),
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
              AppSpacing.verticalXxl,
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
