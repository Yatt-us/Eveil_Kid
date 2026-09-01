import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/questions/enums/question_type.enum.dart';
import 'package:eveilkid/features/questions/models/question_model.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';

class QuestionRepository {
  final FirebaseFirestore? _firestore;

  QuestionRepository({FirebaseFirestore? firestore}) : _firestore = firestore;

  CollectionReference _getQuestionsCollection(String activiteId) {
    return (_firestore ?? FirebaseFirestore.instance)
        .collection('activites')
        .doc(activiteId)
        .collection('questions');
  }

  Future<List<Question>> getQuestionsByActivite(String activiteId) async {
    try {
      final snapshot = await _getQuestionsCollection(activiteId)
          .orderBy('ordre')
          .get();
      
      final list = snapshot.docs.map((doc) => _fromFirestore(doc, activiteId)).toList();
      return list.where((q) => !q.estArchive).toList();
    } catch (_) {
      try {
        final snapshot = await _getQuestionsCollection(activiteId).get();
        final list = snapshot.docs.map((doc) => _fromFirestore(doc, activiteId)).toList();
        final activeQuestions = list.where((q) => !q.estArchive).toList();
        activeQuestions.sort((a, b) => a.ordre.compareTo(b.ordre));
        return activeQuestions;
      } catch (e) {
        throw Exception('Erreur: $e');
      }
    }
  }

  Future<List<Question>> getAllQuestionsByActivite(String activiteId) async {
    try {
      final snapshot = await _getQuestionsCollection(activiteId)
          .orderBy('ordre')
          .get();
      
      return snapshot.docs.map((doc) => _fromFirestore(doc, activiteId)).toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Question?> getQuestionById(String activiteId, String questionId) async {
    try {
      final doc = await _getQuestionsCollection(activiteId).doc(questionId).get();
      if (doc.exists) {
        return _fromFirestore(doc, activiteId);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Question> createQuestion(String activiteId, Question question) async {
    try {
      final existingQuestions = await getQuestionsByActivite(activiteId);
      final nextOrder = existingQuestions.length;
      
      final docRef = _getQuestionsCollection(activiteId).doc();
      final newQuestion = question.copyWith(
        id: docRef.id,
        ordre: nextOrder,
        estArchive: false,
      );
      
      await docRef.set(_toFirestore(newQuestion));
      return newQuestion;
    } catch (e) {
      throw Exception('Erreur lors de la création: $e');
    }
  }

  Future<Question> updateQuestion(String activiteId, Question question) async {
    try {
      if (question.id == null) throw Exception('ID manquant');
      
      final existingDoc = await _getQuestionsCollection(activiteId).doc(question.id).get();
      final existingData = existingDoc.data() as Map<String, dynamic>?;
      final existingOrder = existingData?['ordre'] ?? question.ordre;
      final existingArchived = existingData?['estArchive'] ?? false;
      
      final updatedQuestion = question.copyWith(
        ordre: existingOrder,
        estArchive: existingArchived,
      );
      
      await _getQuestionsCollection(activiteId)
          .doc(question.id)
          .update(_toFirestore(updatedQuestion));
      return updatedQuestion;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  Future<void> archiveQuestion(String activiteId, String questionId) async {
    try {
      await _getQuestionsCollection(activiteId)
          .doc(questionId)
          .update({
            'estArchive': true,
            'dateArchivage': Timestamp.now(),
          });
      
      await _reorderQuestionsAfterArchive(activiteId);
    } catch (e) {
      throw Exception('Erreur lors de l\'archivage: $e');
    }
  }

  Future<void> _reorderQuestionsAfterArchive(String activiteId) async {
    try {
      final questions = await getQuestionsByActivite(activiteId);
      final batch = (_firestore ?? FirebaseFirestore.instance).batch();
      
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        if (question.id != null) {
          batch.update(
            _getQuestionsCollection(activiteId).doc(question.id),
            {'ordre': i}
          );
        }
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors du réordonnancement: $e');
    }
  }

  Future<void> restoreQuestion(String activiteId, String questionId) async {
    try {
      await _getQuestionsCollection(activiteId)
          .doc(questionId)
          .update({
            'estArchive': false,
            'dateArchivage': null,
          });
      
      await _reorderQuestionsAfterArchive(activiteId);
    } catch (e) {
      throw Exception('Erreur lors de la restauration: $e');
    }
  }

  Future<void> updateQuestionsOrder(String activiteId, List<Question> questions) async {
    try {
      final batch = (_firestore ?? FirebaseFirestore.instance).batch();
      for (var question in questions) {
        if (question.id != null) {
          batch.update(
            _getQuestionsCollection(activiteId).doc(question.id),
            {'ordre': question.ordre}
          );
        }
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Question _fromFirestore(DocumentSnapshot doc, String activiteId) {
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
      estArchive: data['estArchive'] ?? false,
    );
  }

  Map<String, dynamic> _toFirestore(Question question) {
    return {
      'enonce': question.enonce,
      'type': question.type.value,
      'options': question.options.map((e) => e.toMap()).toList(),
      'idReponseCorrecte': question.idReponseCorrecte,
      'points': question.points,
      'ordre': question.ordre,
      'imageUrl': question.imageUrl,
      'estArchive': question.estArchive,
      if (question.estArchive == true) 
        'dateArchivage': Timestamp.now(),
    };
  }
}
