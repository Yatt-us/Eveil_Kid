// lib/features/parents/utils/progression_calculateur.dart

import 'package:flutter/material.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';

/// Modèle contenant les statistiques calculées de progression d'un enfant
class ProgressionData {
  final int activitesCompletees;
  final int totalActivites;
  final int defisReussis;
  final int totalDefis;
  final int tempsApprentissageMinutes;
  final int objectifTempsMinutes;
  final int etoilesGagnees;
  final int niveau;
  final double progressionNiveau;
  final int pointsPourNiveauSuivant;

  const ProgressionData({
    this.activitesCompletees = 0,
    this.totalActivites = 40,
    this.defisReussis = 0,
    this.totalDefis = 20,
    this.tempsApprentissageMinutes = 0,
    this.objectifTempsMinutes = 180, // 3 heures par défaut
    this.etoilesGagnees = 0,
    this.niveau = 1,
    this.progressionNiveau = 0.05,
    this.pointsPourNiveauSuivant = 50,
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

/// Modèle pour les badges dynamiques calculés depuis les données réelles
class BadgeProgression {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final double progress;
  final String progressLabel;
  final String? unlockedDate;

  const BadgeProgression({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    required this.progress,
    required this.progressLabel,
    this.unlockedDate,
  });
}

/// Classe utilitaire contenant les calculs de progression et appréciations
class ProgressionCalculateur {
  const ProgressionCalculateur._();

  /// Calcule le ratio global (0.0 à 1.0) équilibré entre activités et défis.
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

  /// Extrait automatiquement les données de progression réelles depuis un [EnfantModel]
  static ProgressionData extraireProgression(
    EnfantModel enfant, {
    int totalActivites = 0,
    int totalDefis = 0,
    int objectifTempsMinutes = 180,
  }) {
    final resultats = enfant.resultatsActivite;

    int activites = 0;
    int defis = 0;
    int tempsTotalMinutes = 0;

    for (final item in resultats) {
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final type = map['type']?.toString().toLowerCase() ?? '';
        final isQuiz = type.contains('defi') ||
            type.contains('challenge') ||
            map['totalQuestions'] != null;
        final estTermine = map['statut'] == 'termine' ||
            map['termine'] == true ||
            map['estTerminee'] == true ||
            map['estReussi'] == true ||
            (map['score'] != null && (map['score'] as num) > 0);

        if (estTermine) {
          activites++;
          if (isQuiz) {
            defis++;
          }
        }

        final duree = map['dureeMinutes'] ??
            map['tempsMinutes'] ??
            map['duree'] ??
            0;
        if (duree is num && duree > 0) {
          tempsTotalMinutes += duree.toInt();
        } else if (estTermine) {
          tempsTotalMinutes += 8; // estimation réaliste de 8 min par activité
        }
      } else {
        activites++;
        tempsTotalMinutes += 8;
      }
    }

    final calcTotalActivites = totalActivites > 0
        ? totalActivites
        : (activites > 0 ? (activites * 1.5).ceil() : 10);
    final calcTotalDefis = totalDefis > 0
        ? totalDefis
        : (defis > 0 ? (defis * 1.5).ceil() : 5);

    return ProgressionData(
      activitesCompletees: activites,
      totalActivites: calcTotalActivites,
      defisReussis: defis,
      totalDefis: calcTotalDefis,
      tempsApprentissageMinutes: tempsTotalMinutes,
      objectifTempsMinutes: objectifTempsMinutes,
      etoilesGagnees: enfant.totalPoints,
      niveau: enfant.niveau,
      progressionNiveau: enfant.progressionNiveau,
      pointsPourNiveauSuivant: enfant.pointsPourProchainNiveau,
    );
  }

  /// Génère dynamiquement les badges et trophées basés sur les vraies statistiques
  static List<BadgeProgression> genererBadges(EnfantModel enfant) {
    final prog = extraireProgression(enfant);
    final activites = prog.activitesCompletees;
    final defis = prog.defisReussis;
    final etoiles = enfant.totalPoints;
    final niveau = enfant.niveau;
    final souhaits = enfant.souhait.length;

    return [
      BadgeProgression(
        title: 'Premier Pas',
        description: 'Terminer une première activité d\'éveil',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFF10B981),
        isUnlocked: activites >= 1,
        progress: (activites / 1.0).clamp(0.0, 1.0),
        progressLabel: activites >= 1 ? 'Validé ⭐' : '$activites/1 activité',
        unlockedDate: activites >= 1 ? 'Débloqué' : null,
      ),
      BadgeProgression(
        title: 'Explorateur Curieux',
        description: 'Compléter 5 activités différentes',
        icon: Icons.explore_rounded,
        color: const Color(0xFF3B82F6),
        isUnlocked: activites >= 5,
        progress: (activites / 5.0).clamp(0.0, 1.0),
        progressLabel: activites >= 5 ? 'Validé ⭐' : '$activites/5 activités',
        unlockedDate: activites >= 5 ? 'Débloqué' : null,
      ),
      BadgeProgression(
        title: 'Étoile Brillante',
        description: 'Cumuler 50 étoiles dans les jeux',
        icon: Icons.star_rounded,
        color: const Color(0xFFF59E0B),
        isUnlocked: etoiles >= 50,
        progress: (etoiles / 50.0).clamp(0.0, 1.0),
        progressLabel: etoiles >= 50 ? 'Validé ⭐' : '$etoiles/50 étoiles',
        unlockedDate: etoiles >= 50 ? 'Débloqué' : null,
      ),
      BadgeProgression(
        title: 'Génie des Défis',
        description: 'Réussir avec succès 3 quiz ou défis',
        icon: Icons.psychology_rounded,
        color: const Color(0xFF8B5CF6),
        isUnlocked: defis >= 3,
        progress: (defis / 3.0).clamp(0.0, 1.0),
        progressLabel: defis >= 3 ? 'Validé ⭐' : '$defis/3 défis',
        unlockedDate: defis >= 3 ? 'Débloqué' : null,
      ),
      BadgeProgression(
        title: 'Grand Champion',
        description: 'Terminer 10 activités complètes',
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFFEC4899),
        isUnlocked: activites >= 10,
        progress: (activites / 10.0).clamp(0.0, 1.0),
        progressLabel: activites >= 10 ? 'Validé ⭐' : '$activites/10 activités',
        unlockedDate: activites >= 10 ? 'Débloqué' : null,
      ),
      BadgeProgression(
        title: 'Maître Éveilleur',
        description: 'Atteindre le Niveau 3 d\'apprentissage',
        icon: Icons.rocket_launch_rounded,
        color: const Color(0xFF06B6D4),
        isUnlocked: niveau >= 3,
        progress: (niveau / 3.0).clamp(0.0, 1.0),
        progressLabel: niveau >= 3 ? 'Validé ⭐' : 'Niveau $niveau/3',
        unlockedDate: niveau >= 3 ? 'Débloqué' : null,
      ),
      BadgeProgression(
        title: 'Boîte à Trésors',
        description: 'Ajouter un jouet coup de cœur aux souhaits',
        icon: Icons.favorite_rounded,
        color: const Color(0xFFE11D48),
        isUnlocked: souhaits >= 1,
        progress: (souhaits / 1.0).clamp(0.0, 1.0),
        progressLabel: souhaits >= 1 ? 'Validé ⭐' : '$souhaits/1 souhait',
        unlockedDate: souhaits >= 1 ? 'Débloqué' : null,
      ),
    ];
  }
}
