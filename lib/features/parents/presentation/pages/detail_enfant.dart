// lib/features/parents/presentation/pages/detail_enfant.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_avatars.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import '../../providers/parent_provider.dart';
import '../../utils/progression_calculateur.dart';
import 'modifier_enfant.dart';

class DetailEnfantPage extends ConsumerStatefulWidget {
  final EnfantModel enfant;

  const DetailEnfantPage({super.key, required this.enfant});

  @override
  ConsumerState<DetailEnfantPage> createState() => _DetailEnfantPageState();
}

class _DetailEnfantPageState extends ConsumerState<DetailEnfantPage> {
  int _selectedTabIndex = 0; // 0: Progression, 1: Activités, 2: Résultats

  static const List<String> _childPresetAvatars = AppAvatars.childPresets;

  Future<void> _updateChildPhoto(EnfantModel enfant, String? newAvatarUrl) async {
    try {
      final updated = enfant.copyWith(avatarUrl: newAvatarUrl);
      await ref.read(parentNotifierProvider.notifier).modifierEnfant(updated);
      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: newAvatarUrl == null
              ? 'Photo de l\'enfant supprimée.'
              : 'Photo de ${enfant.nom} mise à jour !',
        );
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Erreur lors de la mise à jour: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _pickChildImage(EnfantModel enfant, ImageSource source) async {
    Navigator.pop(context);

    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 360,
        maxHeight: 360,
        imageQuality: 75,
      );

      if (pickedFile != null && mounted) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        await _updateChildPhoto(enfant, base64String);
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Impossible de charger l\'image: $e',
          isError: true,
        );
      }
    }
  }

  void _showAvatarGalleryModal(EnfantModel enfant) {
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
                  'Choisir un avatar enfant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                AppSpacing.verticalMd,
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _childPresetAvatars.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (ctx, index) {
                      final url = _childPresetAvatars[index];
                      final isSelected = enfant.avatarUrl == url;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _updateChildPhoto(enfant, url);
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

  void _showPhotoOptionsSheet(EnfantModel enfant) {
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
                  'Modifier la photo de ${enfant.nom}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                AppSpacing.verticalMd,
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.camera_alt_rounded, color: theme.colorScheme.primary),
                  ),
                  title: const Text('Prendre une photo', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => _pickChildImage(enfant, ImageSource.camera),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
                  ),
                  title: const Text('Choisir depuis la galerie', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => _pickChildImage(enfant, ImageSource.gallery),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.withValues(alpha: 0.15),
                    child: const Icon(Icons.face_retouching_natural_rounded, color: Colors.amber),
                  ),
                  title: const Text('Choisir parmi les avatars prédéfinis', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => _showAvatarGalleryModal(enfant),
                ),
                if (enfant.avatarUrl != null && enfant.avatarUrl!.isNotEmpty) ...[
                  const Divider(),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
                      child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
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
                      _updateChildPhoto(enfant, null);
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

  @override
  Widget build(BuildContext context) {
    final parentAsync = ref.watch(parentNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Obtenir la version la plus à jour de l'enfant depuis le provider si disponible
    final currentEnfant = parentAsync.maybeWhen(
      data: (parent) =>
          parent.enfants.where((e) => e.enfantId == widget.enfant.enfantId).firstOrNull ??
          widget.enfant,
      orElse: () => widget.enfant,
    );

    final niveau = ProgressionCalculateur.calculerNiveauParAge(currentEnfant.age);
    final progression = ProgressionCalculateur.extraireProgression(currentEnfant);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            tooltip: 'Modifier l\'enfant',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ModifierEnfantPage(enfant: currentEnfant),
                ),
              );
            },
          ),
          AppSpacing.horizontalSm,
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  AppSpacing.verticalSm,

                  // ── AVATAR AVEC BADGE CAMÉRA ──
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AppAvatar(
                          imageUrl: currentEnfant.avatarUrl,
                          name: currentEnfant.nom,
                          radius: 56,
                          defaultIcon: currentEnfant.genre.trim().toLowerCase() == 'fille'
                              ? Icons.face_3_rounded
                              : Icons.face_rounded,
                          onTap: () => _showPhotoOptionsSheet(currentEnfant),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showPhotoOptionsSheet(currentEnfant),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.scaffoldBackgroundColor,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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
                  ),

                  AppSpacing.verticalMd,

                  // ── NOM DE L'ENFANT ──
                  Text(
                    currentEnfant.nom,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.titleLarge?.color ??
                          theme.colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalXs,

                  // ── ÂGE ET NIVEAU ──
                  Text(
                    '${currentEnfant.age} ans   -   Niveau $niveau',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8) ??
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  AppSpacing.verticalLg,

                  // ── BARRE D'ONGLETS ──
                  _buildCustomTabBar(theme),

                  AppSpacing.verticalLg,

                  // ── CONTENU DE L'ONGLET SÉLECTIONNÉ ──
                  if (_selectedTabIndex == 0)
                    _buildProgressionTab(currentEnfant, theme, isDark, progression)
                  else if (_selectedTabIndex == 1)
                    _buildActivitesTab(currentEnfant, theme, isDark)
                  else
                    _buildResultatsTab(currentEnfant, theme, isDark),

                  AppSpacing.verticalXl,
                ],
              ),
            ),
          ),

          // ── BOUTON INFÉRIEUR "BASCULER VERS L'ESPACE ENFANT" ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  context.go(AppRoutes.espaceEnfantFor(currentEnfant.enfantId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 4,
                  shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Basculer vers l’espace enfant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem(
            theme: theme,
            index: 0,
            title: 'Progression',
            icon: Icons.trending_up_rounded,
          ),
          _buildTabItem(
            theme: theme,
            index: 1,
            title: 'Activités',
            icon: Icons.assignment_outlined,
          ),
          _buildTabItem(
            theme: theme,
            index: 2,
            title: 'Résultats',
            icon: Icons.notifications_none_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required ThemeData theme,
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedTabIndex == index;
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ??
        theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressionTab(
    EnfantModel enfant,
    ThemeData theme,
    bool isDark,
    ProgressionData progression,
  ) {
    final pourcentage = progression.pourcentageGlobal;
    final ratio = progression.ratioGlobal;
    final titre = ProgressionCalculateur.obtenirTitreAppreciation(pourcentage);
    final sousTitre = ProgressionCalculateur.obtenirSousTitreAppreciation(
      enfant.nom,
      pourcentage,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.textPrimary)
                .withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progression globale',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: theme.textTheme.titleMedium?.color ??
                  theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.verticalLg,

          // ── CERCLE DE PROGRESSION & MESSAGE ──
          Row(
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: CircularProgressIndicator(
                        value: ratio,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      '$pourcentage%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.titleMedium?.color ??
                            theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.titleMedium?.color ??
                            theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sousTitre,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
                            theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.verticalLg,
          Divider(
            color: theme.dividerColor.withValues(alpha: 0.2),
            thickness: 1.2,
          ),
          AppSpacing.verticalMd,

          // ── BARRE 1 : ACTIVITÉS COMPLÉTÉES ──
          _buildStatProgressBar(
            theme: theme,
            label: 'Activités complétées',
            score: progression.scoreActivites,
            progress: progression.ratioActivites,
            progressColor: const Color(0xFF10B981), // Vert
          ),
          AppSpacing.verticalLg,

          // ── BARRE 2 : DÉFIS RÉUSSIS ──
          _buildStatProgressBar(
            theme: theme,
            label: 'Défis réussis',
            score: progression.scoreDefis,
            progress: progression.ratioDefis,
            progressColor: const Color(0xFF3B82F6), // Bleu
          ),
          AppSpacing.verticalLg,

          // ── BARRE 3 : TEMPS D'APPRENTISSAGE ──
          _buildStatProgressBar(
            theme: theme,
            label: 'Temps d’apprentissage',
            score: progression.tempsFormate,
            progress: progression.ratioTemps,
            progressColor: const Color(0xFFF97316), // Orange
          ),
        ],
      ),
    );
  }

  Widget _buildStatProgressBar({
    required ThemeData theme,
    required String label,
    required String score,
    required double progress,
    required Color progressColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color ??
                    theme.colorScheme.onSurface,
              ),
            ),
            Text(
              score,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color ??
                    theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitesTab(EnfantModel enfant, ThemeData theme, bool isDark) {
    final activites = [
      {
        'title': 'Comptage et chiffres',
        'category': 'Mathématiques',
        'status': 'Terminé',
        'icon': Icons.calculate_outlined,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Reconnaissance des couleurs',
        'category': 'Éveil visuel',
        'status': 'En cours',
        'icon': Icons.palette_outlined,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'Les animaux de la forêt',
        'category': 'Découverte',
        'status': 'À commencer',
        'icon': Icons.pets_outlined,
        'color': const Color(0xFFF59E0B),
      },
    ];

    return Column(
      children: activites.map((act) {
        final iconColor = act['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.textPrimary)
                    .withValues(alpha: isDark ? 0.25 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  act['icon'] as IconData,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      act['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color ??
                            theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      act['category'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.7) ??
                            theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  act['status'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultatsTab(EnfantModel enfant, ThemeData theme, bool isDark) {
    final badges = [
      {
        'title': 'Petit Explorateur',
        'desc': '10 activités terminées',
        'icon': '🌟',
      },
      {
        'title': 'Génie des Puzzles',
        'desc': 'Score parfait sur 5 puzzles',
        'icon': '🧩',
      },
      {
        'title': 'Artiste en herbe',
        'desc': '3 dessins créés',
        'icon': '🎨',
      },
    ];

    return Column(
      children: badges.map((badge) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.textPrimary)
                    .withValues(alpha: isDark ? 0.25 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                badge['icon'] as String,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color ??
                            theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      badge['desc'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.7) ??
                            theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
