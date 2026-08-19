import 'package:flutter/material.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/shared/widgets/app_logo.dart';

/// Page d'attente (Splash screen) affichée pendant l'initialisation de la session Firebase.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Officiel SVG
            const AppLogo(size: 110),
            AppSpacing.verticalLg,

            // Titre de l'application
            const Text(
              'Éveil Kid',
              style: AppTextStyles.headingLarge,
            ),
            AppSpacing.verticalXs,

            // Sous-titre
            Text(
              'Ludothèque & Éveil Pédagogique',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.verticalXxl,

            // Indicateur de chargement stylisé
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.8,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
