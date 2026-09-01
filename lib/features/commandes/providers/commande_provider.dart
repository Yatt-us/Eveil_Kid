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

// 2. Repository Provider
final commandeRepositoryProvider = Provider<CommandeRepository>((ref) {
  return CommandeRepository();
});

// 3. Le Provider global pour le client (commandeProvider)
final commandeProvider = NotifierProvider<CommandeNotifier, CommandeState>(() {
  return CommandeNotifier();
});

// 4. Provider d'administration pour la liste des commandes
final adminCommandesProvider = FutureProvider<List<CommandeModel>>((ref) async {
  final repository = ref.watch(commandeRepositoryProvider);
  return repository.recupererToutesLesCommandes();
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
  Future<CommandeModel?> passerCommande(CommandeModel commande) async {
    state = state.copyWith(estEnChargement: true, messageErreur: null);
    try {
      final commandeEnregistree = await _depot.creerCommande(commande);
      final nouvellesCommandes = [commandeEnregistree, ...state.commandes];
      state = state.copyWith(
        commandes: nouvellesCommandes,
        commandeSelectionnee: commandeEnregistree,
        estEnChargement: false,
      );
      return commandeEnregistree;
    } catch (e) {
      state = state.copyWith(messageErreur: e.toString(), estEnChargement: false);
      return null;
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