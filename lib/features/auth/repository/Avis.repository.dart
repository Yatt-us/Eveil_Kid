import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/auth/models/Avis.model.dart';


class AvisRepository {
  final CollectionReference _avisRef = 
      FirebaseFirestore.instance.collection('avis');

 
  Future<List<Avis>> getAllAvis() async {
    try {
      QuerySnapshot snapshot = await _avisRef
          .orderBy('dateCreation', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Avis.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  
  Future<List<Avis>> getAvisVisibles() async {
    try {
      QuerySnapshot snapshot = await _avisRef
          .where('statut', isEqualTo: 'visible')
          .orderBy('dateCreation', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Avis.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // 3. RÉCUPÉRER LES AVIS D'UNE CIBLE (activité, tutoriel, jouet)
  Future<List<Avis>> getAvisByCible(String cibleId, String typeCible) async {
    try {
      QuerySnapshot snapshot = await _avisRef
          .where('cibleId', isEqualTo: cibleId)
          .where('typeCible', isEqualTo: typeCible)
          .where('statut', isEqualTo: 'visible')
          .orderBy('dateCreation', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Avis.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }


  Future<Avis?> getAvisById(String id) async {
    try {
      DocumentSnapshot doc = await _avisRef.doc(id).get();
      if (doc.exists) {
        return Avis.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  
  Future<Avis> createAvis(Avis avis) async {
    try {
      DocumentReference docRef = _avisRef.doc();
      
      Avis newAvis = avis.copyWith(
        id: docRef.id,
        dateCreation: DateTime.now(),
        dateModification: DateTime.now(),
      );
      
      await docRef.set(newAvis.toFirestore());
      return newAvis;
    } catch (e) {
      throw Exception('Erreur lors de la création: $e');
    }
  }

  
  Future<Avis> updateAvis(Avis avis) async {
    try {
      if (avis.id == null) {
        throw Exception('ID manquant');
      }
      
      Avis updatedAvis = avis.copyWith(
        dateModification: DateTime.now(),
      );
      
      await _avisRef
          .doc(avis.id)
          .update(updatedAvis.toFirestore());
      
      return updatedAvis;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  
  Future<void> deleteAvis(String id) async {
    try {
      await _avisRef.doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  
  Future<void> masquerAvis(String id) async {
    try {
      await _avisRef.doc(id).update({
        'statut': 'masque',
        'dateModification': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // 9. RENDRE VISIBLE UN AVIS
  Future<void> rendreVisibleAvis(String id) async {
    try {
      await _avisRef.doc(id).update({
        'statut': 'visible',
        'dateModification': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // 10. RECHERCHER DES AVIS
  Future<List<Avis>> searchAvis(String searchTerm) async {
    try {
      List<Avis> allAvis = await getAllAvis();
      
      return allAvis.where((avis) {
        return avis.commentaire.toLowerCase().contains(searchTerm.toLowerCase()) ||
               avis.nomUtilisateur.toLowerCase().contains(searchTerm.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

 
  Future<List<Avis>> filterByNote(double noteMinimale) async {
    try {
      List<Avis> allAvis = await getAvisVisibles();
      
      return allAvis.where((avis) => avis.note >= noteMinimale).toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  
  Future<double> getNoteMoyenne(String cibleId, String typeCible) async {
    try {
      List<Avis> avis = await getAvisByCible(cibleId, typeCible);
      
      if (avis.isEmpty) {
        return 0.0;
      }
      
      double somme = avis.fold(0.0, (total, avis) => total + avis.note);
      return somme / avis.length;
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  
  Future<int> countAvisByCible(String cibleId, String typeCible) async {
    try {
      QuerySnapshot snapshot = await _avisRef
          .where('cibleId', isEqualTo: cibleId)
          .where('typeCible', isEqualTo: typeCible)
          .where('statut', isEqualTo: 'visible')
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  
  Future<List<Avis>> getDerniersAvis({int limit = 10}) async {
    try {
      QuerySnapshot snapshot = await _avisRef
          .where('statut', isEqualTo: 'visible')
          .orderBy('dateCreation', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => Avis.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}