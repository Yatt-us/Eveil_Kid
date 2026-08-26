

import 'package:eveilkid/features/activites/enums/publication_status.enum.dart';

class Activite {
  final String? id;
  final String titre;
  final String description;
  final String categorieId; 
  final String difficulte; 
  final int ageMinimum;
  final int ageMaximum;
  final int dureeEnMinutes;
  final List<String> materiels;
  final List<String> objectifsApprentissage;
  final PublicationStatus statut;
  final String? imageUrl;
  final int points;
  final DateTime dateCreation;
  final DateTime dateModification;
  final int ordreAffichage;

  const Activite({
    this.id,
    required this.titre,
    required this.description,
    required this.categorieId,
    required this.difficulte,
    required this.ageMinimum,
    required this.ageMaximum,
    required this.dureeEnMinutes,
    this.materiels = const [],
    this.objectifsApprentissage = const [],
    this.statut = PublicationStatus.brouillon,
    this.imageUrl,
    required this.points,
    required this.dateCreation,
    required this.dateModification,
    this.ordreAffichage = 0,
  });

  
  static Activite empty() {
    return Activite(
      titre: '',
      description: '',
      categorieId: '',
      difficulte: 'facile',
      ageMinimum: 3,
      ageMaximum: 6,
      dureeEnMinutes: 5,
      points: 30,
      dateCreation: DateTime.now(),
      dateModification: DateTime.now(),
    );
  }

  Activite copyWith({
    String? id,
    String? titre,
    String? description,
    String? categorieId,
    String? difficulte,
    int? ageMinimum,
    int? ageMaximum,
    int? dureeEnMinutes,
    List<String>? materiels,
    List<String>? objectifsApprentissage,
    PublicationStatus? statut,
    String? imageUrl,
    int? points,
    DateTime? dateCreation,
    DateTime? dateModification,
    int? ordreAffichage,
  }) {
    return Activite(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      categorieId: categorieId ?? this.categorieId,
      difficulte: difficulte ?? this.difficulte,
      ageMinimum: ageMinimum ?? this.ageMinimum,
      ageMaximum: ageMaximum ?? this.ageMaximum,
      dureeEnMinutes: dureeEnMinutes ?? this.dureeEnMinutes,
      materiels: materiels ?? this.materiels,
      objectifsApprentissage: objectifsApprentissage ?? this.objectifsApprentissage,
      statut: statut ?? this.statut,
      imageUrl: imageUrl ?? this.imageUrl,
      points: points ?? this.points,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      ordreAffichage: ordreAffichage ?? this.ordreAffichage,
    );
  }
}