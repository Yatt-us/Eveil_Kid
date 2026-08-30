import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/providers/cloudinary_duration_provider.dart';
import 'package:eveilkid/features/tutoriels/utils/duration_utils.dart';

/// Carte vidéo moderne, épurée et sans badge parasite,
/// mettant en valeur l'aperçu vidéo et les informations essentielles.
class TutorielCard extends ConsumerWidget {
  final Tutoriel tutoriel;
  final VoidCallback? onTap;
  final String? categoryName;
  final bool isHorizontal;

  const TutorielCard({
    super.key,
    required this.tutoriel,
    this.onTap,
    this.categoryName,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.15);
    final titleColor = theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65) ??
        theme.colorScheme.onSurfaceVariant;
    final durationSecs = tutoriel.duree > 0
        ? tutoriel.duree.toDouble()
        : (ref
                .watch(cloudinaryVideoDurationProvider(tutoriel.videoUrl))
                .asData
                ?.value ??
            0.0);

    final imageUrl = tutoriel.miniatureUrl.isNotEmpty
        ? tutoriel.miniatureUrl
        : 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=900&q=80';

    final metaInfo = [
      if (categoryName != null && categoryName!.isNotEmpty) categoryName!,
      tutoriel.ageRangeLabel,
    ].join(' • ');

    if (isHorizontal) {
      // Format horizontal épuré
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.card,
          border: Border.all(color: dividerColor, width: 1),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.card,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 120,
                      height: 80,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildPlaceholder(context),
                          ),
                          _buildPlayOverlay(context, isCompact: true),
                          if (durationSecs > 0)
                            Positioned(
                              right: 6,
                              bottom: 6,
                              child: _buildDurationBadge(formatDurationSeconds(durationSecs)),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tutoriel.titre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                            height: 1.25,
                          ),
                        ),
                        if (metaInfo.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            metaInfo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Format Standard Full Card (Flux vidéo propre et cinématique)
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dividerColor, width: 1),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aperçu vidéo grand format
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildPlaceholder(context),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                      ),
                      // Gradient subtil pour la lisibilité
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.45),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Bouton Play central
                      _buildPlayOverlay(context),
                      // Badge durée vidéo
                      if (durationSecs > 0)
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: _buildDurationBadge(formatDurationSeconds(durationSecs)),
                        ),
                    ],
                  ),
                ),
              ),

              // Détails textuels propres et aérés (sans badge parasite)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutoriel.titre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 14,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            metaInfo.isNotEmpty ? metaInfo : 'Guide vidéo',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayOverlay(BuildContext context, {bool isCompact = false}) {
    final theme = Theme.of(context);
    final size = isCompact ? 32.0 : 48.0;
    final iconSize = isCompact ? 18.0 : 28.0;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildDurationBadge(String duration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        duration,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.play_circle_fill_rounded,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
