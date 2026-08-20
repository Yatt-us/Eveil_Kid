/// Énumérations utilisées pour le module d'activités ludo-éducatives.
library;

enum CategorieActivite {
  math('Mathématiques'),
  lecture('Lecture & Français'),
  logique('Logique & Énigmes'),
  sciences('Sciences & Nature'),
  langues('Langues & Vocabulaire'),
  cognitif('Développement Cognitif'),
  art('Art & Créativité'),
  musique('Éveil Musical');

  final String label;
  const CategorieActivite(this.label);

  static CategorieActivite fromString(String? value) {
    if (value == null) return CategorieActivite.logique;
    final normalized = value.toLowerCase().trim();
    return CategorieActivite.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized || e.label.toLowerCase() == normalized,
      orElse: () => CategorieActivite.logique,
    );
  }
}

enum DifficulteActivite {
  facile('Facile'),
  moyen('Moyen'),
  difficile('Difficile');

  final String label;
  const DifficulteActivite(this.label);

  static DifficulteActivite fromString(String? value) {
    if (value == null) return DifficulteActivite.facile;
    final normalized = value.toLowerCase().trim();
    if (normalized == 'beginner') return DifficulteActivite.facile;
    if (normalized == 'intermediate') return DifficulteActivite.moyen;
    if (normalized == 'advanced') return DifficulteActivite.difficile;
    return DifficulteActivite.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized || e.label.toLowerCase() == normalized,
      orElse: () => DifficulteActivite.facile,
    );
  }
}

enum StatutActivite {
  toutes('Toutes'),
  enCours('En cours'),
  terminees('Terminées');

  final String label;
  const StatutActivite(this.label);

  static StatutActivite fromString(String? value) {
    if (value == null) return StatutActivite.enCours;
    final normalized = value.toLowerCase().trim();
    return StatutActivite.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => StatutActivite.enCours,
    );
  }
}

enum StatutPublication {
  draft('Brouillon'),
  published('Publié'),
  archived('Archivé');

  final String label;
  const StatutPublication(this.label);

  static StatutPublication fromString(String? value) {
    if (value == null) return StatutPublication.published;
    final normalized = value.toLowerCase().trim();
    return StatutPublication.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => StatutPublication.published,
    );
  }
}

enum TypeAffichageQuestion {
  liste,
  grille;

  static TypeAffichageQuestion fromString(String? value) {
    if (value == null) return TypeAffichageQuestion.liste;
    final normalized = value.toLowerCase().trim();
    return TypeAffichageQuestion.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => TypeAffichageQuestion.liste,
    );
  }
}

enum TypeQuestion {
  choixMultiple,
  vraiFaux;

  static TypeQuestion fromString(String? value) {
    if (value == null) return TypeQuestion.choixMultiple;
    final normalized = value.toLowerCase().trim();
    if (normalized == 'choix_multiple') return TypeQuestion.choixMultiple;
    if (normalized == 'vrai_faux') return TypeQuestion.vraiFaux;
    return TypeQuestion.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => TypeQuestion.choixMultiple,
    );
  }
}
