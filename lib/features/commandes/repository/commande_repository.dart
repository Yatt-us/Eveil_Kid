import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/commande_model.dart';

class CommandeRepository {
  final FirebaseFirestore _firestore;

  CommandeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _collectionCommandes =>
      _firestore.collection('commandes');

  // 1. Récupérer toutes les commandes d'un parent
  Future<List<CommandeModel>> recupererCommandes(String parentId) async {
    try {
      QuerySnapshot instantane = await _collectionCommandes
          .where('parentId', isEqualTo: parentId)
          .orderBy('dateCreation', descending: true)
          .get();

      return instantane.docs
          .map((doc) =>
              CommandeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      try {
        // Fallback si l'index n'est pas encore prêt ou en cas d'erreur composite
        QuerySnapshot instantane = await _collectionCommandes
            .where('parentId', isEqualTo: parentId)
            .get();

        final list = instantane.docs
            .map((doc) => CommandeModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        // Tri manuel
        list.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        return list;
      } catch (e2) {
        throw Exception('Erreur lors de la récupération des commandes : $e2');
      }
    }
  }

  // 2. Récupérer une seule commande par son identifiant
  Future<CommandeModel?> recupererCommande(String commandeId) async {
    try {
      DocumentSnapshot doc = await _collectionCommandes.doc(commandeId).get();
      if (doc.exists) {
        return CommandeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la commande : $e');
    }
  }

  // 3. Créer une nouvelle commande
  Future<CommandeModel> creerCommande(CommandeModel commande) async {
    try {
      final docRef = (commande.id.isNotEmpty)
          ? _collectionCommandes.doc(commande.id)
          : _collectionCommandes.doc();

      final commandeFinale = commande.copyWith(
        id: docRef.id,
        statut: commande.statut.isEmpty ? 'En cours' : commande.statut,
        dateCreation: commande.dateCreation,
      );

      await docRef.set(commandeFinale.toMap());
      return commandeFinale;
    } catch (e) {
      throw Exception('Erreur lors de la création de la commande : $e');
    }
  }

  // 4. Annuler une commande
  Future<void> annulerCommande(String commandeId) async {
    try {
      await _collectionCommandes
          .doc(commandeId)
          .update({'statut': 'annulee'});
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de la commande : $e');
    }
  }

  // 5. Modifier le statut d'une commande
  Future<void> modifierStatutCommande(String commandeId, String statut) async {
    try {
      await _collectionCommandes.doc(commandeId).update({'statut': statut});
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut : $e');
    }
  }

  // 6. Récupérer toutes les commandes pour l'administration
  Future<List<CommandeModel>> recupererToutesLesCommandes() async {
    try {
      QuerySnapshot instantane = await _collectionCommandes
          .orderBy('dateCreation', descending: true)
          .get();

      return instantane.docs
          .map((doc) =>
              CommandeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      try {
        QuerySnapshot instantane = await _collectionCommandes.get();
        final list = instantane.docs
            .map((doc) =>
                CommandeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        list.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        return list;
      } catch (e2) {
        throw Exception('Erreur lors de la récupération des commandes : $e2');
      }
    }
  }

  // 7. Supprimer définitivement une commande
  Future<void> supprimerCommande(String commandeId) async {
    try {
      await _collectionCommandes.doc(commandeId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la commande : $e');
    }
  }
}