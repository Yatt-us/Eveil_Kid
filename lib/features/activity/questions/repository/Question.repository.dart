import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Question.model.dart';


class QuestionRepository {
  
  CollectionReference _getQuestionsCollection(String activiteId) {
    return FirebaseFirestore.instance
        .collection('activites')
        .doc(activiteId)
        .collection('questions');
  }

  
  Future<List<Question>> getQuestionsByActivite(String activiteId) async {
    try {
      QuerySnapshot snapshot = await _getQuestionsCollection(activiteId)
          .orderBy('ordre')
          .get();
      
      return snapshot.docs
          .map((doc) => Question.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  
  Future<Question?> getQuestionById(String activiteId, String questionId) async {
    try {
      DocumentSnapshot doc = await _getQuestionsCollection(activiteId)
          .doc(questionId)
          .get();
      
      if (doc.exists) {
        return Question.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Question> createQuestion(String activiteId, Question question) async {
    try {
      DocumentReference docRef = _getQuestionsCollection(activiteId).doc();
      
      Question newQuestion = question.copyWith(
        id: docRef.id,
        activiteId: activiteId,
        dateCreation: DateTime.now(),
        dateModification: DateTime.now(),
      );
      
      await docRef.set(newQuestion.toFirestore());
      return newQuestion;
    } catch (e) {
      throw Exception('Erreur lors de la création: $e');
    }
  }


  Future<Question> updateQuestion(String activiteId, Question question) async {
    try {
      if (question.id == null) {
        throw Exception('ID manquant');
      }
      
      Question updatedQuestion = question.copyWith(
        dateModification: DateTime.now(),
      );
      
      await _getQuestionsCollection(activiteId)
          .doc(question.id)
          .update(updatedQuestion.toFirestore());
      
      return updatedQuestion;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

 
  Future<void> deleteQuestion(String activiteId, String questionId) async {
    try {
      await _getQuestionsCollection(activiteId)
          .doc(questionId)
          .delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

 
  Future<void> updateQuestionsOrder(String activiteId, List<Question> questions) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      
      for (Question question in questions) {
        if (question.id != null) {
          DocumentReference ref = _getQuestionsCollection(activiteId)
              .doc(question.id);
          batch.update(ref, {'ordre': question.ordre});
        }
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'ordre: $e');
    }
  }

 
  Future<bool> verifierReponse(String activiteId, String questionId, int indexSelectionne) async {
    try {
      Question? question = await getQuestionById(activiteId, questionId);
      if (question == null) {
        return false;
      }
      
      return question.indexBonneReponse == indexSelectionne;
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  
  Future<void> deleteAllQuestions(String activiteId) async {
    try {
      QuerySnapshot snapshot = await _getQuestionsCollection(activiteId).get();
      
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors de la suppression des questions: $e');
    }
  }
}