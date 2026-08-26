import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/favoris/models/favoris.dart';

class FavoriService {
  final FirebaseFirestore _firestore;

  FavoriService(this._firestore);

  CollectionReference<Map<String, dynamic>> get _favorisCollection =>
      _firestore.collection('favoris');

  Stream<List<Favori>> getFavoris(String utilisateurId) {
    if (utilisateurId.isEmpty) {
      return Stream.value([]);
    }

    return _favorisCollection
        .where('utilisateurId', isEqualTo: utilisateurId)
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Favori.fromFirestore(doc)).toList();
    });
  }

  Future<void> ajouterFavori(Favori favori) async {
    final query = await _favorisCollection
        .where('utilisateurId', isEqualTo: favori.utilisateurId)
        .where('elementId', isEqualTo: favori.elementId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return;
    }

    await _favorisCollection.add(favori.toFirestore());

    if (favori.utilisateurId.isNotEmpty) {
      await _firestore.collection('utilisateurs').doc(favori.utilisateurId).update({
        'nombreFavoris': FieldValue.increment(1),
      }).catchError((_) {});
    }
  }

  Future<void> supprimerFavori(String favoriId, {String? utilisateurId}) async {
    await _favorisCollection.doc(favoriId).delete();

    if (utilisateurId != null && utilisateurId.isNotEmpty) {
      await _firestore.collection('utilisateurs').doc(utilisateurId).update({
        'nombreFavoris': FieldValue.increment(-1),
      }).catchError((_) {});
    }
  }

  Future<void> toggleFavori({
    required String utilisateurId,
    required String elementId,
    required TypeElement typeElement,
    required String titre,
    required String miniatureUrl,
    required double prix,
  }) async {
    if (utilisateurId.isEmpty) return;

    final query = await _favorisCollection
        .where('utilisateurId', isEqualTo: utilisateurId)
        .where('elementId', isEqualTo: elementId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await _favorisCollection.doc(query.docs.first.id).delete();
      await _firestore.collection('utilisateurs').doc(utilisateurId).update({
        'nombreFavoris': FieldValue.increment(-1),
      }).catchError((_) {});
    } else {
      final newFavori = Favori(
        favoriId: '',
        utilisateurId: utilisateurId,
        elementId: elementId,
        typeElement: typeElement,
        titre: titre,
        miniatureUrl: miniatureUrl,
        prix: prix,
        dateCreation: DateTime.now(),
      );
      await _favorisCollection.add(newFavori.toFirestore());
      await _firestore.collection('utilisateurs').doc(utilisateurId).update({
        'nombreFavoris': FieldValue.increment(1),
      }).catchError((_) {});
    }
  }
}