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

  /// Récupère tous les jouets (actifs et inactifs) pour l'administration
  Future<List<Jouet>> getAllJouetsAdmin() async {
    final snapshot = await _jouetsCollection.get();
    return snapshot.docs
        .map((doc) => Jouet.fromFirestore(doc))
        .toList();
  }

  /// Écoute en temps réel tous les jouets pour l'espace manager
  Stream<List<Jouet>> streamJouetsAdmin() {
    return _jouetsCollection.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Jouet.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> ajouterJouet(Jouet jouet) async {
    final docRef = jouet.jouetId.isNotEmpty
        ? _jouetsCollection.doc(jouet.jouetId)
        : _jouetsCollection.doc();
    final effectiveJouet = jouet.jouetId.isNotEmpty
        ? jouet
        : jouet.copyWith(jouetId: docRef.id);
    await docRef.set(effectiveJouet.toFirestore(), SetOptions(merge: true));
  }

  Future<void> modifierJouet(Jouet jouet) async {
    await _jouetsCollection
        .doc(jouet.jouetId)
        .set(jouet.toFirestore(), SetOptions(merge: true));
  }

  Future<void> supprimerJouet(String jouetId) async {
    await _jouetsCollection.doc(jouetId).delete();
  }

  Future<void> modifierStock(
    String jouetId,
    int nouveauStock,
  ) async {
    await _jouetsCollection.doc(jouetId).set({
      'stock': nouveauStock,
      'stockDisponible': nouveauStock,
      'dateModification': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// Active ou désactive un jouet
  Future<void> toggleActif(String jouetId, bool estActif) async {
    await _jouetsCollection.doc(jouetId).set({
      'estActif': estActif,
      'dateModification': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// Définit si un jouet est populaire (mis en avant)
  Future<void> togglePopulaire(String jouetId, bool estPopulaire) async {
    await _jouetsCollection.doc(jouetId).set({
      'estPopulaire': estPopulaire,
      'dateModification': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// Modification express prix et stock
  Future<void> modifierPrixEtStock(
    String jouetId, {
    required double prix,
    required int stock,
    required int stockDisponible,
  }) async {
    await _jouetsCollection.doc(jouetId).set({
      'prix': prix,
      'stock': stock,
      'stockDisponible': stockDisponible,
      'dateModification': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// Modifie la catégorie d'un jouet
  Future<void> modifierCategorie(
    String jouetId, {
    required String categorieId,
    required String nomCategorieDenormalise,
  }) async {
    await _jouetsCollection.doc(jouetId).set({
      'categorieId': categorieId,
      'nomCategorie': nomCategorieDenormalise,
      'nomCategorieDenormalise': nomCategorieDenormalise,
      'dateModification': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}