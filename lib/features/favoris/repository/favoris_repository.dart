import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/favoris/models/favoris.dart';


class FavoriService {
  final FirebaseFirestore _firestore;

  FavoriService(this._firestore);

  CollectionReference<Map<String, dynamic>>
      get _favorisCollection =>
          _firestore.collection('favoris');


  Stream<List<Favori>> getFavoris(
    String utilisateurId,
  ) {
    return _favorisCollection
        .where(
          'utilisateurId',
          isEqualTo: utilisateurId,
        )
        .orderBy(
          'dateCreation',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  (doc) => Favori.fromFirestore(doc),
                )
                .toList();
          },
        );
  }


  Future<void> ajouterFavori(
    Favori favori,
  ) async {
    // Vérifier si l'élément existe déjà
    final query = await _favorisCollection
        .where(
          'utilisateurId',
          isEqualTo: favori.utilisateurId,
        )
        .where(
          'elementId',
          isEqualTo: favori.elementId,
        )
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return;
    }

    await _favorisCollection.add(
      favori.toFirestore(),
    );
  }


  Future<void> supprimerFavori(
    String favoriId,
  ) async {
    await _favorisCollection
        .doc(favoriId)
        .delete();
  }
}