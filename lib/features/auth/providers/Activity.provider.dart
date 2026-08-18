import 'package:eveilkid/features/auth/models/Activite.model.dart';
import 'package:eveilkid/features/auth/models/enums/ActivityCategory.enum.dart';
import 'package:eveilkid/features/auth/models/enums/DifficultyLevel.enum.dart';
import 'package:eveilkid/features/auth/repository/activite.repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';


// 1. PROVIDER DU REPOSITORY (toujours le même)
final activiteRepositoryProvider = Provider<ActiviteRepository>((ref) {
  return ActiviteRepository();
});

// 2. PROVIDER POUR RÉCUPÉRER TOUTES LES ACTIVITÉS (pour les utilisateurs normaux)
final activitesProvider = FutureProvider<List<Activite>>((ref) async {
  final repository = ref.read(activiteRepositoryProvider);
  return repository.getAllActivites();
});

// 3. PROVIDER POUR RÉCUPÉRER TOUTES LES ACTIVITÉS (pour admin - voir même les brouillons)
final adminActivitesProvider = FutureProvider<List<Activite>>((ref) async {
  final repository = ref.read(activiteRepositoryProvider);
  return repository.getAllActivitesForAdmin();
});

// 4. PROVIDER POUR RÉCUPÉRER UNE ACTIVITÉ PAR SON ID
final activiteByIdProvider = FutureProvider.family<Activite?, String>((ref, id) async {
  final repository = ref.read(activiteRepositoryProvider);
  return repository.getActiviteById(id);
});

// 5. PROVIDER POUR RECHERCHER DES ACTIVITÉS
final searchActivitesProvider = FutureProvider.family<List<Activite>, String>((ref, searchTerm) async {
  final repository = ref.read(activiteRepositoryProvider);
  return repository.searchActivites(searchTerm);
});

// 6. PROVIDER POUR FILTRER PAR CATÉGORIE
final filterByCategorieProvider = FutureProvider.family<List<Activite>, ActivityCategory>((ref, categorie) async {
  final repository = ref.read(activiteRepositoryProvider);
  return repository.filterByCategorie(categorie);
});

// 7. PROVIDER POUR FILTRER PAR ÂGE
final filterByAgeProvider = FutureProvider.family<List<Activite>, int>((ref, age) async {
  final repository = ref.read(activiteRepositoryProvider);
  return repository.filterByAge(age);
});

// 8. PROVIDER POUR FILTRER PAR DIFFICULTÉ
final filterByDifficulteProvider = FutureProvider.family<List<Activite>, DifficultyLevel>((ref, difficulte) async {
  final repository = ref.read(activiteRepositoryProvider);
  return repository.filterByDifficulte(difficulte);
});

// 9. NOTIFIER POUR GÉRER LES OPÉRATIONS (créer, modifier, supprimer, publier, dépublier)
class ActiviteNotifier extends StateNotifier<AsyncValue<Activite?>> {
  final ActiviteRepository _repository;

  ActiviteNotifier(this._repository) : super(const AsyncValue.data(null));

  // Créer une activité
  Future<void> createActivite(Activite activite) async {
    state = const AsyncValue.loading();
    try {
      final newActivite = await _repository.createActivite(activite);
      state = AsyncValue.data(newActivite);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Modifier une activité
  Future<void> updateActivite(Activite activite) async {
    state = const AsyncValue.loading();
    try {
      final updatedActivite = await _repository.updateActivite(activite);
      state = AsyncValue.data(updatedActivite);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Supprimer une activité
  Future<void> deleteActivite(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteActivite(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Publier une activité
  Future<void> publishActivite(String id) async {
    try {
      await _repository.publishActivite(id);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Dépublier une activité
  Future<void> unpublishActivite(String id) async {
    try {
      await _repository.unpublishActivite(id);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

// 10. PROVIDER DU NOTIFIER
final activiteNotifierProvider = StateNotifierProvider<ActiviteNotifier, AsyncValue<Activite?>>((ref) {
  final repository = ref.read(activiteRepositoryProvider);
  return ActiviteNotifier(repository);
});