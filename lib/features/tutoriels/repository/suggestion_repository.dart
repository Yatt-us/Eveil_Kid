import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/suggestion.dart';

class SuggestionRepository {
  final FirebaseFirestore _firestore;

  SuggestionRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
          firestore ?? FirebaseFirestore.instance;

  /// Récupérer les suggestions d'un tutoriel
  Future<List<Suggestion>> getSuggestions(
    String tutorielId,
  ) async {
    final snapshot = await _firestore
        .collection('tutoriels')
        .doc(tutorielId)
        .collection('suggestions')
        .orderBy('temps')
        .get();

    return snapshot.docs
        .map(
          (doc) => Suggestion.fromFirestore(doc),
        )
        .toList();
  }

  /// Récupérer une suggestion précise
  Future<Suggestion?> getSuggestionById(
    String tutorielId,
    String suggestionId,
  ) async {
    final doc = await _firestore
        .collection('tutoriels')
        .doc(tutorielId)
        .collection('suggestions')
        .doc(suggestionId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return Suggestion.fromFirestore(doc);
  }

  /// Ajouter une suggestion
  Future<String> createSuggestion(
    Suggestion suggestion,
  ) async {
    final collection = _firestore
        .collection('tutoriels')
        .doc(suggestion.tutorielId)
        .collection('suggestions');

    final docRef = collection.doc();

    await docRef.set(
      suggestion.toFirestore(),
    );

    return docRef.id;
  }

  /// Modifier une suggestion
  Future<void> updateSuggestion(
    Suggestion suggestion,
  ) async {
    await _firestore
        .collection('tutoriels')
        .doc(suggestion.tutorielId)
        .collection('suggestions')
        .doc(suggestion.suggestionId)
        .update(
          suggestion.toFirestore(),
        );
  }

  /// Supprimer une suggestion
  Future<void> deleteSuggestion(
    String tutorielId,
    String suggestionId,
  ) async {
    await _firestore
        .collection('tutoriels')
        .doc(tutorielId)
        .collection('suggestions')
        .doc(suggestionId)
        .delete();
  }
}