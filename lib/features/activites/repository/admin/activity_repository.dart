import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/core/cloudinary/cloudinary_service.dart';
import 'package:eveilkid/features/activites/mappers/activity_mapper.dart';
import 'package:eveilkid/features/activites/models/activity.dart';

class ActivityRepository {
  final CollectionReference _activitesRef = 
      FirebaseFirestore.instance.collection('activites');
  final CloudinaryService _cloudinary;

  ActivityRepository({CloudinaryService? cloudinary})
      : _cloudinary = cloudinary ?? CloudinaryService();

  // Récupérer toutes les activités publiées
  Future<List<Activite>> getAllActivites() async {
    try {
      final snapshot = await _activitesRef
          .where('statut', isEqualTo: 'publie')
          .orderBy('ordreAffichage')
          .get();
      
      return ActivityMapper.fromFirestoreList(snapshot.docs);
    } catch (e) {
      throw Exception('Erreur lors de la récupération: $e');
    }
  }

  // Récupérer toutes les activités (pour admin)
  Future<List<Activite>> getAllActivitesForAdmin() async {
    try {
      final snapshot = await _activitesRef
          .orderBy('ordreAffichage')
          .get();
      
      return ActivityMapper.fromFirestoreList(snapshot.docs);
    } catch (e) {
      throw Exception('Erreur lors de la récupération: $e');
    }
  }

  // Récupérer une activité par ID
  Future<Activite?> getActiviteById(String id) async {
    try {
      final doc = await _activitesRef.doc(id).get();
      if (doc.exists) {
        return ActivityMapper.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération: $e');
    }
  }

  // ✅ CRÉER UNE ACTIVITÉ AVEC ORDRE AUTOMATIQUE
  Future<Activite> createActivite(Activite activite) async {
    try {
      // ✅ Récupérer le nombre total d'activités pour définir l'ordre
      final snapshot = await _activitesRef.get();
      final totalActivities = snapshot.docs.length;
      
      final docRef = _activitesRef.doc();
      
      final newActivite = activite.copyWith(
        id: docRef.id,
        dateCreation: DateTime.now(),
        dateModification: DateTime.now(),
        ordreAffichage: totalActivities, // ✅ Ordre basé sur le nombre total
      );
      
      await docRef.set(ActivityMapper.toFirestore(newActivite));
      return newActivite;
    } catch (e) {
      throw Exception('Erreur lors de la création: $e');
    }
  }

  // ✅ METTRE À JOUR UNE ACTIVITÉ (sans modifier l'ordre)
  Future<Activite> updateActivite(Activite activite) async {
    try {
      if (activite.id == null) {
        throw Exception('ID manquant');
      }
      
      // ✅ Conserver l'ordre existant
      final existingDoc = await _activitesRef.doc(activite.id).get();
      final existingData = existingDoc.data() as Map<String, dynamic>?;
      final existingOrder = existingData?['ordreAffichage'] ?? 0;
      
      final updatedActivite = activite.copyWith(
        dateModification: DateTime.now(),
        ordreAffichage: existingOrder, // ✅ Garder l'ordre existant
      );
      
      await _activitesRef
          .doc(activite.id)
          .update(ActivityMapper.toFirestore(updatedActivite));
      
      return updatedActivite;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  // ✅ RÉORDONNER LES ACTIVITÉS (pour le drag & drop)
  Future<void> reorderActivities(List<Activite> activities) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      for (int i = 0; i < activities.length; i++) {
        final activity = activities[i];
        if (activity.id != null) {
          batch.update(
            _activitesRef.doc(activity.id),
            {'ordreAffichage': i}
          );
        }
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors du réordonnancement: $e');
    }
  }

  // Supprimer une activité
  Future<void> deleteActivite(String id) async {
    try {
      await _activitesRef.doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  // Upload d'image avec Cloudinary
  Future<String> uploadImage(String activityId, File imageFile) async {
    try {
      final downloadUrl = await _cloudinary.uploadImage(
        imageFile,
        folder: 'activites/$activityId',
      );
      
      await _activitesRef.doc(activityId).update({
        'imageUrl': downloadUrl,
        'dateModification': Timestamp.now(),
      });
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de l\'image: $e');
    }
  }

  // Publier une activité
  Future<void> publierActivite(String id) async {
    try {
      await _activitesRef.doc(id).update({
        'statut': 'publie',
        'dateModification': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la publication: $e');
    }
  }

  // Dépublier une activité
  Future<void> depublierActivite(String id) async {
    try {
      await _activitesRef.doc(id).update({
        'statut': 'brouillon',
        'dateModification': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors du dépublication: $e');
    }
  }
}