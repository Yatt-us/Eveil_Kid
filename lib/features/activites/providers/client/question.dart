import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/pages/client/quiz_screen.dart';
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