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
      throw Exception('Erreur lors de la récupération des commandes : $e');
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
  Future<void> creerCommande(CommandeModel commande) async {
    try {
      await _collectionCommandes.doc(commande.id).set(commande.toMap());
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
}