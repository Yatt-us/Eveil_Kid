import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/activite_enums.dart';
import 'question.dart';

/// Modèle complet représentant une Activité ludo-éducative.
class Activite {
  final String id;
  final String titre;
  final String description;
  final String cheminImage;
  final CategorieActivite categorie;
  final DifficulteActivite difficulte;
  final StatutActivite statut;
  final StatutPublication statutPublication;
  final double progression;
  final int totalQuestions;
  final List<Question> questions;
  final int ageMinimum;
  final int ageMaximum;
  final int dureeEnMinutes;
  final List<String> materiels;
  final List<String> objectifsApprentissage;
  final int points;
  final int ordreAffichage;
  final DateTime dateCreation;
  final DateTime dateModification;

  const Activite({
    required this.id,
    required this.titre,
    required this.description,
    this.cheminImage = '',
    this.categorie = CategorieActivite.logique,
    this.difficulte = DifficulteActivite.facile,
    this.statut = StatutActivite.enCours,
    this.statutPublication = StatutPublication.published,
    this.progression = 0.0,
    this.totalQuestions = 0,
    this.questions = const [],
    this.ageMinimum = 3,
    this.ageMaximum = 10,
    this.dureeEnMinutes = 15,
    this.materiels = const [],
    this.objectifsApprentissage = const [],
    this.points = 100,
    this.ordreAffichage = 0,
    required this.dateCreation,
    required this.dateModification,
  });

  /// Getter facilitant pour l'image
  String get imageUrl => cheminImage;

  /// Indique si l'activité est complètement terminée
  bool get estTerminee => statut == StatutActivite.terminees || progression >= 1.0;

  factory Activite.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final rawQuestions = data['questions'] as List<dynamic>? ?? [];
    final parsedQuestions = <Question>[];
    for (int i = 0; i < rawQuestions.length; i++) {
      final q = rawQuestions[i];
      if (q is Map<String, dynamic>) {
        parsedQuestions.add(Question.fromMap(q, index: i));
      }
    }

    final parsedCategorie = CategorieActivite.fromString(data['categorie']?.toString());
    final parsedDifficulte = DifficulteActivite.fromString(data['difficulte']?.toString());
    final parsedStatut = StatutActivite.fromString(data['statut']?.toString());
    final parsedPublication = StatutPublication.fromString(data['statutPublication']?.toString());

    final now = DateTime.now();
    DateTime createdAt = now;
    if (data['dateCreation'] is Timestamp) {
      createdAt = (data['dateCreation'] as Timestamp).toDate();
    }
    DateTime updatedAt = now;
    if (data['dateModification'] is Timestamp) {
      updatedAt = (data['dateModification'] as Timestamp).toDate();
    }

    final totalQ = (data['totalQuestions'] as num?)?.toInt() ?? 
                   (parsedQuestions.isNotEmpty ? parsedQuestions.length : 0);

    return Activite(
      id: doc.id,
      titre: data['titre']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      cheminImage: data['cheminImage']?.toString() ?? data['imageUrl']?.toString() ?? '',
      categorie: parsedCategorie,
      difficulte: parsedDifficulte,
      statut: parsedStatut,
      statutPublication: parsedPublication,
      progression: (data['progression'] as num?)?.toDouble() ?? 0.0,
      totalQuestions: totalQ,
      questions: parsedQuestions,
      ageMinimum: (data['ageMinimum'] as num?)?.toInt() ?? 3,
      ageMaximum: (data['ageMaximum'] as num?)?.toInt() ?? 10,
      dureeEnMinutes: (data['dureeEnMinutes'] as num?)?.toInt() ?? 15,
      materiels: List<String>.from(data['materiels'] ?? []),
      objectifsApprentissage: List<String>.from(data['objectifsApprentissage'] ?? []),
      points: (data['points'] as num?)?.toInt() ?? (parsedQuestions.length * 10),
      ordreAffichage: (data['ordreAffichage'] as num?)?.toInt() ?? 0,
      dateCreation: createdAt,
      dateModification: updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titre': titre,
      'description': description,
      'cheminImage': cheminImage,
      'imageUrl': cheminImage,
      'categorie': categorie.name,
      'difficulte': difficulte.name,
      'statut': statut.name,
      'statutPublication': statutPublication.name,
      'progression': progression,
      'totalQuestions': totalQuestions > 0 ? totalQuestions : questions.length,
      'questions': questions.map((q) => q.toMap()).toList(),
      'ageMinimum': ageMinimum,
      'ageMaximum': ageMaximum,
      'dureeEnMinutes': dureeEnMinutes,
      'materiels': materiels,
      'objectifsApprentissage': objectifsApprentissage,
      'points': points,
      'ordreAffichage': ordreAffichage,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
    };
  }

  Activite copyWith({
    String? id,
    String? titre,
    String? description,
    String? cheminImage,
    CategorieActivite? categorie,
    DifficulteActivite? difficulte,
    StatutActivite? statut,
    StatutPublication? statutPublication,
    double? progression,
    int? totalQuestions,
    List<Question>? questions,
    int? ageMinimum,
    int? ageMaximum,
    int? dureeEnMinutes,
    List<String>? materiels,
    List<String>? objectifsApprentissage,
    int? points,
    int? ordreAffichage,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Activite(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      cheminImage: cheminImage ?? this.cheminImage,
      categorie: categorie ?? this.categorie,
      difficulte: difficulte ?? this.difficulte,
      statut: statut ?? this.statut,
      statutPublication: statutPublication ?? this.statutPublication,
      progression: progression ?? this.progression,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      questions: questions ?? this.questions,
      ageMinimum: ageMinimum ?? this.ageMinimum,
      ageMaximum: ageMaximum ?? this.ageMaximum,
      dureeEnMinutes: dureeEnMinutes ?? this.dureeEnMinutes,
      materiels: materiels ?? this.materiels,
      objectifsApprentissage: objectifsApprentissage ?? this.objectifsApprentissage,
      points: points ?? this.points,
      ordreAffichage: ordreAffichage ?? this.ordreAffichage,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }
}
