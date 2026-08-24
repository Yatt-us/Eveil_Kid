// lib/features/parent/providers/parent_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/parent_model.dart';
import '../repository/parent_repository.dart';

final currentUserIdProvider = Provider<String>((ref) {
  try {
    final authUser = FirebaseAuth.instance.currentUser;
    return authUser?.uid ?? 'parent_default_id';
  } catch (_) {
    return 'parent_default_id';
  }
});

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return ParentFirestoreRepository();
});

final parentProfileStreamProvider = StreamProvider<UtilisateurModel>((ref) {
  final repository = ref.watch(parentRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return repository.watchParentProfile(userId);
});

final enfantsStreamProvider = StreamProvider<List<EnfantModel>>((ref) {
  final repository = ref.watch(parentRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return repository.watchEnfants(userId);
});

class ParentNotifier extends AsyncNotifier<UtilisateurModel> {
  @override
  Future<UtilisateurModel> build() async {
    final repository = ref.read(parentRepositoryProvider);
    final userId = ref.read(currentUserIdProvider);
    return await repository.fetchParentProfile(userId);
  }

  Future<void> chargerProfil([String? id]) async {
    final String targetId = id ?? ref.read(currentUserIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(parentRepositoryProvider);
      return await repository.fetchParentProfile(targetId);
    });
  }

  Future<void> updateParentProfile(UtilisateurModel updatedParent) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(parentRepositoryProvider);
      final saved = await repository.updateParentProfile(updatedParent);
      return saved;
    });
  }

  Future<void> ajouterEnfant(EnfantModel enfant) async {
    final userId = ref.read(currentUserIdProvider);
    final toAdd = enfant.copyWith(utilisateurId: userId);

    state = await AsyncValue.guard(() async {
      final repository = ref.read(parentRepositoryProvider);
      await repository.ajouterEnfant(toAdd);
      return await repository.fetchParentProfile(userId);
    });
  }

  Future<void> modifierEnfant(EnfantModel enfant) async {
    final userId = ref.read(currentUserIdProvider);

    state = await AsyncValue.guard(() async {
      final repository = ref.read(parentRepositoryProvider);
      await repository.modifierEnfant(enfant);
      return await repository.fetchParentProfile(userId);
    });
  }

  Future<void> supprimerEnfant(String enfantId) async {
    final userId = ref.read(currentUserIdProvider);

    state = await AsyncValue.guard(() async {
      final repository = ref.read(parentRepositoryProvider);
      await repository.supprimerEnfant(enfantId, userId);
      return await repository.fetchParentProfile(userId);
    });
  }
}

final parentNotifierProvider = AsyncNotifierProvider<ParentNotifier, UtilisateurModel>(() {
  return ParentNotifier();
});
