// lib/features/parents/providers/parent_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eveilkid/features/auth/models/utilisateur.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import '../repository/parent_repository.dart';

final currentUserIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authProvider);
  if (authState.utilisateur?.utilisateurId.isNotEmpty == true) {
    return authState.utilisateur!.utilisateurId;
  }
  try {
    final authUser = FirebaseAuth.instance.currentUser;
    return authUser?.uid ?? '';
  } catch (_) {
    return '';
  }
});

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return ParentFirestoreRepository();
});

final parentProfileStreamProvider = StreamProvider<Utilisateur>((ref) {
  final repository = ref.watch(parentRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId.isEmpty) return Stream.value(const Utilisateur(utilisateurId: ''));
  return repository.watchParentProfile(userId);
});

final enfantsStreamProvider = StreamProvider<List<EnfantModel>>((ref) {
  final repository = ref.watch(parentRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId.isEmpty) return Stream.value([]);
  return repository.watchEnfants(userId);
});

final enfantSelectionneProvider = Provider<EnfantModel?>((ref) {
  return ref.watch(enfantNotifierProvider).enfantSelectionne;
});

final enfantParIdProvider = Provider.family<EnfantModel?, String>((
  ref,
  enfantId,
) {
  final enfants = ref.watch(enfantNotifierProvider).enfants;
  for (final enfant in enfants) {
    if (enfant.enfantId == enfantId) return enfant;
  }
  return null;
});

class ParentNotifier extends AsyncNotifier<Utilisateur> {
  @override
  Future<Utilisateur> build() async {
    final repository = ref.read(parentRepositoryProvider);
    final userId = ref.watch(currentUserIdProvider);
    if (userId.isEmpty) {
      return const Utilisateur(utilisateurId: '');
    }
    final parent = await repository.fetchParentProfile(userId);
    await ref.read(enfantNotifierProvider.notifier).chargerEnfants(userId);
    return parent;
  }

  Future<void> chargerProfil([String? id]) async {
    final String targetId = id ?? ref.read(currentUserIdProvider);
    if (targetId.isEmpty) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(parentRepositoryProvider);
      return await repository.fetchParentProfile(targetId);
    });
  }

  Future<void> updateParentProfile(Utilisateur updatedParent) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(parentRepositoryProvider);
      final saved = await repository.updateParentProfile(updatedParent);
      return saved;
    });
  }

  Future<void> ajouterEnfant(EnfantModel enfant) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId.isEmpty) return;
    final toAdd = enfant.copyWith(utilisateurId: userId);

    state = await AsyncValue.guard(() async {
      final repository = ref.read(parentRepositoryProvider);
      await repository.ajouterEnfant(toAdd);
      return await repository.fetchParentProfile(userId);
    });
  }

  Future<void> modifierEnfant(EnfantModel enfant) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId.isEmpty) return;

    state = await AsyncValue.guard(() async {
      final repository = ref.read(parentRepositoryProvider);
      await repository.modifierEnfant(enfant);
      return await repository.fetchParentProfile(userId);
    });
  }

  Future<void> supprimerEnfant(String enfantId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId.isEmpty) return;

    state = await AsyncValue.guard(() async {
      final repository = ref.read(parentRepositoryProvider);
      await repository.supprimerEnfant(enfantId, userId);
      return await repository.fetchParentProfile(userId);
    });
  }
}

final parentNotifierProvider =
    AsyncNotifierProvider<ParentNotifier, Utilisateur>(() {
      return ParentNotifier();
    });
