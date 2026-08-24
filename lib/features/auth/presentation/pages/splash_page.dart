import 'package:flutter/material.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/shared/widgets/app_logo.dart';

/// Page d'attente (Splash screen) affichée pendant l'initialisation de la session Firebase.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final titleColor = colorScheme.onSurface;
    final subtitleColor = colorScheme.onSurfaceVariant;
    final primaryColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Officiel SVG
            const AppLogo(size: 110),
            AppSpacing.verticalLg,

            // Titre de l'application
            Text(
              'Éveil Kid',
              style: AppTextStyles.headingLarge.copyWith(
                color: titleColor,
              ),
            ),
            AppSpacing.verticalXs,

            // Sous-titre
            Text(
              'Ludothèque & Éveil Pédagogique',
              style: textTheme.bodyMedium?.copyWith(
                    color: subtitleColor,
                  ) ??
                  AppTextStyles.bodyMedium.copyWith(
                    color: subtitleColor,
                  ),
            ),
            AppSpacing.verticalXxl,

            // Indicateur de chargement stylisé
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.8,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
