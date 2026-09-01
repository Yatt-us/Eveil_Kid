// lib/features/parents/utils/progression_calculateur.dart

import 'package:eveilkid/features/enfant/model/enfant_model.dart';

/// Modèle contenant les statistiques calculées de progression d'un enfant
class ProgressionData {
  final int activitesCompletees;
  final int totalActivites;
  final int defisReussis;
  final int totalDefis;
  final int tempsApprentissageMinutes;
  final int objectifTempsMinutes;

  const ProgressionData({
    this.activitesCompletees = 0,
    this.totalActivites = 40,
    this.defisReussis = 0,
    this.totalDefis = 20,
    this.tempsApprentissageMinutes = 0,
    this.objectifTempsMinutes = 300, // 5 heures par défaut
  });

  /// Ratio global de 0.0 à 1.0
  double get ratioGlobal => ProgressionCalculateur.calculerRatioGlobal(
        activitesCompletees: activitesCompletees,
        totalActivites: totalActivites,
        defisReussis: defisReussis,
        totalDefis: totalDefis,
      );

  /// Pourcentage global de 0 à 100 %
  int get pourcentageGlobal => ProgressionCalculateur.calculerPourcentageGlobal(
        activitesCompletees: activitesCompletees,
        totalActivites: totalActivites,
        defisReussis: defisReussis,
        totalDefis: totalDefis,
      );

  /// Ratio d'activités (0.0 à 1.0)
  double get ratioActivites =>
      ProgressionCalculateur.calculerRatio(activitesCompletees, totalActivites);

  /// Ratio de défis réussis (0.0 à 1.0)
  double get ratioDefis =>
      ProgressionCalculateur.calculerRatio(defisReussis, totalDefis);

  /// Ratio de temps passé par rapport à l'objectif (0.0 à 1.0)
  double get ratioTemps => ProgressionCalculateur.calculerRatioTemps(
        tempsApprentissageMinutes,
        objectifTempsMinutes,
      );

  /// Chaîne formatée du score d'activités (ex: "28/40")
  String get scoreActivites => '$activitesCompletees/$totalActivites';

  /// Chaîne formatée du score de défis (ex: "12/20")
  String get scoreDefis => '$defisReussis/$totalDefis';

  /// Chaîne formatée du temps d'apprentissage (ex: "3h 45min")
  String get tempsFormate =>
      ProgressionCalculateur.formaterTemps(tempsApprentissageMinutes);
}

/// Classe utilitaire contenant les calculs de progression et appréciations
class ProgressionCalculateur {
  const ProgressionCalculateur._();

  /// Calcule le ratio global (0.0 à 1.0) équilibré entre activités et défis.
  /// Si une seule catégorie a un total > 0, elle est prise à 100%.
  static double calculerRatioGlobal({
    required int activitesCompletees,
    required int totalActivites,
    required int defisReussis,
    required int totalDefis,
  }) {
    int categoriesValides = 0;
    double sommeRatios = 0.0;

    if (totalActivites > 0) {
      sommeRatios += (activitesCompletees / totalActivites).clamp(0.0, 1.0);
      categoriesValides++;
    }

    if (totalDefis > 0) {
      sommeRatios += (defisReussis / totalDefis).clamp(0.0, 1.0);
      categoriesValides++;
    }

    if (categoriesValides == 0) return 0.0;
    return (sommeRatios / categoriesValides).clamp(0.0, 1.0);
  }

  /// Calcule le pourcentage global arrondi (0 à 100)
  static int calculerPourcentageGlobal({
    required int activitesCompletees,
    required int totalActivites,
    required int defisReussis,
    required int totalDefis,
  }) {
    final ratio = calculerRatioGlobal(
      activitesCompletees: activitesCompletees,
      totalActivites: totalActivites,
      defisReussis: defisReussis,
      totalDefis: totalDefis,
    );
    return (ratio * 100).round();
  }

  /// Retourne un titre d'appréciation basé sur le pourcentage global
  static String obtenirTitreAppreciation(int pourcentage) {
    if (pourcentage >= 80) return 'Excellent !';
    if (pourcentage >= 60) return 'Très bien !';
    if (pourcentage >= 40) return 'Bon travail !';
    if (pourcentage >= 20) return 'En bonne voie !';
    return 'Encourageant !';
  }

  /// Retourne un message personnalisé avec le prénom de l'enfant
  static String obtenirSousTitreAppreciation(String prenom, int pourcentage) {
    final nomAffiche = prenom.trim().isEmpty ? 'L\'enfant' : prenom;
    if (pourcentage >= 80) return '$nomAffiche progresse à pas de géant !';
    if (pourcentage >= 60) return '$nomAffiche progresse très bien.';
    if (pourcentage >= 40) return '$nomAffiche fait de bons progrès.';
    if (pourcentage >= 20) return '$nomAffiche est sur la bonne voie.';
    return '$nomAffiche commence son parcours.';
  }

  /// Calcule le ratio simple pour une barre de progression
  static double calculerRatio(int valeur, int total) {
    if (total <= 0) return 0.0;
    return (valeur / total).clamp(0.0, 1.0);
  }

  /// Calcule le ratio du temps passé par rapport à l'objectif
  static double calculerRatioTemps(int minutesPassees, int objectifMinutes) {
    if (objectifMinutes <= 0) return 0.0;
    return (minutesPassees / objectifMinutes).clamp(0.0, 1.0);
  }

  /// Formate une durée en minutes vers une chaîne lisible (ex: "3h 45min", "45min", "2h", "0min")
  static String formaterTemps(int totalMinutes) {
    if (totalMinutes <= 0) return '0min';
    final heures = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (heures == 0) return '${minutes}min';
    if (minutes == 0) return '${heures}h';
    return '${heures}h ${minutes}min';
  }

  /// Calcule le niveau selon le nombre d'activités complétées (1 niveau tous les 10)
  static int calculerNiveauParActivites(int activitesCompletees) {
    return (activitesCompletees ~/ 10) + 1;
  }

  /// Calcule le niveau selon l'âge de l'enfant (utilisé dans Eveil_Kid)
  static int calculerNiveauParAge(int age) {
    if (age <= 3) return 1;
    if (age <= 5) return 2;
    if (age <= 7) return 3;
    if (age <= 9) return 4;
    return 5;
  }

  /// Extrait automatiquement les données de progression depuis un [EnfantModel]
  static ProgressionData extraireProgression(
    EnfantModel enfant, {
    int totalActivites = 40,
    int totalDefis = 20,
    int objectifTempsMinutes = 300,
  }) {
    final resultats = enfant.resultatsActivite;

    int activites = 0;
    int defis = 0;
    int tempsTotalMinutes = 0;

    for (final item in resultats) {
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final type = map['type']?.toString().toLowerCase() ?? '';
        final estTermine = map['statut'] == 'termine' ||
            map['estTermine'] == true ||
            map['score'] != null;

        if (estTermine) {
          if (type.contains('defi') || type.contains('challenge')) {
            defis++;
          } else {
            activites++;
          }
        }

        final duree = map['dureeMinutes'] ??
            map['tempsMinutes'] ??
            map['duree'] ??
            0;
        if (duree is num) {
          tempsTotalMinutes += duree.toInt();
        }
      } else {
        activites++;
      }
    }

    return ProgressionData(
      activitesCompletees: activites,
      totalActivites: totalActivites,
      defisReussis: defis,
      totalDefis: totalDefis,
      tempsApprentissageMinutes: tempsTotalMinutes,
      objectifTempsMinutes: objectifTempsMinutes,
    );
  }
}
