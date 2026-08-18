import 'package:eveilkid/features/auth/models/Avis.model.dart';
import 'package:eveilkid/features/auth/repository/Avis.repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';


// 1. PROVIDER DU REPOSITORY
final avisRepositoryProvider = Provider<AvisRepository>((ref) {
  return AvisRepository();
});

// 2. PROVIDER POUR RÉCUPÉRER TOUS LES AVIS
final avisProvider = FutureProvider<List<Avis>>((ref) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getAllAvis();
});

// 3. PROVIDER POUR RÉCUPÉRER LES AVIS VISIBLES SEULEMENT
final avisVisiblesProvider = FutureProvider<List<Avis>>((ref) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getAvisVisibles();
});

// 4. PROVIDER POUR RÉCUPÉRER LES AVIS D'UNE CIBLE (activité, tutoriel, jouet)
final avisByCibleProvider = FutureProvider.family<List<Avis>, ({String cibleId, String typeCible})>((ref, params) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getAvisByCible(params.cibleId, params.typeCible);
});

// 5. PROVIDER POUR RÉCUPÉRER UN AVIS PAR SON ID
final avisByIdProvider = FutureProvider.family<Avis?, String>((ref, id) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getAvisById(id);
});

// 6. PROVIDER POUR LA NOTE MOYENNE D'UNE CIBLE
final noteMoyenneProvider = FutureProvider.family<double, ({String cibleId, String typeCible})>((ref, params) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getNoteMoyenne(params.cibleId, params.typeCible);
});

// 7. PROVIDER POUR LE NOMBRE D'AVIS D'UNE CIBLE
final countAvisProvider = FutureProvider.family<int, ({String cibleId, String typeCible})>((ref, params) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.countAvisByCible(params.cibleId, params.typeCible);
});

// 8. PROVIDER POUR LES DERNIERS AVIS (avec limite)
final derniersAvisProvider = FutureProvider.family<List<Avis>, int>((ref, limit) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getDerniersAvis(limit: limit);
});

// 9. PROVIDER POUR RECHERCHER DES AVIS
final searchAvisProvider = FutureProvider.family<List<Avis>, String>((ref, searchTerm) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.searchAvis(searchTerm);
});

// 10. PROVIDER POUR FILTRER PAR NOTE MINIMALE
final filterAvisByNoteProvider = FutureProvider.family<List<Avis>, double>((ref, noteMinimale) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.filterByNote(noteMinimale);
});

// 11. NOTIFIER POUR GÉRER LES AVIS
class AvisNotifier extends StateNotifier<AsyncValue<Avis?>> {
  final AvisRepository _repository;

  AvisNotifier(this._repository) : super(const AsyncValue.data(null));

  // Créer un avis
  Future<void> createAvis(Avis avis) async {
    state = const AsyncValue.loading();
    try {
      final newAvis = await _repository.createAvis(avis);
      state = AsyncValue.data(newAvis);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Modifier un avis
  Future<void> updateAvis(Avis avis) async {
    state = const AsyncValue.loading();
    try {
      final updatedAvis = await _repository.updateAvis(avis);
      state = AsyncValue.data(updatedAvis);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Supprimer un avis
  Future<void> deleteAvis(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteAvis(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Masquer un avis
  Future<void> masquerAvis(String id) async {
    try {
      await _repository.masquerAvis(id);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Rendre visible un avis
  Future<void> rendreVisibleAvis(String id) async {
    try {
      await _repository.rendreVisibleAvis(id);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

// 12. PROVIDER DU NOTIFIER
final avisNotifierProvider = StateNotifierProvider<AvisNotifier, AsyncValue<Avis?>>((ref) {
  final repository = ref.read(avisRepositoryProvider);
  return AvisNotifier(repository);
});