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

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.textPrimary).withValues(
                alpha: isDark ? 0.25 : 0.03,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
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
                      ? theme.colorScheme.surfaceContainerHighest
                      : const Color(0xFFF8F7FC),
                  child: jouet.imagePrincipaleUrl.isNotEmpty
                      ? Image.network(
                          jouet.imagePrincipaleUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported_outlined,
                              color: Color.fromARGB(255, 206, 198, 232),
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
                          size: 48,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.4,
                          ),
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
                  children: [
                    Text(
                      jouet.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            theme.textTheme.titleSmall?.color ??
                            theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '${jouet.prix.toStringAsFixed(0)} ${jouet.devise.isNotEmpty ? jouet.devise : 'CFA'}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.accent,
                          size: 15,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          jouet.noteMoyenneDenormalise > 0
                              ? jouet.noteMoyenneDenormalise.toStringAsFixed(1)
                              : '4.8',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                theme.textTheme.bodySmall?.color?.withValues(
                                  alpha: 0.7,
                                ) ??
                                AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}
