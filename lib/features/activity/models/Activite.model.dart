import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/activity/enums/ActivityCategory.enum.dart';
import 'package:eveilkid/features/activity/enums/DifficultyLevel.enum.dart';
import 'package:eveilkid/features/activity/enums/PublicationStatus.enum.dart';



class Activite {
  final String? id;
  final String titre;
  final String description;
  final ActivityCategory categorie;
  final DifficultyLevel difficulte;
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

  Activite({
    this.id,
    required this.titre,
    required this.description,
    required this.categorie,
    required this.difficulte,
    required this.ageMinimum,
    required this.ageMaximum,
    required this.dureeEnMinutes,
    this.materiels = const [],
    this.objectifsApprentissage = const [],
    this.statut = PublicationStatus.draft,
    this.imageUrl,
    required this.points,
    required this.dateCreation,
    required this.dateModification,
    this.ordreAffichage = 0,
  });

 
  factory Activite.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Activite(
      id: doc.id,
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      categorie: _getCategorieFromString(data['categorie']),
      difficulte: _getDifficulteFromString(data['difficulte']),
      ageMinimum: data['ageMinimum'] ?? 4,
      ageMaximum: data['ageMaximum'] ?? 12,
      dureeEnMinutes: data['dureeEnMinutes'] ?? 30,
      materiels: List<String>.from(data['materiels'] ?? []),
      objectifsApprentissage: List<String>.from(data['objectifsApprentissage'] ?? []),
      statut: _getStatutFromString(data['statut']),
      imageUrl: data['imageUrl'],
      points: data['points'] ?? 0,
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      dateModification: (data['dateModification'] as Timestamp).toDate(),
      ordreAffichage: data['ordreAffichage'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titre': titre,
      'description': description,
      'categorie': categorie.toString().split('.').last,
      'difficulte': difficulte.toString().split('.').last,
      'ageMinimum': ageMinimum,
      'ageMaximum': ageMaximum,
      'dureeEnMinutes': dureeEnMinutes,
      'materiels': materiels,
      'objectifsApprentissage': objectifsApprentissage,
      'statut': statut.toString().split('.').last,
      'imageUrl': imageUrl,
      'points': points,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
      'ordreAffichage': ordreAffichage,
    };
  }

  
  static ActivityCategory _getCategorieFromString(String value) {
    switch (value) {
      case 'cognitif': return ActivityCategory.cognitif;
      case 'language': return ActivityCategory.language;
      case 'math': return ActivityCategory.math;
      case 'science': return ActivityCategory.science;
      case 'art': return ActivityCategory.art;
      case 'music': return ActivityCategory.music;
      default: return ActivityCategory.logic;
    }
  }

  static DifficultyLevel _getDifficulteFromString(String value) {
    switch (value) {
      case 'beginner': return DifficultyLevel.beginner;
      case 'intermediate': return DifficultyLevel.intermediate;
      default: return DifficultyLevel.advanced;
    }
  }

  static PublicationStatus _getStatutFromString(String value) {
    switch (value) {
      case 'published': return PublicationStatus.published;
      case 'archived': return PublicationStatus.archived;
      default: return PublicationStatus.draft;
    }
  }

 
  Activite copyWith({
    String? id,
    String? titre,
    String? description,
    ActivityCategory? categorie,
    DifficultyLevel? difficulte,
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
      categorie: categorie ?? this.categorie,
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