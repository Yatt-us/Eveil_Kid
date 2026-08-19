import 'package:cloud_firestore/cloud_firestore.dart';
import 'activitees_enums.dart';
import 'question_model.dart';

class ActiviteesModel {
  final String id;
  final String titre;
  final String description;
  final String cheminImage;
  final CategorieActivitee categorie;
  final DifficulteActivitee difficulte;
  final StatutActivitee statut;
  final double progression;
  final int totalQuestions;
  final List<QuestionModel> questions;

  const ActiviteesModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.cheminImage,
    required this.categorie,
    required this.difficulte,
    this.statut = StatutActivitee.enCours,
    this.progression = 0.0,
    required this.totalQuestions,
    this.questions = const [],
  });

  factory ActiviteesModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final rawQuestions = data['questions'] as List<dynamic>? ?? [];
    final parsedQuestions = rawQuestions
        .map((q) => QuestionModel.fromMap(q as Map<String, dynamic>))
        .toList();

    return ActiviteesModel(
      id: doc.id,
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      cheminImage: data['cheminImage'] ?? '',
      categorie: CategorieActivitee.values.firstWhere(
        (e) => e.name == data['categorie'],
        orElse: () => CategorieActivitee.sciences,
      ),
      difficulte: DifficulteActivitee.values.firstWhere(
        (e) => e.name == data['difficulte'],
        orElse: () => DifficulteActivitee.facile,
      ),
      statut: StatutActivitee.values.firstWhere(
        (e) => e.name == data['statut'],
        orElse: () => StatutActivitee.enCours,
      ),
      progression: (data['progression'] as num?)?.toDouble() ?? 0.0,
      totalQuestions: data['totalQuestions'] ?? parsedQuestions.length,
      questions: parsedQuestions,
    );
  }
}