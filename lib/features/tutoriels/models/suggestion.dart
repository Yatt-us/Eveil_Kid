import 'package:cloud_firestore/cloud_firestore.dart';

class Suggestion {
  final String suggestionId;
  final String tutorielId;
  final String jouetId;
  final int temps;
  final String message;

  Suggestion({
    required this.suggestionId,
    required this.tutorielId,
    required this.jouetId,
    required this.temps,
    required this.message,
  });

  /// Firestore -> Model
  factory Suggestion.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return Suggestion(
      suggestionId: doc.id,
      tutorielId: data['tutorielId'] as String,
      jouetId: data['jouetId'] as String,
      temps: (data['temps'] as num).toInt(),
      message: data['message'] as String,
    );
  }

  /// Model -> Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'tutorielId': tutorielId,
      'jouetId': jouetId,
      'temps': temps,
      'message': message,
    };
  }
}