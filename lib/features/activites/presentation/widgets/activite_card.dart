import 'package:flutter/material.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../core/constants/app_colors.dart';
import '../../enums/activite_enums.dart';
import '../../models/activite.dart';

/// Carte représentant une activité dans la liste avec jauge de progression.
class ActiviteCard extends StatelessWidget {
  final Activite activite;
  final VoidCallback onTap;

  const ActiviteCard({
    super.key,
    required this.activite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final estTerminee = activite.estTerminee;
    final totalQ = activite.totalQuestions > 0 ? activite.totalQuestions : activite.questions.length;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Vignette thématique
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _getCouleurFondCategorie(activite.categorie),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: activite.cheminImage.isNotEmpty
                    ? Image.asset(
                        activite.cheminImage,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => _buildPlaceholderIcon(),
                      )
                    : _buildPlaceholderIcon(),
              ),
            ),
            AppSpacing.horizontalMd,

            // Titre, Catégorie & Questions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activite.titre,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getBadgeColor(activite.categorie).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          activite.categorie.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getBadgeColor(activite.categorie),
                          ),
                        ),
                      ),
                      AppSpacing.horizontalSm,
                      Text(
                        '$totalQ questions',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Indicateur d'avancement (Check vert ou Cercle de progression)
            if (estTerminee) ...[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00A859),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Terminée',
                    style: TextStyle(
                      color: Color(0xFF00A859),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              )
            ] else ...[
              SizedBox(
                width: 54,
                height: 54,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        value: activite.progression,
                        backgroundColor: const Color(0xFFEBEBEB),
                        color: AppColors.primary,
                        strokeWidth: 4.5,
                      ),
                    ),
                    Text(
                      '${(activite.progression * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    IconData icon;
    Color color;

    switch (activite.categorie) {
      case CategorieActivite.math:
        icon = Icons.calculate_rounded;
        color = AppColors.primary;
        break;
      case CategorieActivite.lecture:
        icon = Icons.menu_book_rounded;
        color = AppColors.secondary;
        break;
      case CategorieActivite.sciences:
        icon = Icons.biotech_rounded;
        color = AppColors.teal;
        break;
      case CategorieActivite.art:
        icon = Icons.palette_rounded;
        color = AppColors.accent;
        break;
      case CategorieActivite.musique:
        icon = Icons.music_note_rounded;
        color = Colors.purple;
        break;
      default:
        icon = Icons.psychology_rounded;
        color = AppColors.primary;
    }

    return Center(
      child: Icon(icon, color: color, size: 34),
    );
  }

  Color _getCouleurFondCategorie(CategorieActivite categorie) {
    switch (categorie) {
      case CategorieActivite.sciences:
        return const Color(0xFFE8F8F5);
      case CategorieActivite.math:
        return const Color(0xFFFFF3E0);
      case CategorieActivite.lecture:
        return const Color(0xFFFFECEC);
      case CategorieActivite.art:
        return const Color(0xFFFFF7EA);
      case CategorieActivite.musique:
        return const Color(0xFFF3E5F5);
      default:
        return const Color(0xFFEBF3FF);
    }
  }

  Color _getBadgeColor(CategorieActivite categorie) {
    switch (categorie) {
      case CategorieActivite.sciences:
        return AppColors.teal;
      case CategorieActivite.math:
        return Colors.orange.shade800;
      case CategorieActivite.lecture:
        return AppColors.danger;
      case CategorieActivite.art:
        return AppColors.accent;
      case CategorieActivite.musique:
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }
}
