import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/commande_model.dart';
import '../repository/commande_repository.dart';

// 1. Définition de l'état (State)
class CommandeState {
  final List<CommandeModel> commandes;
  final CommandeModel? commandeSelectionnee;
  final bool estEnChargement;
  final String? messageErreur;

  CommandeState({
    this.commandes = const [],
    this.commandeSelectionnee,
    this.estEnChargement = false,
    this.messageErreur,
  });

  CommandeState copyWith({
    List<CommandeModel>? commandes,
    CommandeModel? commandeSelectionnee,
    bool? estEnChargement,
    String? messageErreur,
  }) {
    return CommandeState(
      commandes: commandes ?? this.commandes,
      commandeSelectionnee: commandeSelectionnee ?? this.commandeSelectionnee,
      estEnChargement: estEnChargement ?? this.estEnChargement,
      messageErreur: messageErreur,
    );
  }
}

// 2. Le Provider global (c'est celui-ci qui s'appellera "commandeProvider")
final commandeProvider = NotifierProvider<CommandeNotifier, CommandeState>(() {
  return CommandeNotifier();
});

class CommandeNotifier extends Notifier<CommandeState> {
  final CommandeRepository _depot = CommandeRepository();

  @override
  CommandeState build() {
    return CommandeState();
  }

  // Charger les commandes d'un parent
  Future<void> chargerCommandes(String parentId) async {
    state = state.copyWith(estEnChargement: true, messageErreur: null);
    try {
      final commandes = await _depot.recupererCommandes(parentId);
      state = state.copyWith(commandes: commandes, estEnChargement: false);
    } catch (e) {
      state = state.copyWith(messageErreur: e.toString(), estEnChargement: false);
    }
  }

  // Récupérer et afficher les détails d'une commande
  Future<void> chargerDetailCommande(String commandeId) async {
    state = state.copyWith(estEnChargement: true, messageErreur: null);
    try {
      final commande = await _depot.recupererCommande(commandeId);
      state = state.copyWith(commandeSelectionnee: commande, estEnChargement: false);
    } catch (e) {
      state = state.copyWith(messageErreur: e.toString(), estEnChargement: false);
    }
  }

  // Créer une commande
  Future<bool> passerCommande(CommandeModel commande) async {
    state = state.copyWith(estEnChargement: true, messageErreur: null);
    try {
      await _depot.creerCommande(commande);
      final nouvellesCommandes = [commande, ...state.commandes];
      state = state.copyWith(
        commandes: nouvellesCommandes,
        commandeSelectionnee: commande,
        estEnChargement: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(messageErreur: e.toString(), estEnChargement: false);
      return false;
    }
  }

  // Annuler une commande
  Future<void> annulerCommande(String commandeId) async {
    state = state.copyWith(estEnChargement: true, messageErreur: null);
    try {
      await _depot.annulerCommande(commandeId);
      
      final commandesMisesAJour = state.commandes.map((c) {
        if (c.id == commandeId) {
          return c.copyWith(statut: 'Annulée');
        }
        return c;
      }).toList();

      CommandeModel? selectionMaj = state.commandeSelectionnee;
      if (selectionMaj?.id == commandeId) {
        selectionMaj = selectionMaj?.copyWith(statut: 'Annulée');
      }

      state = state.copyWith(
        commandes: commandesMisesAJour,
        commandeSelectionnee: selectionMaj,
        estEnChargement: false,
      );
    } catch (e) {
      state = state.copyWith(messageErreur: e.toString(), estEnChargement: false);
    }
  }
}