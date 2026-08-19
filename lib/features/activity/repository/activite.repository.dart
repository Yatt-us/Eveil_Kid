import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/activity/models/Activite.model.dart';
import 'package:eveilkid/features/activity/enums/ActivityCategory.enum.dart';
import 'package:eveilkid/features/activity/enums/DifficultyLevel.enum.dart';


class ActiviteRepository {
  final CollectionReference _activitesRef = 
      FirebaseFirestore.instance.collection('activites');


  Future<List<Activite>> getAllActivites() async {
    try {
      QuerySnapshot snapshot = await _activitesRef
          .where('statut', isEqualTo: 'published')
          .orderBy('ordreAffichage')
          .get();
      
      return snapshot.docs
          .map((doc) => Activite.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  
  Future<List<Activite>> getAllActivitesForAdmin() async {
    try {
      QuerySnapshot snapshot = await _activitesRef
          .orderBy('ordreAffichage')
          .get();
      
      return snapshot.docs
          .map((doc) => Activite.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }


  Future<Activite?> getActiviteById(String id) async {
    try {
      DocumentSnapshot doc = await _activitesRef.doc(id).get();
      if (doc.exists) {
        return Activite.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Activite> createActivite(Activite activite) async {
    try {
      DocumentReference docRef = _activitesRef.doc();
      
      Activite newActivite = activite.copyWith(
        id: docRef.id,
        dateCreation: DateTime.now(),
        dateModification: DateTime.now(),
      );
      
      await docRef.set(newActivite.toFirestore());
      return newActivite;
    } catch (e) {
      throw Exception('Erreur lors de la création: $e');
    }
  }

 
  Future<Activite> updateActivite(Activite activite) async {
    try {
      if (activite.id == null) {
        throw Exception('ID manquant');
      }
      
      Activite updatedActivite = activite.copyWith(
        dateModification: DateTime.now(),
      );
      
      await _activitesRef
          .doc(activite.id)
          .update(updatedActivite.toFirestore());
      
      return updatedActivite;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

 
  Future<void> deleteActivite(String id) async {
    try {
      await _activitesRef.doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  
  Future<void> publishActivite(String id) async {
    try {
      await _activitesRef.doc(id).update({
        'statut': 'published',
        'dateModification': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  
  Future<void> unpublishActivite(String id) async {
    try {
      await _activitesRef.doc(id).update({
        'statut': 'draft',
        'dateModification': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  
  Future<List<Activite>> searchActivites(String searchTerm) async {
    try {
      List<Activite> allActivites = await getAllActivites();
      
      return allActivites.where((activite) {
        return activite.titre.toLowerCase().contains(searchTerm.toLowerCase()) ||
               activite.description.toLowerCase().contains(searchTerm.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  
  Future<List<Activite>> filterByCategorie(ActivityCategory categorie) async {
    try {
      QuerySnapshot snapshot = await _activitesRef
          .where('categorie', isEqualTo: categorie.toString().split('.').last)
          .where('statut', isEqualTo: 'published')
          .get();
      
      return snapshot.docs
          .map((doc) => Activite.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  
  Future<List<Activite>> filterByAge(int age) async {
    try {
      QuerySnapshot snapshot = await _activitesRef
          .where('ageMinimum', isLessThanOrEqualTo: age)
          .where('ageMaximum', isGreaterThanOrEqualTo: age)
          .where('statut', isEqualTo: 'published')
          .get();
      
      return snapshot.docs
          .map((doc) => Activite.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  
  Future<List<Activite>> filterByDifficulte(DifficultyLevel difficulte) async {
    try {
      QuerySnapshot snapshot = await _activitesRef
          .where('difficulte', isEqualTo: difficulte.toString().split('.').last)
          .where('statut', isEqualTo: 'published')
          .get();
      
      return snapshot.docs
          .map((doc) => Activite.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}