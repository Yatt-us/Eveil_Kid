import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eveilkid/core/constants/app_avatars.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/core/utils/parental_pin_helper.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/presentation/pages/liste_souhaits_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/pages/progression_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_button.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_card.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:eveilkid/shared/widgets/app_avatar.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';

class ProfilEnfantPages extends ConsumerWidget {
  const ProfilEnfantPages({super.key});

  static const List<String> _presetAvatars = AppAvatars.childPresets;

  Future<void> _updatePhoto(
    BuildContext context,
    WidgetRef ref,
    EnfantModel enfant,
    String? newPhotoUrl,
  ) async {
    try {
      final parentId = enfant.utilisateurId;
      if (parentId.isEmpty) return;

      await ref.read(enfantNotifierProvider.notifier).mettreAJourPhoto(
            parentId: parentId,
            enfantId: enfant.enfantId,
            photoUrl: newPhotoUrl ?? '',
          );
      
      // Mettre à jour également dans le childModeProvider si c'est l'enfant actif
      final childMode = ref.read(childModeProvider);
      if (childMode.activeChildId == enfant.enfantId) {
        await ref.read(childModeProvider.notifier).enterChildMode(
          childId: enfant.enfantId,
          child: enfant.copyWith(avatarUrl: newPhotoUrl),
        );
      }

      if (context.mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: newPhotoUrl == null || newPhotoUrl.isEmpty
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
    BuildContext pageContext,
    BuildContext menuContext,
    WidgetRef ref,
    EnfantModel enfant,
    ImageSource source,
  ) async {
    Navigator.pop(menuContext);

    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 360,
        maxHeight: 360,
        imageQuality: 75,
      );

      if (pickedFile != null && pageContext.mounted) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        await _updatePhoto(pageContext, ref, enfant, base64String);
      }
    } catch (e) {
      if (pageContext.mounted) {
        AppDialogs.showSnackBar(
          context: pageContext,
          message: 'Impossible de charger l\'image: $e',
          isError: true,
        );
      }
    }
  }

  void _showAvatarGalleryModal(
    BuildContext pageContext,
    BuildContext menuContext,
    WidgetRef ref,
    EnfantModel enfant,
  ) {
    Navigator.pop(menuContext);
    final theme = Theme.of(pageContext);

    showModalBottomSheet(
      context: pageContext,
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
                    color: theme.textTheme.titleMedium?.color ??
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
                      final isSelected = enfant.avatarUrl == url;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _updatePhoto(pageContext, ref, enfant, url);
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
    EnfantModel enfant,
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
                  onTap: () => _pickImage(context, ctx, ref, enfant, ImageSource.camera),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
                  ),
                  title: const Text('Choisir depuis la galerie', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => _pickImage(context, ctx, ref, enfant, ImageSource.gallery),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.withValues(alpha: 0.15),
                    child: const Icon(Icons.face_retouching_natural_rounded, color: Colors.amber),
                  ),
                  title: const Text('Choisir parmi les avatars prédéfinis', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => _showAvatarGalleryModal(context, ctx, ref, enfant),
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
                      _updatePhoto(context, ref, enfant, null);
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final childMode = ref.watch(childModeProvider);
    final enfant = childMode.activeChild ??
        ref.watch(
          enfantNotifierProvider.select((state) => state.enfantSelectionne),
        );

    if (enfant == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: Text('Aucun enfant sélectionné')),
      );
    }

    final wishesCount =
        enfant.souhait.where((s) => !s.contains(' ') && s.isNotEmpty).length;
    final activitiesCount = enfant.totalActivitesTerminees;
    final starsCount = enfant.totalPoints;
    final level = enfant.niveau;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── APP BAR LUDIQUE ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Material(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    elevation: isDark ? 0 : 1,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: theme.dividerColor.withValues(
                              alpha: isDark ? 0.3 : 0.15,
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: KidTheme.primaryGreenDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: const Icon(
                      Icons.face_rounded,
                      size: 22,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                child: Column(
                  children: [
                    // ── HERO AVATAR & INFOS 3D DUOLINGO ──
                    DuolingoCard(
                      borderRadius: 28,
                      bottomThickness: 4.5,
                      padding: const EdgeInsets.all(22),
                      gradientColors: isDark
                          ? [const Color(0xFF14532D), const Color(0xFF064E3B)]
                          : [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)],
                      borderColor: isDark
                          ? const Color(0xFF22C55E).withValues(alpha: 0.4)
                          : KidTheme.primaryGreen.withValues(alpha: 0.4),
                      bottomBorderColor: isDark
                          ? const Color(0xFF064E3B)
                          : KidTheme.primaryGreenDark,
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 95,
                                height: 95,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: KidTheme.primaryGreen,
                                    width: 3.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: AppAvatar(
                                  imageUrl: enfant.avatarUrl,
                                  name: enfant.nom,
                                  radius: 45,
                                  onTap: () => _showPhotoOptionsSheet(context, ref, enfant),
                                ),
                              ),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: GestureDetector(
                                  onTap: () => _showPhotoOptionsSheet(context, ref, enfant),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: KidTheme.primaryGreen,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            enfant.nom,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF14532D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${enfant.age} ans • Niveau $level 🚀',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: KidTheme.primaryGreenDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── STATS GRID LUDIQUE 3D ──
                    Row(
                      children: [
                        _buildStatBox(
                          '⭐ Étoiles',
                          '$starsCount',
                          const Color(0xFFFEF3C7),
                          const Color(0xFFD97706),
                          const Color(0xFFB45309),
                          theme,
                          isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildStatBox(
                          '🎮 Activités',
                          '$activitiesCount',
                          const Color(0xFFF3E8FF),
                          const Color(0xFF9333EA),
                          const Color(0xFF7E22CE),
                          theme,
                          isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildStatBox(
                          '💖 Souhaits',
                          '$wishesCount',
                          const Color(0xFFFCE7F3),
                          const Color(0xFFDB2777),
                          const Color(0xFFBE185D),
                          theme,
                          isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── ACTIONS RAPIDES ENFANT 3D DUOLINGO ──
                    _buildMenuCard(
                      icon: Icons.stars_rounded,
                      iconColor: const Color(0xFFD97706),
                      title: 'Ma Progression & Trophées',
                      subtitle: 'Voir mes badges débloqués',
                      theme: theme,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KidThemeScope(
                              child: ProgressionEnfantPage(),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildMenuCard(
                      icon: Icons.favorite_rounded,
                      iconColor: const Color(0xFFDB2777),
                      title: 'Ma Liste de Souhaits',
                      subtitle: '$wishesCount jouets enregistrés',
                      theme: theme,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KidThemeScope(
                              child: ListeSouhaitsEnfantPage(),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── BOUTON SORTIE CONTRÔLE PARENTAL 3D ──
                    DuolingoButton(
                      text: 'Quitter l’espace enfant 🔒',
                      icon: Icons.lock_outline_rounded,
                      colorType: DuolingoButtonColor.neutral,
                      isFullWidth: true,
                      onPressed: () => ParentalPinHelper.exitChildSpace(
                        context: context,
                        ref: ref,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    Color bg,
    Color textColor,
    Color bottomBorderColor,
    ThemeData theme,
    bool isDark,
  ) {
    return Expanded(
      child: DuolingoCard(
        borderRadius: 20,
        bottomThickness: 3.5,
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: isDark ? theme.colorScheme.surfaceContainerHighest : bg,
        borderColor: isDark ? theme.dividerColor.withValues(alpha: 0.2) : bg,
        bottomBorderColor: isDark ? const Color(0xFF1E293B) : bottomBorderColor.withValues(alpha: 0.5),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? theme.colorScheme.onSurface : textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required ThemeData theme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return DuolingoCard(
      onTap: onTap,
      borderRadius: 22,
      bottomThickness: 4.0,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return const Center(
      child: Icon(
        Icons.face_rounded,
        size: 52,
        color: KidTheme.primaryGreenDark,
      ),
    );
  }
}