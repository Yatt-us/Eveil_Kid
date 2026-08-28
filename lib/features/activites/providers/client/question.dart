import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/client/question_quiz.dart';
final questionsStreamProvider =
    StreamProvider.family<List<QuestionQuiz>, String>((ref, activiteId) {
  return FirebaseFirestore.instance
      .collection('activites')
      .doc(activiteId)
      .collection('questions')
      .orderBy('ordre')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => QuestionQuiz.fromFirestore(doc)).toList());
});