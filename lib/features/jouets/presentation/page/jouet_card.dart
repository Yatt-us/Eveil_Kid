import 'package:flutter/material.dart';
import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';

class JouetCard extends StatelessWidget {
  final Jouet jouet;
  final VoidCallback? onTap;

  const JouetCard({super.key, required this.jouet, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.15 : 0.1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: isDark
                        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    child: jouet.imagePrincipaleUrl.isNotEmpty
                        ? Image.network(
                            jouet.imagePrincipaleUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported_outlined,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                                size: 32,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            },
                          )
                        : Icon(
                            Icons.toys_outlined,
                            size: 44,
                            color: theme.colorScheme.primary.withValues(alpha: 0.35),
                          ),
                  ),
                ),
              ),

              // INFORMATIONS
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        jouet.nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ) ??
                        TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${jouet.prix.toStringAsFixed(0)} ${jouet.devise.isNotEmpty ? jouet.devise : 'CFA'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.accent,
                                size: 15,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                jouet.noteMoyenneDenormalise > 0
                                    ? jouet.noteMoyenneDenormalise.toStringAsFixed(1)
                                    : '4.8',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ) ??
                                TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
