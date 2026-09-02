import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/ActivityCategorie/providers/activity_category_provider.dart';
import 'package:eveilkid/features/activites/enums/publication_status.enum.dart';
import 'package:eveilkid/features/activites/models/activity.dart';

class ActivityCard extends ConsumerWidget {
  final Activite activity;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPublish;
  final VoidCallback onUnpublish;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onPublish,
    required this.onUnpublish,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesMapAsync = ref.watch(categoriesMapProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12);

    final statusBgColor = _getStatusBgColor(activity.statut, isDark);
    final statusTextColor = _getStatusTextColor(activity.statut, isDark);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Image Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 76,
                    height: 76,
                    color: isDark
                        ? theme.colorScheme.surfaceContainerHighest
                        : AppColors.primary.withValues(alpha: 0.08),
                    child: activity.imageUrl != null && activity.imageUrl!.isNotEmpty
                        ? Image.network(
                            activity.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildPlaceholder(theme),
                            loadingBuilder: (_, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.primary,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          )
                        : _buildPlaceholder(theme),
                  ),
                ),

                const SizedBox(width: 12),

                // 2. Infos principales
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre & Menu Actions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              activity.titre,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          _buildActionsMenu(context, theme),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Catégorie & Âge
                      categoriesMapAsync.when(
                        loading: () => const SizedBox(
                          height: 14,
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                        error: (_, _) => Text(
                          'Non catégorisé',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        data: (categoriesMap) {
                          final categoryName = _getCategoryName(
                            activity.categorieId,
                            categoriesMap,
                          );
                          return Row(
                            children: [
                              Flexible(
                                child: Text(
                                  categoryName,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 3.5,
                                height: 3.5,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${activity.ageMinimum}-${activity.ageMaximum} ans',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // Badges de statut, points et durée (Responsive Wrap)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Statut pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              activity.statut.label,
                              style: TextStyle(
                                color: statusTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          // Points pill
                          if (activity.points > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF78350F).withValues(alpha: 0.5)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 13,
                                    color: Color(0xFFD97706),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${activity.points} pts',
                                    style: const TextStyle(
                                      color: Color(0xFFD97706),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Durée
                          if (activity.dureeEnMinutes > 0)
                            Text(
                              '⏱ ${activity.dureeEnMinutes} min',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context, ThemeData theme) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'publish':
            onPublish();
            break;
          case 'unpublish':
            onUnpublish();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              const Text('Modifier'),
            ],
          ),
        ),
        if (activity.statut == PublicationStatus.brouillon)
          const PopupMenuItem(
            value: 'publish',
            child: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 18, color: Color(0xFF16A34A)),
                SizedBox(width: 10),
                Text('Publier'),
              ],
            ),
          ),
        if (activity.statut == PublicationStatus.publie)
          const PopupMenuItem(
            value: 'unpublish',
            child: Row(
              children: [
                Icon(Icons.pause_circle_outline_rounded, size: 18, color: Color(0xFFD97706)),
                SizedBox(width: 10),
                Text('Passer en brouillon'),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: theme.colorScheme.error),
              const SizedBox(width: 10),
              Text(
                'Supprimer',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.extension_rounded,
        color: theme.colorScheme.primary.withValues(alpha: 0.35),
        size: 32,
      ),
    );
  }

  Color _getStatusBgColor(PublicationStatus status, bool isDark) {
    switch (status) {
      case PublicationStatus.publie:
        return isDark
            ? const Color(0xFF14532D).withValues(alpha: 0.5)
            : const Color(0xFFDCFCE7);
      case PublicationStatus.brouillon:
        return isDark
            ? const Color(0xFF78350F).withValues(alpha: 0.5)
            : const Color(0xFFFEF3C7);
      case PublicationStatus.archive:
        return isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.5)
            : const Color(0xFFFEE2E2);
    }
  }

  Color _getStatusTextColor(PublicationStatus status, bool isDark) {
    switch (status) {
      case PublicationStatus.publie:
        return isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);
      case PublicationStatus.brouillon:
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
      case PublicationStatus.archive:
        return isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
    }
  }

  String _getCategoryName(String categoryId, Map<String, String> categoriesMap) {
    return categoriesMap[categoryId] ?? 'Non catégorisé';
  }
}