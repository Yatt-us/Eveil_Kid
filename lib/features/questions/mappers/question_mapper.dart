import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import '../models/question_model.dart';
import '../enums/question_type.enum.dart';

class QuestionMapper {
  static Question fromFirestore(DocumentSnapshot doc, String activiteId) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    
    final rawOptions = (data['options'] as List? ??
        data['choix'] as List? ??
        data['reponses'] as List? ??
        []);

    final optionsList = <OptionQuestion>[];
    for (int i = 0; i < rawOptions.length; i++) {
      optionsList.add(OptionQuestion.fromMap(rawOptions[i], index: i));
    }

    final enonce = data['enonce'] ??
        data['intitule'] ??
        data['titre'] ??
        data['question'] ??
        '';

    final idReponse = data['idReponseCorrecte'] ??
        data['reponseCorrecteId'] ??
        data['bonneReponse'] ??
        data['reponseCorrecte'] ??
        '';

    final typeStr = data['type']?.toString() ?? 'choixMultiple';

    return Question(
      id: doc.id,
      activiteId: activiteId,
      enonce: enonce.toString(),
      type: QuestionTypeExtension.fromString(typeStr),
      options: optionsList,
      idReponseCorrecte: idReponse.toString(),
      points: (data['points'] is num) ? (data['points'] as num).toInt() : 10,
      ordre: (data['ordre'] is num) ? (data['ordre'] as num).toInt() : 0,
      imageUrl: data['imageUrl'] ?? data['image'],
      estArchive: data['estArchive'] == true,
    );
  }

  static Map<String, dynamic> toFirestore(Question question) {
    return {
      'enonce': question.enonce,
      'intitule': question.enonce,
      'type': question.type.value,
      'options': question.options.map((e) => e.toMap()).toList(),
      'idReponseCorrecte': question.idReponseCorrecte,
      'reponseCorrecteId': question.idReponseCorrecte,
      'points': question.points,
      'ordre': question.ordre,
      'imageUrl': question.imageUrl,
      'estArchive': question.estArchive,
    };
  }

  static List<Question> fromFirestoreList(List<DocumentSnapshot> docs, String activiteId) {
    return docs.map((doc) => fromFirestore(doc, activiteId)).toList();
  }
}