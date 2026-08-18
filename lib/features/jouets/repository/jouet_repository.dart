import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/jouet.dart';

class JouetRepository {
  final FirebaseFirestore _firestore;

  JouetRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _jouetsCollection => _firestore.collection('jouets');


  Future<List<Jouet>> getJouets() async {
    final snapshot = await _jouetsCollection
        .where('estActif', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Jouet.fromFirestore(doc))
        .toList();
  }

  Future<Jouet?> getJouetById(String jouetId) async {
    final doc = await _jouetsCollection.doc(jouetId).get();

    if (!doc.exists) {
      return null;
    }

    return Jouet.fromFirestore(doc);
  }

  Future<List<Jouet>> getJouetsByCategorie(
    String categorieId,
  ) async {
    final snapshot = await _jouetsCollection
        .where('categorieId', isEqualTo: categorieId)
        .where('estActif', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Jouet.fromFirestore(doc))
        .toList();
  }

  Future<List<Jouet>> searchJouets(String recherche) async {
    final snapshot = await _jouetsCollection
        .where('estActif', isEqualTo: true)
        .get();

    final rechercheLower = recherche.toLowerCase();

    return snapshot.docs
        .map((doc) => Jouet.fromFirestore(doc))
        .where(
          (jouet) =>
              jouet.nom.toLowerCase().contains(rechercheLower),
        )
        .toList();
  }

  Future<void> ajouterJouet(Jouet jouet) async {
    await _jouetsCollection
        .doc(jouet.jouetId)
        .set(jouet.toFirestore());
  }


  Future<void> modifierJouet(Jouet jouet) async {
    await _jouetsCollection
        .doc(jouet.jouetId)
        .update(jouet.toFirestore());
  }


  Future<void> supprimerJouet(String jouetId) async {
    await _jouetsCollection.doc(jouetId).delete();
  }

  Future<void> modifierStock(
    String jouetId,
    int nouveauStock,
  ) async {
    await _jouetsCollection.doc(jouetId).update({
      'stock': nouveauStock,
      'stockDisponible': nouveauStock,
      'dateModification': Timestamp.now(),
    });
  }
}