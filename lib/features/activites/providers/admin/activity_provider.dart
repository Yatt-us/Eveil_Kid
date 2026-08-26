import 'dart:io';

import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:eveilkid/features/activites/repository/admin/activity_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================
// PROVIDER DU REPOSITORY
// ============================================================

final activityRepositoryProvider =
    Provider<ActivityRepository>((ref) {
  return ActivityRepository();
});


// ============================================================
// ACTIVITÉS PUBLIÉES
// ============================================================

final activitesProvider =
    FutureProvider<List<Activite>>((ref) async {
  final repository =
      ref.read(activityRepositoryProvider);

  return repository.getAllActivites();
});

// ============================================================
// TOUTES LES ACTIVITÉS - ADMIN
// ============================================================

final adminActivitesProvider =
    FutureProvider<List<Activite>>((ref) async {
  final repository =
      ref.read(activityRepositoryProvider);

  return repository.getAllActivitesForAdmin();
});

// ============================================================
// ACTIVITÉ PAR ID
// ============================================================

final activiteByIdProvider =
    FutureProvider.family<Activite?, String>(
  (ref, id) async {
    final repository =
        ref.read(activityRepositoryProvider);

    return repository.getActiviteById(id);
  },
);

// ============================================================
// ASYNC NOTIFIER
// ============================================================

class ActivityNotifier
    extends AsyncNotifier<Activite?> {
  late final ActivityRepository _repository;

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Future<Activite?> build() async {
    _repository =
        ref.read(activityRepositoryProvider);

    return null;
  }

  // ==========================================================
  // CRÉER UNE ACTIVITÉ
  // ==========================================================

   Future<Activite> createActivity(Activite activite) async {
    state = const AsyncValue.loading();

    try {
      final newActivite = await _repository.createActivite(activite);
      state = AsyncValue.data(newActivite);

      // Invalider les listes
      ref.invalidate(activitesProvider);
      ref.invalidate(adminActivitesProvider);

      return newActivite;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  // ==========================================================
  // MODIFIER UNE ACTIVITÉ
  // ==========================================================

  Future<Activite> updateActivity(Activite activite) async {
    state = const AsyncValue.loading();

    try {
      final updatedActivite = await _repository.updateActivite(activite);
      state = AsyncValue.data(updatedActivite);

      // Actualiser les listes
      ref.invalidate(activitesProvider);
      ref.invalidate(adminActivitesProvider);

      if (updatedActivite.id != null) {
        ref.invalidate(activiteByIdProvider(updatedActivite.id!));
      }

      return updatedActivite;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  // ==========================================================
  // SUPPRIMER UNE ACTIVITÉ
  // ==========================================================

Future<void> deleteActivity(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteActivite(id);
      state = const AsyncValue.data(null);
      
      // ✅ Forcer le rafraîchissement des providers
      ref.invalidate(adminActivitesProvider);
      ref.invalidate(activitesProvider);
      
      // ✅ Forcer un rebuild manuel
      ref.refresh(adminActivitesProvider);
      
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }


  // ==========================================================
  // PUBLIER UNE ACTIVITÉ
  // ==========================================================

  Future<void> publierActivity(
    String id,
  ) async {
    try {
      await _repository.publierActivite(id);

      // Les données ont changé
      ref.invalidate(activitesProvider);

      ref.invalidate(adminActivitesProvider);

      ref.invalidate(
        activiteByIdProvider(id),
      );
    } catch (e) {
      rethrow;
    }
  }

  
  Future<void> depublierActivity(
    String id,
  ) async {
    try {
      await _repository.depublierActivite(id);

      // Les données ont changé
      ref.invalidate(activitesProvider);

      ref.invalidate(adminActivitesProvider);

      ref.invalidate(
        activiteByIdProvider(id),
      );
    } catch (e) {
      rethrow;
    }
  }


  Future<String> uploadImage(
    String activityId,
    File imageFile,
  ) async {
    try {
      final imageUrl =
          await _repository.uploadImage(
        activityId,
        imageFile,
      );

      ref.invalidate(activitesProvider);

      ref.invalidate(adminActivitesProvider);

      ref.invalidate(
        activiteByIdProvider(activityId),
      );

      return imageUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reorderActivities(List<Activite> activities) async {
    try {
      await _repository.reorderActivities(activities);
      ref.invalidate(adminActivitesProvider);
      ref.invalidate(activitesProvider);
    } catch (e) {
      rethrow;
    }
  }
}


final activityNotifierProvider =
    AsyncNotifierProvider<
        ActivityNotifier,
        Activite?>(
  ActivityNotifier.new,
);