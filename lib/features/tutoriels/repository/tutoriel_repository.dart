import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';

class TutorielRepository {
 final FirebaseFirestore _firestore;

 TutorielRepository({FirebaseFirestore? firestore})
     : _firestore = firestore ?? FirebaseFirestore.instance;

 CollectionReference<Map<String, dynamic>> get _tutorielsCollection =>
     _firestore.collection('tutoriels');

 Future<List<Tutoriel>> getTutoriels({bool onlyPublished = true}) async {
   final query = onlyPublished
       ? _tutorielsCollection.where('estPublie', isEqualTo: true)
       : _tutorielsCollection;

   final snapshot = await query.get();
   return snapshot.docs
       .map((doc) => Tutoriel.fromFirestore(doc))
       .toList();
 }

 Future<Tutoriel?> getTutorielById(String tutorielId) async {
   final doc = await _tutorielsCollection.doc(tutorielId).get();
   if (!doc.exists || doc.data() == null) return null;
   return Tutoriel.fromFirestore(doc);
 }

 Future<List<Tutoriel>> searchTutoriels(String query) async {
   final tutoriels = await getTutoriels();
   final normalized = query.trim().toLowerCase();
   if (normalized.isEmpty) return tutoriels;

   return tutoriels.where((tutoriel) {
     final title = tutoriel.titre.toLowerCase();
     final description = tutoriel.description.toLowerCase();
     return title.contains(normalized) || description.contains(normalized);
   }).toList();
 }

 Future<String> createTutoriel(Tutoriel tutoriel) async {
   final docRef = _tutorielsCollection.doc();
   final value = tutoriel.copyWith(
     tutorielId: docRef.id,
     dateCreation: DateTime.now(),
     dateModification: DateTime.now(),
   );

   await docRef.set(value.toFirestore());
   return docRef.id;
 }

 Future<void> updateTutoriel(Tutoriel tutoriel) async {
   await _tutorielsCollection.doc(tutoriel.tutorielId).update(
     tutoriel.copyWith(
       dateModification: DateTime.now(),
     ).toFirestore(),
   );
 }

 Future<void> deleteTutoriel(String tutorielId) async {
   await _tutorielsCollection.doc(tutorielId).delete();
 }
}