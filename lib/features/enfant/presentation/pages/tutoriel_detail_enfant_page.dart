import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_button.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_card.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:eveilkid/features/tutoriels/enums/tutoriel_status.enum.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/video_player_widget.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

/// Page de détail d'un tutoriel dédiée à l'Espace Enfant :
/// - Design minimaliste & épuré (pas d'informations superflues)
/// - Aucun Floating Action Button (FAB)
/// - Thème vert/ludique du lecteur vidéo adapté à l'espace enfant
/// - Aucune incitation d'achat ou panier commercial
class TutorielDetailEnfantPage extends ConsumerWidget {
  final String tutorielId;

  const TutorielDetailEnfantPage({
    super.key,
    required this.tutorielId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final childMode = ref.watch(childModeProvider);
    final enfant = childMode.activeChild ??
        ref.watch(enfantNotifierProvider.select((state) => state.enfantSelectionne));
    final childAge = enfant?.age ?? 0;

    final tutorielAsync = ref.watch(tutorielStreamByIdProvider(tutorielId));
    final tutorielsAsync = ref.watch(tutorielsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: tutorielAsync.when(
          data: (tutoriel) {
            if (tutoriel == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.videocam_off_rounded,
                        size: 56,
                        color: KidTheme.primaryGreen,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Oups ! Tutoriel introuvable',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      DuolingoButton(
                        text: 'Retour aux tutoriels',
                        icon: Icons.arrow_back_rounded,
                        colorType: DuolingoButtonColor.green,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            }

            final relatedTutoriels = tutorielsAsync.maybeWhen(
              data: (list) => list
                  .where((item) =>
                      item.tutorielId != tutoriel.tutorielId &&
                      item.statut == TutorielStatus.publie &&
                      (childAge <= 0 || item.ageMinimum <= childAge))
                  .take(4)
                  .toList(),
              orElse: () => <Tutoriel>[],
            );

            return Column(
              children: [
                // ── APP BAR LUDIQUE & MINIMALISTE ──
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
                              Icons.keyboard_arrow_down_rounded,
                              size: 24,
                              color: KidTheme.primaryGreenDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Tutoriel',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFED7AA)),
                        ),
                        child: const Icon(
                          Icons.movie_creation_rounded,
                          size: 20,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── CONTENU VIDÉO ET INFOS MINIMALISTES ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. LECTEUR VIDÉO AU THÈME ESPACE ENFANT
                        TutorielInlineVideoPlayer(
                          tutoriel: tutoriel,
                          autoPlay: false,
                          isKidMode: true,
                        ),

                        const SizedBox(height: 18),

                        // 2. TITRE & BADGES
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF86EFAC),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '${tutoriel.ageMinimum} - ${tutoriel.ageMaximum} ans',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: KidTheme.primaryGreenDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (tutoriel.duree > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFDE68A),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  '⏱ ${tutoriel.dureeFormatted}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          tutoriel.titre,
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),

                        if (tutoriel.description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          DuolingoCard(
                            borderRadius: 22,
                            bottomThickness: 4.0,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.lightbulb_rounded,
                                      size: 18,
                                      color: Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'À propos de cette vidéo',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  tutoriel.description,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // 3. AUTRES VIDÉOS POUR L'ENFANT
                        if (relatedTutoriels.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Regarde aussi',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 130,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: relatedTutoriels.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final item = relatedTutoriels[index];
                                return _buildRelatedKidCard(
                                  context,
                                  item,
                                  theme,
                                  isDark,
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => _buildDetailSkeleton(theme, isDark),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Erreur : $err',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedKidCard(
    BuildContext context,
    Tutoriel item,
    ThemeData theme,
    bool isDark,
  ) {
    return SizedBox(
      width: 140,
      child: DuolingoCard(
        onTap: () {
          if (item.tutorielId != null && item.tutorielId!.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => KidThemeScope(
                  child: TutorielDetailEnfantPage(
                    tutorielId: item.tutorielId!,
                  ),
                ),
              ),
            );
          }
        },
        borderRadius: 18,
        bottomThickness: 3.5,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: SizedBox(
                height: 75,
                width: double.infinity,
                child: item.miniatureUrl.isNotEmpty
                    ? Image.network(
                        item.miniatureUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFFFFEDD5),
                          child: const Icon(
                            Icons.movie_rounded,
                            color: Color(0xFFEA580C),
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFFFEDD5),
                        child: const Icon(
                          Icons.movie_rounded,
                          color: Color(0xFFEA580C),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Text(
                item.titre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSkeleton(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: const AppSkeletonLoader(
              height: 220,
              borderRadius: 24,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              AppSkeletonLoader(width: 80, height: 26, borderRadius: 12),
              SizedBox(width: 8),
              AppSkeletonLoader(width: 70, height: 26, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 14),
          const AppSkeletonLoader(width: 240, height: 24, borderRadius: 8),
          const SizedBox(height: 14),
          const AppSkeletonLoader(height: 80, borderRadius: 18),
        ],
      ),
    );
  }
}
