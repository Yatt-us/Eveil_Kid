import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/parent_model.dart';
// Note : Assurez-vous d'importer EnfantModel si défini dans un autre fichier
import '../repository/parent_repository.dart';

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return ParentRepositoryImpl();
});

class ParentNotifier extends AsyncNotifier<ParentModel> {

  @override
  Future<ParentModel> build() async {
    // Initialisation : on charge un profil par défaut pour le développement
    final repository = ref.read(parentRepositoryProvider);
    return await repository.fetchParentProfile('default_parent_id');
  }

  // Charger le profil du parent connecté
  Future<void> chargerProfil(String parentId) async {
    // Met automatiquement l'état en AsyncLoading
    state = const AsyncLoading();

    // state = await AsyncValue.guard(...) gère automatiquement le try/catch,
    // la capture des erreurs et du stackTrace.
    state = await AsyncValue.guard(() async {
      final repository = ref.read(parentRepositoryProvider);
      return await repository.fetchParentProfile(parentId);
    });
  }

  // Ajouter un enfant et mettre à jour l'état de manière réactive
  Future<void> ajouterEnfant(String parentId, EnfantModel enfant) async {
    final currentState = state;

    // Vérifie si on a déjà des données valides à modifier
    if (currentState is AsyncData<ParentModel>) {
      final parentActuel = currentState.value;

      // Basculer en mode chargement tout en conservant les données actuelles
      state = AsyncLoading<ParentModel>().copyWithPrevious(currentState);

      state = await AsyncValue.guard(() async {
        final repository = ref.read(parentRepositoryProvider);
        await repository.ajouterEnfant(parentId, enfant);

        // Crée la nouvelle liste et retourne le parent mis à jour
        final enfantsAjour = [...parentActuel.enfants, enfant];
        return parentActuel.copyWith(enfants: enfantsAjour);
      });
    }
  }
}

// 3. Provider de l'état du Parent lié au AsyncNotifier
final parentNotifierProvider = AsyncNotifierProvider<ParentNotifier, ParentModel>(() {
  return ParentNotifier();
});
