import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/jouets/repository/jouet_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/jouet.dart';

final jouetRepositoryProvider = Provider<JouetRepository>((ref) {
  return JouetRepository(
    FirebaseFirestore.instance,
  );
});


final jouetsProvider = FutureProvider<List<Jouet>>((ref) async {
  final repository = ref.read(jouetRepositoryProvider);

  return repository.getJouets();
});

final jouetByIdProvider = FutureProvider.family<Jouet?, String>((ref, jouetId) async {
  final repository = ref.read(jouetRepositoryProvider);

  return repository.getJouetById(jouetId);
});

final jouetsByCategorieProvider = FutureProvider.family<List<Jouet>, String>(
  (ref, categorieId) async {
    final repository = ref.read(jouetRepositoryProvider);

    return repository.getJouetsByCategorie(categorieId);
  },
);


final rechercheJouetsProvider =
    FutureProvider.family<List<Jouet>, String>(
  (ref, recherche) async {
    final repository = ref.read(jouetRepositoryProvider);

    return repository.searchJouets(recherche);
  },
);

/// Stream en temps réel de tous les jouets pour le catalogue admin
final jouetsAdminStreamProvider = StreamProvider<List<Jouet>>((ref) {
  final repository = ref.read(jouetRepositoryProvider);
  return repository.streamJouetsAdmin();
});

/// FutureProvider de tous les jouets pour l'admin
final jouetsAdminProvider = FutureProvider<List<Jouet>>((ref) async {
  final repository = ref.read(jouetRepositoryProvider);
  return repository.getAllJouetsAdmin();
});