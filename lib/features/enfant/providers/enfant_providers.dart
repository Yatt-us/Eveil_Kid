import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/repository/enfant_repository.dart';
import 'enfant_state.dart';

final enfantRepositoryProvider = Provider<EnfantRepository>((ref) {
  return EnfantRepository();
});

final enfantNotifierProvider = NotifierProvider<EnfantNotifier, EnfantState>(
  EnfantNotifier.new,
);

class EnfantNotifier extends Notifier<EnfantState> {
  late final EnfantRepository _enfantRepository;

  @override
  EnfantState build() {
    _enfantRepository = ref.watch(enfantRepositoryProvider);
    return const EnfantState();
  }

  Future<void> chargerEnfants(String parentId) async {
    if (parentId.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        forceNullSelection: true,
        forceNullError: true,
      );
      return;
    }

    state = state.copyWith(isLoading: true, forceNullError: true);

    try {
      final enfants = await _enfantRepository.recupererEnfantsDuParent(parentId);
      EnfantModel? selection = state.enfantSelectionne;

      if (selection == null && enfants.isNotEmpty) {
        selection = enfants.first;
      } else if (selection != null) {
        final index = enfants.indexWhere((e) => e.enfantId == selection!.enfantId);
        selection = index != -1 ? enfants[index] : (enfants.isNotEmpty ? enfants.first : null);
      }

      state = state.copyWith(
        enfants: enfants,
        enfantSelectionne: selection,
        forceNullSelection: selection == null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erreur lors du chargement des enfants : $e',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectionnerEnfant(EnfantModel enfant) {
    state = state.copyWith(enfantSelectionne: enfant);
  }

  void deselectionnerEnfant() {
    state = state.copyWith(forceNullSelection: true);
  }

  Future<bool> ajouterEnfant(EnfantModel enfant) async {
    state = state.copyWith(isLoading: true, forceNullError: true);

    try {
      await _enfantRepository.ajouterEnfant(
        parentId: enfant.utilisateurId,
        enfant: enfant,
      );

      final nouveauxEnfants = [...state.enfants, enfant];
      state = state.copyWith(
        enfants: nouveauxEnfants,
        enfantSelectionne: state.enfantSelectionne ?? enfant,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erreur lors de l\'ajout : $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> modifierEnfant(EnfantModel enfant) async {
    state = state.copyWith(isLoading: true, forceNullError: true);

    try {
      await _enfantRepository.modifierEnfant(
        parentId: enfant.utilisateurId,
        enfant: enfant,
      );

      final nouveauxEnfants = state.enfants.map((e) {
        return e.enfantId == enfant.enfantId ? enfant : e;
      }).toList();

      final selectionEstModifiee = state.enfantSelectionne?.enfantId == enfant.enfantId;
      state = state.copyWith(
        enfants: nouveauxEnfants,
        enfantSelectionne: selectionEstModifiee ? enfant : state.enfantSelectionne,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erreur lors de la modification : $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> supprimerEnfant({
    required String parentId,
    required String enfantId,
  }) async {
    state = state.copyWith(isLoading: true, forceNullError: true);

    try {
      await _enfantRepository.supprimerEnfant(parentId: parentId, enfantId: enfantId);
      final nouveauxEnfants = state.enfants.where((e) => e.enfantId != enfantId).toList();

      EnfantModel? nouvelleSelection = state.enfantSelectionne;
      if (state.enfantSelectionne?.enfantId == enfantId) {
        nouvelleSelection = nouveauxEnfants.isNotEmpty ? nouveauxEnfants.first : null;
      }

      state = state.copyWith(
        enfants: nouveauxEnfants,
        enfantSelectionne: nouvelleSelection,
        forceNullSelection: nouvelleSelection == null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erreur lors de la suppression : $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> mettreAJourPhoto({
    required String parentId,
    required String enfantId,
    required String photoUrl,
  }) async {
    state = state.copyWith(isLoading: true, forceNullError: true);

    try {
      await _enfantRepository.mettreAJourPhoto(
        parentId: parentId,
        enfantId: enfantId,
        photoUrl: photoUrl,
      );

      final nouveauxEnfants = state.enfants.map((e) {
        if (e.enfantId == enfantId) {
          return e.copyWith(
            avatarUrl: photoUrl,
            dateModification: DateTime.now(),
          );
        }
        return e;
      }).toList();

      final enfantMaj = nouveauxEnfants.firstWhere((e) => e.enfantId == enfantId);
      final selectionEstConcernee = state.enfantSelectionne?.enfantId == enfantId;

      state = state.copyWith(
        enfants: nouveauxEnfants,
        enfantSelectionne: selectionEstConcernee ? enfantMaj : state.enfantSelectionne,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erreur lors de la mise à jour de la photo : $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> ajouterEnfantLegacy({
    required String parentId,
    required EnfantModel enfant,
  }) async {
    return ajouterEnfant(enfant.copyWith(utilisateurId: parentId));
  }

  Future<bool> modifierEnfantLegacy({
    required String parentId,
    required EnfantModel enfant,
  }) async {
    return modifierEnfant(enfant.copyWith(utilisateurId: parentId));
  }

  Future<bool> supprimerEnfantLegacy({
    required String parentId,
    required String enfantId,
  }) async {
    return supprimerEnfant(parentId: parentId, enfantId: enfantId);
  }

  void clearError() {
    state = state.copyWith(forceNullError: true);
  }
}
