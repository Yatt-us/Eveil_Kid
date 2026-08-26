import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TutorielRepository {
 final FirebaseFirestore _firestore;

 TutorielRepository({FirebaseFirestore? firestore})
     : _firestore = firestore ?? FirebaseFirestore.instance;

 CollectionReference<Map<String, dynamic>> get _tutorielsCollection =>
     _firestore.collection('tutoriels');

   final FirebaseStorage _storage = FirebaseStorage.instance;

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
   final cleanedId = tutorielId.trim();
   if (cleanedId.isEmpty) return null;

   final doc = await _tutorielsCollection.doc(cleanedId).get();
   if (doc.exists && doc.data() != null) {
     return Tutoriel.fromFirestore(doc);
   }

   final snapshot = await _tutorielsCollection
       .where('tutorielId', isEqualTo: cleanedId)
       .limit(1)
       .get();

   if (snapshot.docs.isEmpty) return null;
   return Tutoriel.fromFirestore(snapshot.docs.first);
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

  Future<Tutoriel> createTutoriel(Tutoriel tutoriel) async {
    try {
      final docRef = _tutorielsCollection.doc();
      final newTutoriel = tutoriel.copyWith(
        tutorielId: docRef.id,
        dateCreation: DateTime.now(),
        dateModification: DateTime.now(),
      );
      await docRef.set(newTutoriel.toFirestore());
      return newTutoriel;
    } catch (e) {
      throw Exception('Erreur lors de la création: $e');
    }
  }

  Future<Tutoriel> updateTutoriel(Tutoriel tutoriel) async {
    try {
      if (tutoriel.tutorielId == null) throw Exception('ID manquant');
      final updatedTutoriel = tutoriel.copyWith(
        dateModification: DateTime.now(),
      );
      await _tutorielsCollection
          .doc(tutoriel.tutorielId)
          .update(updatedTutoriel.toFirestore());
      return updatedTutoriel;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

 Future<void> deleteTutoriel(String id) async {
    try {
      await _tutorielsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  Future<String> uploadMiniature(String tutorielId, File imageFile) async {
    try {
      final ref = _storage.ref().child(
        'tutoriels/$tutorielId/miniature.jpg'
      );
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      await _tutorielsCollection.doc(tutorielId).update({
        'miniatureUrl': downloadUrl,
        'dateModification': Timestamp.now(),
      });
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors du téléchargement: $e');
    }
  }

  Future<void> publierTutoriel(String id) async {
    try {
      await _tutorielsCollection.doc(id).update({
        'statut': 'publie',
        'dateModification': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> depublierTutoriel(String id) async {
    try {
      await _tutorielsCollection.doc(id).update({
        'statut': 'brouillon',
        'dateModification': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }




  Future<List<Tutoriel>> getAllTutoriels() async {
    try {
      final snapshot = await _tutorielsCollection
          .where('statut', isEqualTo: 'publie')
          .orderBy('dateCreation', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => Tutoriel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<List<Tutoriel>> getAllTutorielsForAdmin() async {
    try {
      final snapshot = await _tutorielsCollection
          .orderBy('dateCreation', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => Tutoriel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

}

