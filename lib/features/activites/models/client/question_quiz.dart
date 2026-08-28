import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionQuiz {
  final String id;
  final String intitule;
  final String? audioUrl;
  final bool isGrid;
  final String reponseCorrecteId;
  final int ordre;
  final List<OptionQuiz> options;

  QuestionQuiz({
    required this.id,
    required this.intitule,
    this.audioUrl,
    required this.isGrid,
    required this.reponseCorrecteId,
    required this.ordre,
    required this.options,
  });

  factory QuestionQuiz.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final optionsList = (data['options'] as List<dynamic>?) ?? [];

    return QuestionQuiz(
      id: doc.id,
      intitule: data['intitule'] ?? '',
      audioUrl: data['audioUrl'],
      isGrid: data['isGrid'] ?? false,
      reponseCorrecteId: data['reponseCorrecteId'] ?? '',
      ordre: data['ordre'] ?? 0,
      options: optionsList
          .map((item) => OptionQuiz.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class OptionQuiz {
  final String id;
  final String libelle;
  final String? imageUrl;

  OptionQuiz({
    required this.id,
    required this.libelle,
    this.imageUrl,
  });

  factory OptionQuiz.fromMap(Map<String, dynamic> map) {
    return OptionQuiz(
      id: map['id'] ?? '',
      libelle: map['libelle'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }
}