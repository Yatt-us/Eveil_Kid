import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
class TutorielRepository {
  final FirebaseFirestore _firestore;

  TutorielRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tutorielsCollection =>
      _firestore.collection('tutoriels');

  // Récupérer tous les tutoriels
  Future<List<Tutoriel>> getTutoriels() async {
    final snapshot = await _tutorielsCollection
        .where('estPublie', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Tutoriel.fromFirestore(doc))
        .toList();
  }

  // Récupérer un tutoriel par son ID
  Future<Tutoriel?> getTutorielById(String tutorielId) async {
    final doc = await _tutorielsCollection.doc(tutorielId).get();

    if (!doc.exists) {
      return null;
    }

    return Tutoriel.fromFirestore(doc);
  }

  // Ajouter un tutoriel
  Future<String> createTutoriel(Tutoriel tutoriel) async {
    final docRef = _tutorielsCollection.doc();

    await docRef.set(tutoriel.toFirestore());

    return docRef.id;
  }

  // Modifier un tutoriel
  Future<void> updateTutoriel(Tutoriel tutoriel) async {
    await _tutorielsCollection
        .doc(tutoriel.tutorielId)
        .update(tutoriel.toFirestore());
  }

  // Supprimer un tutoriel
  Future<void> deleteTutoriel(String tutorielId) async {
    await _tutorielsCollection.doc(tutorielId).delete();
  }
}