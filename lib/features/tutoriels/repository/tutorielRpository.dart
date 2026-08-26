import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:firebase_storage/firebase_storage.dart';
class TutorielRepository {
  final FirebaseFirestore _firestore;

  TutorielRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tutorielsCollection =>
      _firestore.collection('tutoriels');
      final FirebaseStorage _storage = FirebaseStorage.instance;

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
}