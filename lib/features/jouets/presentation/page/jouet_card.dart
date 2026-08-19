import 'package:flutter/material.dart';

import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/core/constants/app_colors.dart';

import 'package:eveilkid/features/jouets/models/jouet.dart';

class JouetCard extends StatelessWidget {
  final Jouet jouet;
  final VoidCallback? onTap;

  const JouetCard({
    super.key,
    required this.jouet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: AppColors.border,
            width: 0.8,
          ),
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
                  color: AppColors.surfaceVariant,
                  child: jouet.imagePrincipaleUrl.isNotEmpty
                      ? Image.network(
                          jouet.imagePrincipaleUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.disabled,
                              size: 32,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            );
                          },
                        )
                      : const Icon(
                          Icons.toys_outlined,
                          size: 40,
                          color: AppColors.disabled,
                        ),
                ),
              ),
            ),

            // INFORMATIONS
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jouet.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13, // Augmenté de 9 à 13
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '${jouet.prix.toStringAsFixed(0)} ${jouet.devise}',
                          style: const TextStyle(
                            fontSize: 13, // Augmenté de 9 à 13
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star,
                          color: AppColors.accent,
                          size: 14, // Augmenté de 11 à 14
                        ),
                        const SizedBox(width: 3),
                        Text(
                          jouet.noteMoyenneDenormalise.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12, // Augmenté de 8 à 12
                            color: AppColors.textSecondary,
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