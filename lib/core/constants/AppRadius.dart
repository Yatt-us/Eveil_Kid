import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  // ============================================================
  // VALEURS
  // ============================================================

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  /// Pour les éléments complètement arrondis.
  static const double circular = 999.0;

  // ============================================================
  // BORDER RADIUS
  // ============================================================

  static const BorderRadius xsRadius = BorderRadius.all(Radius.circular(xs));

  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));

  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));

  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));

  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));

  static const BorderRadius xxlRadius = BorderRadius.all(Radius.circular(xxl));

  static const BorderRadius xxxlRadius = BorderRadius.all(
    Radius.circular(xxxl),
  );

  static const BorderRadius circularRadius = BorderRadius.all(
    Radius.circular(circular),
  );

  // ============================================================
  // ÉLÉMENTS SPÉCIFIQUES
  // ============================================================

  /// Cartes
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));

  /// Champs de formulaire
  static const BorderRadius input = BorderRadius.all(Radius.circular(md));

  /// Boutons
  static const BorderRadius button = BorderRadius.all(Radius.circular(md));

  /// Petits boutons
  static const BorderRadius buttonSmall = BorderRadius.all(Radius.circular(sm));

  /// Dialogues
  static const BorderRadius dialog = BorderRadius.all(Radius.circular(xl));

  /// Bottom sheets
  static const BorderRadius bottomSheet = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );

  /// Images dans les cartes
  static const BorderRadius image = BorderRadius.all(Radius.circular(lg));

  /// Badges
  static const BorderRadius badge = BorderRadius.all(Radius.circular(circular));

  /// Avatar
  static const BorderRadius avatar = BorderRadius.all(
    Radius.circular(circular),
  );

  /// Éléments de l'espace enfant
  static const BorderRadius childCard = BorderRadius.all(Radius.circular(xxl));

  static const BorderRadius childButton = BorderRadius.all(
    Radius.circular(xxl),
  );
}
