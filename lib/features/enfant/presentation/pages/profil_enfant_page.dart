import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/core/utils/parental_pin_helper.dart';
import 'package:eveilkid/features/enfant/presentation/pages/liste_souhaits_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/pages/progression_enfant_page.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';

class ProfilEnfantPages extends ConsumerWidget {
  const ProfilEnfantPages({super.key});

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
    final activitiesCount = enfant.resultatsActivite.length;
    final starsCount = (activitiesCount * 15) + 30;
    final level = (enfant.age + (activitiesCount ~/ 5)).clamp(1, 10);

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mon Profil',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Ton espace personnel',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
                    // ── HERO AVATAR & INFOS ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF14532D), const Color(0xFF064E3B)]
                              : [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isDark
                              ? theme.dividerColor.withValues(alpha: 0.25)
                              : KidTheme.primaryGreen.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.08,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
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
                            child: ClipOval(
                              child: enfant.avatarUrl != null &&
                                      enfant.avatarUrl!.isNotEmpty
                                  ? Image.network(
                                      enfant.avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _defaultAvatar(),
                                    )
                                  : _defaultAvatar(),
                            ),
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
                              color: Colors.white.withValues(alpha: 0.8),
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

                    // ── STATS GRID LUDIQUE ──
                    Row(
                      children: [
                        _buildStatBox(
                          '⭐ Étoiles',
                          '$starsCount',
                          const Color(0xFFFEF3C7),
                          const Color(0xFFD97706),
                          theme,
                          isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildStatBox(
                          '🎮 Activités',
                          '$activitiesCount',
                          const Color(0xFFF3E8FF),
                          const Color(0xFF9333EA),
                          theme,
                          isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildStatBox(
                          '💖 Souhaits',
                          '$wishesCount',
                          const Color(0xFFFCE7F3),
                          const Color(0xFFDB2777),
                          theme,
                          isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── ACTIONS RAPIDES ENFANT ──
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

                    const SizedBox(height: 10),

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

                    // ── BOUTON SORTIE CONTRÔLE PARENTAL ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => ParentalPinHelper.exitChildSpace(
                          context: context,
                          ref: ref,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurface,
                          side: BorderSide(
                            color: theme.dividerColor.withValues(
                              alpha: isDark ? 0.3 : 0.2,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.lock_outline_rounded, size: 20),
                        label: const Text(
                          'Quitter l’espace enfant 🔒',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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
    ThemeData theme,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surfaceContainerHighest : bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? theme.dividerColor.withValues(alpha: 0.2) : bg,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
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
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
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
          ),
        ),
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