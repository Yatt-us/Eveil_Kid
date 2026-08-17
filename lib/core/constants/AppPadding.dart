import 'package:flutter/material.dart';

class AppPadding {
  AppPadding._();

  // ============================================================
  // VALEURS DE BASE
  // ============================================================

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;

  // ============================================================
  // PADDING HORIZONTAL
  // ============================================================

  /// Très petit espacement horizontal
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);

  /// Petit espacement horizontal
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);

  /// Espacement horizontal moyen
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);

  /// Espacement horizontal standard
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  /// Grand espacement horizontal
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  /// Très grand espacement horizontal
  static const EdgeInsets horizontalXxl = EdgeInsets.symmetric(horizontal: xxl);

  // ============================================================
  // PADDING VERTICAL
  // ============================================================

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);

  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);

  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);

  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);

  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);

  static const EdgeInsets verticalXxl = EdgeInsets.symmetric(vertical: xxl);

  // ============================================================
  // PADDING COMPLET
  // ============================================================

  static const EdgeInsets allXs = EdgeInsets.all(xs);

  static const EdgeInsets allSm = EdgeInsets.all(sm);

  static const EdgeInsets allMd = EdgeInsets.all(md);

  static const EdgeInsets allLg = EdgeInsets.all(lg);

  static const EdgeInsets allXl = EdgeInsets.all(xl);

  static const EdgeInsets allXxl = EdgeInsets.all(xxl);

  static const EdgeInsets allXxxl = EdgeInsets.all(xxxl);

  // ============================================================
  // PADDING POUR LES ÉCRANS
  // ============================================================

  /// Padding horizontal principal des pages mobiles
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 16.0);

  /// Padding plus large pour les pages importantes
  static const EdgeInsets screenLarge = EdgeInsets.symmetric(horizontal: 24.0);

  // ============================================================
  // PADDING DES CARTES
  // ============================================================

  /// Padding standard d'une carte
  static const EdgeInsets card = EdgeInsets.all(16.0);

  /// Padding compact d'une petite carte
  static const EdgeInsets cardSmall = EdgeInsets.all(12.0);

  /// Padding d'une grande carte
  static const EdgeInsets cardLarge = EdgeInsets.all(20.0);

  // ============================================================
  // PADDING DES CHAMPS DE FORMULAIRE
  // ============================================================

  static const EdgeInsets input = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 14.0,
  );

  // ============================================================
  // PADDING DES BOUTONS
  // ============================================================

  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 14.0,
  );

  static const EdgeInsets buttonSmall = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 10.0,
  );

  static const EdgeInsets buttonLarge = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 16.0,
  );

  // ============================================================
  // PADDING DES DIALOGUES
  // ============================================================

  static const EdgeInsets dialog = EdgeInsets.all(24.0);

  // ============================================================
  // PADDING DES LISTES
  // ============================================================

  static const EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
}
