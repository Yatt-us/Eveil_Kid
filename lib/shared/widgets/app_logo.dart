import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eveilkid/core/constants/app_assets.dart';
import 'package:eveilkid/core/constants/app_colors.dart';

/// Widget réutilisable pour afficher le logo officiel de l'application Éveil Kid.
class AppLogo extends StatelessWidget {
  /// Taille par défaut (carré)
  final double size;

  /// Largeur personnalisée (si différente de la hauteur)
  final double? width;

  /// Hauteur personnalisée (si différente de la largeur)
  final double? height;

  /// Mode d'ajustement du SVG
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size = 80,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveWidth = width ?? size;
    final double effectiveHeight = height ?? size;

    return SvgPicture.asset(
      AppAssets.logo,
      width: effectiveWidth,
      height: effectiveHeight,
      fit: fit,
      placeholderBuilder: (BuildContext context) => Container(
        width: effectiveWidth,
        height: effectiveHeight,
        alignment: Alignment.center,
        child: Icon(
          Icons.child_care_rounded,
          size: effectiveHeight * 0.6,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
