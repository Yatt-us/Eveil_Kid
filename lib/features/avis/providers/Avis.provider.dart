import 'package:eveilkid/features/avis/models/Avis.model.dart';
import 'package:eveilkid/features/avis/repository/Avis.repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';


final avisRepositoryProvider = Provider<AvisRepository>((ref) {
  return AvisRepository();
});

final avisProvider = FutureProvider<List<Avis>>((ref) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getAllAvis();
});

final avisVisiblesProvider = FutureProvider<List<Avis>>((ref) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getAvisVisibles();
});

final avisByCibleProvider = FutureProvider.family<List<Avis>, ({String cibleId, String typeCible})>((ref, params) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getAvisByCible(params.cibleId, params.typeCible);
});

final avisByIdProvider = FutureProvider.family<Avis?, String>((ref, id) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getAvisById(id);
});

final noteMoyenneProvider = FutureProvider.family<double, ({String cibleId, String typeCible})>((ref, params) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getNoteMoyenne(params.cibleId, params.typeCible);
});

final countAvisProvider = FutureProvider.family<int, ({String cibleId, String typeCible})>((ref, params) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.countAvisByCible(params.cibleId, params.typeCible);
});

final derniersAvisProvider = FutureProvider.family<List<Avis>, int>((ref, limit) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getDerniersAvis(limit: limit);
});

final searchAvisProvider = FutureProvider.family<List<Avis>, String>((ref, searchTerm) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.searchAvis(searchTerm);
});

final filterAvisByNoteProvider = FutureProvider.family<List<Avis>, double>((ref, noteMinimale) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.filterByNote(noteMinimale);
});

class AvisNotifier extends StateNotifier<AsyncValue<Avis?>> {
  final AvisRepository _repository;

  AvisNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createAvis(Avis avis) async {
    state = const AsyncValue.loading();
    try {
      final newAvis = await _repository.createAvis(avis);
      state = AsyncValue.data(newAvis);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateAvis(Avis avis) async {
    state = const AsyncValue.loading();
    try {
      final updatedAvis = await _repository.updateAvis(avis);
      state = AsyncValue.data(updatedAvis);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteAvis(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteAvis(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> masquerAvis(String id) async {
    try {
      await _repository.masquerAvis(id);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> rendreVisibleAvis(String id) async {
    try {
      await _repository.rendreVisibleAvis(id);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

final avisNotifierProvider = StateNotifierProvider<AvisNotifier, AsyncValue<Avis?>>((ref) {
  final repository = ref.read(avisRepositoryProvider);
  return AvisNotifier(repository);
});