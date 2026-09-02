import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_card.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';

class ProgressionEnfantPage extends ConsumerWidget {
  const ProgressionEnfantPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final childMode = ref.watch(childModeProvider);
    final enfant = childMode.activeChild ??
        ref.watch(
          enfantNotifierProvider.select((state) => state.enfantSelectionne),
        );

    final completedCount = enfant?.totalActivitesTerminees ?? 0;
    final starsCount = enfant?.totalPoints ?? 0;
    final level = enfant?.niveau ?? 1;
    final progressToNextLevel = enfant?.progressionNiveau ?? 0.05;
    final pointsForNext = enfant?.pointsPourProchainNiveau ?? 50;

    final badges = [
      {
        'title': 'Premier Pas',
        'desc': 'Première activité complétée !',
        'icon': Icons.stars_rounded,
        'unlocked': completedCount >= 1,
        'color': const Color(0xFFFEF3C7),
      },
      {
        'title': 'Ami des Jeux',
        'desc': '3 activités réussies',
        'icon': Icons.sports_esports_rounded,
        'unlocked': completedCount >= 3,
        'color': const Color(0xFFFFEDD5),
      },
      {
        'title': 'Chasseur d’Étoiles',
        'desc': 'Récolter 30 étoiles',
        'icon': Icons.auto_awesome_rounded,
        'unlocked': starsCount >= 30,
        'color': const Color(0xFFE0F2FE),
      },
      {
        'title': 'Artiste Étoilé',
        'desc': '5 activités complétées',
        'icon': Icons.palette_rounded,
        'unlocked': completedCount >= 5,
        'color': const Color(0xFFF3E8FF),
      },
      {
        'title': 'Pilote de l’Espace',
        'desc': 'Atteindre le niveau 5',
        'icon': Icons.rocket_launch_rounded,
        'unlocked': level >= 5 || starsCount >= 200,
        'color': const Color(0xFFDCFCE7),
      },
      {
        'title': 'Super Champion',
        'desc': '10 activités terminées',
        'icon': Icons.workspace_premium_rounded,
        'unlocked': completedCount >= 10 || starsCount >= 500,
        'color': const Color(0xFFFCE7F3),
      },
    ];

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
                      'Progression',
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
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      size: 22,
                      color: KidTheme.primaryGreenDark,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── CARTE HERO NIVEAU & ÉTOILES STYLE DUOLINGO 3D ──
                    DuolingoCard(
                      borderRadius: 28,
                      bottomThickness: 4.5,
                      padding: const EdgeInsets.all(18),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Text(
                                      '🚀',
                                      style: TextStyle(fontSize: 28),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Niveau $level',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF14532D),
                                        ),
                                      ),
                                      Text(
                                        'Grand Explorateur',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? const Color(0xFF86EFAC)
                                              : const Color(0xFF166534),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 18,
                                      color: Color(0xFFD97706),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$starsCount',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Vers le Niveau ${level + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF166534),
                                ),
                              ),
                              Text(
                                '${(progressToNextLevel * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF14532D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progressToNextLevel,
                              minHeight: 8,
                              backgroundColor: Colors.white.withValues(alpha: 0.5),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                KidTheme.primaryGreenDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── GALERIE DE TROPHÉES & BADGES STYLE DUOLINGO 3D ──
                    Text(
                      'Mes Badges & Trophées',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 14),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: badges.length,
                      itemBuilder: (context, index) {
                        final b = badges[index];
                        final isUnlocked = b['unlocked'] as bool;
                        final color = b['color'] as Color;

                        return DuolingoCard(
                          borderRadius: 22,
                          bottomThickness: 4.0,
                          backgroundColor: isUnlocked
                              ? (isDark ? theme.colorScheme.surfaceContainerHighest : color)
                              : (isDark ? const Color(0xFF1E1E24) : const Color(0xFFF1F5F9)),
                          borderColor: isUnlocked
                              ? (isDark
                                  ? KidTheme.primaryGreenLight.withValues(alpha: 0.3)
                                  : KidTheme.primaryGreen.withValues(alpha: 0.35))
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          bottomBorderColor: isUnlocked
                              ? (isDark ? const Color(0xFF14532D) : KidTheme.primaryGreenDark)
                              : (isDark ? const Color(0xFF18181C) : const Color(0xFF94A3B8)),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Opacity(
                                opacity: isUnlocked ? 1.0 : 0.35,
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      b['icon'] as IconData,
                                      size: 28,
                                      color: isUnlocked
                                          ? KidTheme.primaryGreenDark
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                b['title'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: isUnlocked
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isUnlocked
                                    ? (b['desc'] as String)
                                    : '🔒 À débloquer',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isUnlocked
                                      ? theme.colorScheme.onSurfaceVariant
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── CARTE D'ENCOURAGEMENT ──
                    DuolingoCard(
                      borderRadius: 24,
                      bottomThickness: 4.0,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 34)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tu es sur la bonne voie !',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Continue tes activités pour débloquer le badge "Pilote de l’Espace" !',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
}
