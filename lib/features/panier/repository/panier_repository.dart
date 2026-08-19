import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/panier/models/panier.dart';

class PanierService {
  final FirebaseFirestore _firestore;

  PanierService(this._firestore);

  final String collectionName = 'panier';

  CollectionReference<Map<String, dynamic>> get _panierCollection =>
      _firestore.collection(collectionName);

  Stream<List<ArticlePanier>> getPanier(String utilisateurId) {
    return _panierCollection
        .where('utilisateurId', isEqualTo: utilisateurId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ArticlePanier.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> ajouterProduit(ArticlePanier article) async {
    final query = await _panierCollection
        .where('utilisateurId', isEqualTo: article.utilisateurId)
        .where('jouetId', isEqualTo: article.jouetId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;

      final quantiteActuelle = (doc.data()['quantite'] as num).toInt();

      final nouvelleQuantite = quantiteActuelle + article.quantite;

      await doc.reference.update({
        'quantite': nouvelleQuantite,
        'dateModification': FieldValue.serverTimestamp(),
      });

      return;
    }

    await _panierCollection.add(article.toFirestore());
  }

  Future<void> supprimerProduit(String articlePanierId) async {
    await _panierCollection.doc(articlePanierId).delete();
  }

  Future<void> modifierQuantite({
    required String articlePanierId,
    required int quantite,
  }) async {
    if (quantite < 1) {
      throw Exception('La quantité doit être supérieure à 0');
    }

    await _panierCollection.doc(articlePanierId).update({
      'quantite': quantite,
      'dateModification': FieldValue.serverTimestamp(),
    });
  }

  Future<void> augmenterQuantite(ArticlePanier article) async {
    if (article.quantite >= article.stockDispo) {
      throw Exception('Stock insuffisant');
    }

    await modifierQuantite(
      articlePanierId: article.articlePanierId,
      quantite: article.quantite + 1,
    );
  }

  Future<void> diminuerQuantite(ArticlePanier article) async {
    if (article.quantite <= 1) {
      return;
    }

    await modifierQuantite(
      articlePanierId: article.articlePanierId,
      quantite: article.quantite - 1,
    );
  }

  Future<void> viderPanier(String utilisateurId) async {
    final snapshot = await _panierCollection
        .where('utilisateurId', isEqualTo: utilisateurId)
        .get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  double calculerTotal(List<ArticlePanier> articles) {
    return articles.fold(0, (total, article) => total + article.sousTotal);
  }
}
