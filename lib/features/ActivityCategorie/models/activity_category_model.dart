
class ActiviteCategorie {
  final String? id;
  final String nom;
  final String description;
  final String? icon;
  final String? couleur;
  final int ordreAffichage;
  final bool estActive;
  final DateTime? dateCreation;
  final DateTime? dateModification;

  const ActiviteCategorie({
    this.id,
    required this.nom,
    required this.description,
    this.icon,
    this.couleur,
    this.ordreAffichage = 0,
    this.estActive = true,
    required this.dateCreation,
    required this.dateModification,
  });

  // Créer une catégorie vide
  static ActiviteCategorie empty() {
    return ActiviteCategorie(
      nom: '',
      description: '',
      dateCreation: DateTime.now(),
      dateModification: DateTime.now(),
    );
  }

  ActiviteCategorie copyWith({
    String? id,
    String? nom,
    String? description,
    String? icon,
    String? couleur,
    int? ordreAffichage,
    bool? estActive,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return ActiviteCategorie(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      couleur: couleur ?? this.couleur,
      ordreAffichage: ordreAffichage ?? this.ordreAffichage,
      estActive: estActive ?? this.estActive,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }
}