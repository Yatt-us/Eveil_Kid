import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import '../models/question_model.dart';

import '../enums/question_type.enum.dart';

class QuestionMapper {
  static Question fromFirestore(DocumentSnapshot doc, String activiteId) {
    final data = doc.data() as Map<String, dynamic>;
    
    final optionsList = (data['options'] as List? ?? [])
        .map((e) => OptionQuestion.fromMap(e))
        .toList();

    return Question(
      id: doc.id,
      activiteId: activiteId,
      enonce: data['enonce'] ?? '',
      type: QuestionTypeExtension.fromString(data['type'] ?? 'choixMultiple'),
      options: optionsList,
      idReponseCorrecte: data['idReponseCorrecte'] ?? '',
      points: data['points'] ?? 10,
      ordre: data['ordre'] ?? 0,
      imageUrl: data['imageUrl'],
     
    );
  }

  static Map<String, dynamic> toFirestore(Question question) {
    return {
      'enonce': question.enonce,
      'type': question.type.value,
      'options': question.options.map((e) => e.toMap()).toList(),
      'idReponseCorrecte': question.idReponseCorrecte,
      'points': question.points,
      'ordre': question.ordre,
      'imageUrl': question.imageUrl,
    
    };
  }

  static List<Question> fromFirestoreList(List<DocumentSnapshot> docs, String activiteId) {
    return docs.map((doc) => fromFirestore(doc, activiteId)).toList();
  }
}