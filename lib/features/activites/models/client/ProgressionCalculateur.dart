class ProgressionCalculateur {
  static double calculerRatioGlobal({
    required int activitesCompletees,
    required int totalActivites,
    required int defisReussis,
    required int totalDefis,
  }) {
    if (totalActivites == 0 && totalDefis == 0) return 0.0;
    
    final ratioActivites = totalActivites > 0 ? (activitesCompletees / totalActivites) : 0.0;
    final ratioDefis = totalDefis > 0 ? (defisReussis / totalDefis) : 0.0;
    
    return ((ratioActivites + ratioDefis) / 2).clamp(0.0, 1.0);
  }

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

  static String obtenirTitreAppreciation(int pourcentage) {
    if (pourcentage >= 80) return 'Excellent !';
    if (pourcentage >= 60) return 'Très bien !';

    if (pourcentage >= 20) return 'En bonne voie !';
    return 'Encourageant !';
  }

  static String obtenirSousTitreAppreciation(String prenom, int pourcentage) {
    if (pourcentage >= 75) return '$prenom progresse très bien.';
    if (pourcentage >= 50) return '$prenom fait de bons progrès.';
    return '$prenom commence son parcours.';
  }

  static double calculerRatio(int valeur, int total) {
    if (total <= 0) return 0.0;
    return (valeur / total).clamp(0.0, 1.0);
  }

  static String formaterTemps(int totalMinutes) {
    if (totalMinutes <= 0) return '0min';
    final heures = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (heures == 0) return '${minutes}min';
    if (minutes == 0) return '${heures}h';
    return '${heures}h ${minutes}min';
  }

  static int calculerNiveau(int activitesCompletees) {
    return (activitesCompletees ~/ 10) + 1;
  }
}