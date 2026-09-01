import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/jouets_suggestion_card.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/video_player_widget.dart';
import 'package:eveilkid/features/tutoriels/providers/cloudinary_duration_provider.dart';
import 'package:eveilkid/features/tutoriels/utils/duration_utils.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';

/// Page de lecture vidéo immersive pour les tutoriels
class VideoPlayerPage extends ConsumerWidget {
  final Tutoriel tutoriel;

  const VideoPlayerPage({
    super.key,
    required this.tutoriel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryName = categoriesAsync.maybeWhen(
      data: (categories) {
        for (final cat in categories) {
          if (cat.categorieId == tutoriel.categorieId) return cat.nom;
        }
        return null;
      },
      orElse: () => null,
    );

    final toyIds = <String>{
      if (tutoriel.jouetLieId != null && tutoriel.jouetLieId!.isNotEmpty)
        tutoriel.jouetLieId!,
      ...tutoriel.jouetsSuggeres.where((id) => id.isNotEmpty),
    }.toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          tutoriel.titre,
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: theme.textTheme.titleMedium?.color ??
                theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lecteur universel
              TutorielInlineVideoPlayer(
                tutoriel: tutoriel,
                autoPlay: true,
              ),
              const SizedBox(height: 18),

              // Titre & Métadonnées
              Text(
                tutoriel.titre,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.titleMedium?.color ??
                      theme.colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.play_circle_outline_rounded,
                    size: 14,
                    color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.65) ??
                        theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      [
                        if (categoryName != null && categoryName.isNotEmpty)
                          categoryName,
                        tutoriel.ageRangeLabel,
                        if (tutoriel.duree > 0)
                          tutoriel.dureeFormatted
                        else
                          ref.watch(cloudinaryVideoDurationProvider(tutoriel.videoUrl)).when(
                            data: (secs) => secs > 0 ? formatDurationSeconds(secs) : null,
                            loading: () => null,
                            error: (_, _) => null,
                          ),
                      ].join(' • '),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.65) ??
                            theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              if (tutoriel.description.isNotEmpty) ...[
                AppCard(
                  title: 'Description',
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    tutoriel.description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.8) ??
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Matériel & Jouets recommandés
              if (toyIds.isNotEmpty) ...[
                Text(
                  'Matériel & Jouets recommandés',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.titleMedium?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                ...toyIds.map(
                  (toyId) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: JouetSuggestionCard(jouetId: toyId),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}