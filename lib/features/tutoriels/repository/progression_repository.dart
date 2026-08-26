import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/progression.dart';

class ProgressionRepository {
  final FirebaseFirestore _firestore;

  ProgressionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _progressionsCollection =>
      _firestore.collection('progressions');

  Future<Progression?> getProgression(String tutorielId) async {
    final doc = await _progressionsCollection.doc(tutorielId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Progression.fromFirestore(doc);
  }

  Future<void> saveProgression(Progression progression) async {
    await _progressionsCollection
        .doc(progression.tutorielId)
        .set(progression.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteProgression(String tutorielId) async {
    await _progressionsCollection.doc(tutorielId).delete();
  }
}