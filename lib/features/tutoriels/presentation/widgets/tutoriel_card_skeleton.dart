import 'package:flutter/material.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

/// Skeleton réaliste et élégant pour les cartes tutoriels (Espace Parent / Général)
class TutorielCardSkeleton extends StatelessWidget {
  final bool isHorizontal;

  const TutorielCardSkeleton({
    super.key,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.15);

    if (isHorizontal) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dividerColor, width: 1),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const AppSkeletonLoader(
              width: 120,
              height: 80,
              borderRadius: 12,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppSkeletonLoader(height: 14, width: 80, borderRadius: 6),
                  const SizedBox(height: 8),
                  const AppSkeletonLoader(height: 16, width: double.infinity, borderRadius: 6),
                  const SizedBox(height: 6),
                  AppSkeletonLoader(
                    height: 12,
                    width: 100,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dividerColor, width: 1),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aperçu vidéo 16/9 avec placeholder de bouton Play
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const AppSkeletonLoader(
                    height: double.infinity,
                    width: double.infinity,
                    borderRadius: 0,
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black38 : Colors.white60,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      width: 44,
                      height: 18,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black45 : Colors.black26,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Détails textuels
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Catégorie + Âge
                Row(
                  children: [
                    const AppSkeletonLoader(width: 70, height: 16, borderRadius: 6),
                    const SizedBox(width: 8),
                    const AppSkeletonLoader(width: 50, height: 16, borderRadius: 6),
                  ],
                ),
                const SizedBox(height: 10),

                // Titre
                const AppSkeletonLoader(width: double.infinity, height: 18, borderRadius: 6),
                const SizedBox(height: 6),
                const AppSkeletonLoader(width: 180, height: 18, borderRadius: 6),
                const SizedBox(height: 12),

                // Description
                const AppSkeletonLoader(width: double.infinity, height: 13, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton pour les cartes de tutoriel dans l'Espace Enfant
class KidTutorialCardSkeleton extends StatelessWidget {
  const KidTutorialCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Miniature avec bouton play au centre
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const AppSkeletonLoader(
                    height: 150,
                    width: double.infinity,
                    borderRadius: 0,
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black38 : Colors.white70,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Informations
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    AppSkeletonLoader(width: 80, height: 22, borderRadius: 12),
                    SizedBox(width: 8),
                    AppSkeletonLoader(width: 65, height: 22, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 12),
                const AppSkeletonLoader(width: 220, height: 20, borderRadius: 8),
                const SizedBox(height: 8),
                const AppSkeletonLoader(width: double.infinity, height: 14, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
