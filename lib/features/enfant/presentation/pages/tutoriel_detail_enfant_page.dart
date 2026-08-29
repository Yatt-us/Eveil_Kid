import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/tutoriels/enums/tutoriel_status.enum.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/video_player_widget.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';

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
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Retour aux tutoriels'),
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
                      item.statut == TutorielStatus.publie)
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
                          'Tutoriel Vidéo 📺',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: KidTheme.primaryGreenDark,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+15 ⭐',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: KidTheme.primaryGreenDark,
                              ),
                            ),
                          ],
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

                        // 2. TITRE & BADGES SIMPLES
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
                              ),
                              child: Text(
                                '${tutoriel.ageMinimum} - ${tutoriel.ageMaximum} ans',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
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
                                ),
                                child: Text(
                                  '⏱ ${tutoriel.dureeFormatted}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 10),

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
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.dividerColor.withValues(
                                  alpha: isDark ? 0.25 : 0.15,
                                ),
                              ),
                            ),
                            child: Text(
                              tutoriel.description,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],

                        // 3. AUTRES VIDÉOS POUR L'ENFANT
                        if (relatedTutoriels.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Regarde aussi 🎬',
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
          loading: () => const Center(
            child: CircularProgressIndicator(color: KidTheme.primaryGreen),
          ),
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
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => KidThemeScope(
              child: TutorielDetailEnfantPage(
                tutorielId: item.tutorielId ?? '',
              ),
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Container(
                height: 75,
                width: 160,
                color: const Color(0xFFFFEDD5),
                child: item.miniatureUrl.isNotEmpty
                    ? Image.network(
                        item.miniatureUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.play_circle_fill_rounded,
                          size: 32,
                          color: Color(0xFFEA580C),
                        ),
                      )
                    : const Icon(
                        Icons.play_circle_fill_rounded,
                        size: 32,
                        color: Color(0xFFEA580C),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                item.titre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
