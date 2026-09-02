import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/avis_model.dart';

class AvisRepository {
  final FirebaseFirestore _firestore;

  AvisRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getAvisCollection(String jouetId) {
    return _firestore.collection('jouets').doc(jouetId).collection('avis');
  }

  /// Écoute en temps réel les avis d'un jouet
  Stream<List<AvisModel>> streamAvis(String jouetId) {
    return _getAvisCollection(jouetId)
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AvisModel.fromFirestore(doc)).toList();
    });
  }

  /// Récupère la liste des avis d'un jouet
  Future<List<AvisModel>> recupererAvis(String jouetId) async {
    try {
      final snapshot = await _getAvisCollection(jouetId)
          .orderBy('dateCreation', descending: true)
          .get();
      return snapshot.docs.map((doc) => AvisModel.fromFirestore(doc)).toList();
    } catch (e) {
      try {
        final snapshot = await _getAvisCollection(jouetId).get();
        final list = snapshot.docs.map((doc) => AvisModel.fromFirestore(doc)).toList();
        list.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        return list;
      } catch (e2) {
        throw Exception('Erreur lors de la récupération des avis : $e2');
      }
    }
  }

  /// Ajoute ou modifie un avis et met à jour la note moyenne du jouet
  Future<AvisModel> ajouterOuModifierAvis(AvisModel avis) async {
    try {
      final coll = _getAvisCollection(avis.jouetId);
      final docRef = avis.avisId.isNotEmpty ? coll.doc(avis.avisId) : coll.doc();

      final avisFinal = avis.copyWith(
        avisId: docRef.id,
        dateModification: avis.avisId.isNotEmpty ? DateTime.now() : null,
      );

      await docRef.set(avisFinal.toMap(), SetOptions(merge: true));

      // Recalcul de la note moyenne et du nombre d'avis
      await _mettreAJourStatistiquesJouet(avis.jouetId);

      return avisFinal;
    } catch (e) {
      throw Exception('Erreur lors de l\'enregistrement de l\'avis : $e');
    }
  }

  /// Supprime un avis et recalcule la note moyenne
  Future<void> supprimerAvis(String jouetId, String avisId) async {
    try {
      await _getAvisCollection(jouetId).doc(avisId).delete();
      await _mettreAJourStatistiquesJouet(jouetId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'avis : $e');
    }
  }

  /// Met à jour les champs dénormalisés noteMoyenneDenormalise et nombreAvisDenormalise du jouet
  Future<void> _mettreAJourStatistiquesJouet(String jouetId) async {
    try {
      final snapshot = await _getAvisCollection(jouetId).get();
      final avisList = snapshot.docs.map((d) => AvisModel.fromFirestore(d)).toList();

      final totalAvis = avisList.length;
      double noteMoyenne = 0.0;

      if (totalAvis > 0) {
        final sommeNotes = avisList.fold<double>(0.0, (acc, a) => acc + a.note);
        noteMoyenne = double.parse((sommeNotes / totalAvis).toStringAsFixed(1));
      }

      await _firestore.collection('jouets').doc(jouetId).update({
        'noteMoyenneDenormalise': noteMoyenne,
        'nombreAvisDenormalise': totalAvis,
        'dateModification': Timestamp.now(),
      });
    } catch (_) {
      // Si la mise à jour dénormalisée échoue, elle ne bloque pas l'écriture de l'avis
    }
  }
}
