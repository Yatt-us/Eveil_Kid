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
      final enfants = await _enfantRepository.recupererEnfantsDuParent(
        parentId,
      );
      final current = state.enfantSelectionne;
      final selection = current == null
          ? (enfants.isEmpty ? null : enfants.first)
          : enfants.where((e) => e.enfantId == current.enfantId).firstOrNull ??
                (enfants.isEmpty ? null : enfants.first);
      state = state.copyWith(
        enfants: enfants,
        enfantSelectionne: selection,
        forceNullSelection: selection == null,
      );
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Erreur lors du chargement : $error',
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

  void clearError() {
    state = state.copyWith(forceNullError: true);
  }
}
