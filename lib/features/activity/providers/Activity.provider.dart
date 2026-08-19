import 'package:eveilkid/features/activity/models/Activite.model.dart';
import 'package:eveilkid/features/activity/enums/ActivityCategory.enum.dart';
import 'package:eveilkid/features/activity/enums/DifficultyLevel.enum.dart';
import 'package:eveilkid/features/activity/repository/activite.repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';



final activiteRepositoryProvider = Provider<ActiviteRepository>((ref) {
  return ActiviteRepository();
});


final activitesProvider = FutureProvider<List<Activite>>((ref) async {
  final repository = ref.read(activiteRepositoryProvider);
  return repository.getAllActivites();
});


final adminActivitesProvider = FutureProvider<List<Activite>>((ref) async {
  final repository = ref.read(activiteRepositoryProvider);
  return repository.getAllActivitesForAdmin();
});


final activiteByIdProvider = FutureProvider.family<Activite?, String>((ref, id) async {
  final repository = ref.read(activiteRepositoryProvider);
  return repository.getActiviteById(id);
});


final searchActivitesProvider = FutureProvider.family<List<Activite>, String>((ref, searchTerm) async {
  final repository = ref.read(activiteRepositoryProvider);
  return repository.searchActivites(searchTerm);
});


final filterByCategorieProvider = FutureProvider.family<List<Activite>, ActivityCategory>((ref, categorie) async {
  final repository = ref.read(activiteRepositoryProvider);
  return repository.filterByCategorie(categorie);
});


final filterByAgeProvider = FutureProvider.family<List<Activite>, int>((ref, age) async {
  final repository = ref.read(activiteRepositoryProvider);
  return repository.filterByAge(age);
});

final filterByDifficulteProvider = FutureProvider.family<List<Activite>, DifficultyLevel>((ref, difficulte) async {
  final repository = ref.read(activiteRepositoryProvider);
  return repository.filterByDifficulte(difficulte);
});


class ActiviteNotifier extends StateNotifier<AsyncValue<Activite?>> {
  final ActiviteRepository _repository;

  ActiviteNotifier(this._repository) : super(const AsyncValue.data(null));

 
  Future<void> createActivite(Activite activite) async {
    state = const AsyncValue.loading();
    try {
      final newActivite = await _repository.createActivite(activite);
      state = AsyncValue.data(newActivite);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateActivite(Activite activite) async {
    state = const AsyncValue.loading();
    try {
      final updatedActivite = await _repository.updateActivite(activite);
      state = AsyncValue.data(updatedActivite);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

 
  Future<void> deleteActivite(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteActivite(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

 
  Future<void> publishActivite(String id) async {
    try {
      await _repository.publishActivite(id);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }


  Future<void> unpublishActivite(String id) async {
    try {
      await _repository.unpublishActivite(id);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

final activiteNotifierProvider = StateNotifierProvider<ActiviteNotifier, AsyncValue<Activite?>>((ref) {
  final repository = ref.read(activiteRepositoryProvider);
  return ActiviteNotifier(repository);
});