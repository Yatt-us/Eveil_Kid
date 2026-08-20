// lib/features/avis/providers/Avis.provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/Avis.model.dart';
import '../repository/Avis.repository.dart';

final avisRepositoryProvider = Provider<AvisRepository>((ref) {
  return AvisRepository();
});

final avisStreamProvider = StreamProvider<List<Avis>>((ref) {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getAvisStream();
});

final avisByJouetStreamProvider = StreamProvider.family<List<Avis>, String>((ref, jouetId) {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getAvisByJouetStream(jouetId);
});

final avisByUtilisateurStreamProvider = StreamProvider.family<List<Avis>, String>((ref, utilisateurId) {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getAvisByUtilisateurStream(utilisateurId);
});

final avisSignalesProvider = FutureProvider<List<Avis>>((ref) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getAvisSignales();
});

final statsAvisProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, jouetId) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.getStatistiquesAvis(jouetId);
});

final filterAvisByNoteProvider = FutureProvider.family<List<Avis>, double>((ref, noteMinimale) async {
  final repository = ref.read(avisRepositoryProvider);
  return repository.filterByNote(noteMinimale);
});

class AvisNotifier extends AsyncNotifier<Avis?> {
  @override
  Future<Avis?> build() async {
    return null;
  }

  Future<void> createAvis(Avis avis) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(avisRepositoryProvider);
      return await repository.createAvis(avis);
    });
  }

  Future<void> updateAvis(Avis avis) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(avisRepositoryProvider);
      return await repository.updateAvis(avis);
    });
  }

  Future<void> deleteAvis(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(avisRepositoryProvider);
      await repository.deleteAvis(id);
      return null;
    });
  }

  Future<void> masquerAvis(String id) async {
    final repository = ref.read(avisRepositoryProvider);
    await repository.masquerAvis(id);
  }

  Future<void> rendreVisibleAvis(String id) async {
    final repository = ref.read(avisRepositoryProvider);
    await repository.rendreVisibleAvis(id);
  }
}

final avisNotifierProvider = AsyncNotifierProvider<AvisNotifier, Avis?>(AvisNotifier.new);