import 'package:flutter/material.dart';
import '../models/commande_model.dart';
import '../repository/commande_repository.dart';

class CommandeProvider extends ChangeNotifier {
  final CommandeRepository _depot = CommandeRepository();

  List<CommandeModel> _commandes = [];
  CommandeModel? _commandeSelectionnee;
  bool _estEnChargement = false;
  String? _messageErreur;

  List<CommandeModel> get commandes => _commandes;
  CommandeModel? get commandeSelectionnee => _commandeSelectionnee;
  bool get estEnChargement => _estEnChargement;
  String? get messageErreur => _messageErreur;

  // Charger les commandes d'un parent
  Future<void> chargerCommandes(String parentId) async {
    _definirChargement(true);
    try {
      _commandes = await _depot.recupererCommandes(parentId);
      _messageErreur = null;
    } catch (e) {
      _messageErreur = e.toString();
    } finally {
      _definirChargement(false);
    }
  }

  // Récupérer et afficher les détails d'une commande
  Future<void> chargerDetailCommande(String commandeId) async {
    _definirChargement(true);
    try {
      _commandeSelectionnee = await _depot.recupererCommande(commandeId);
      _messageErreur = null;
    } catch (e) {
      _messageErreur = e.toString();
    } finally {
      _definirChargement(false);
    }
  }

  // Créer une commande
  Future<bool> passerCommande(CommandeModel commande) async {
    _definirChargement(true);
    try {
      await _depot.creerCommande(commande);
      _commandes.insert(0, commande);
      _commandeSelectionnee = commande;
      _messageErreur = null;
      notifyListeners();
      return true;
    } catch (e) {
      _messageErreur = e.toString();
      return false;
    } finally {
      _definirChargement(false);
    }
  }

  // Annuler une commande
  Future<void> annulerCommande(String commandeId) async {
    _definirChargement(true);
    try {
      await _depot.annulerCommande(commandeId);
      int index = _commandes.indexWhere((c) => c.id == commandeId);
      if (index != -1) {
        _commandes[index] = _commandes[index].copyWith(statut: 'Annulée');
      }
      if (_commandeSelectionnee?.id == commandeId) {
        _commandeSelectionnee =
            _commandeSelectionnee?.copyWith(statut: 'Annulée');
      }
      _messageErreur = null;
    } catch (e) {
      _messageErreur = e.toString();
    } finally {
      _definirChargement(false);
    }
  }

  void _definirChargement(bool valeur) {
    _estEnChargement = valeur;
    notifyListeners();
  }
}