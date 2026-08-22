import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/categories/repository/categorie_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categorie.dart';

final categorieRepositoryProvider = Provider<CategorieRepository>((ref) {
  return CategorieRepository(FirebaseFirestore.instance);
});

final categoriesProvider = FutureProvider<List<Categorie>>((ref) async {
  final repository = ref.read(categorieRepositoryProvider);

  return repository.getCategories();
});

final categorieByIdProvider = FutureProvider.family<Categorie?, String>((
  ref,
  categorieId,
) async {
  final repository = ref.read(categorieRepositoryProvider);

  return repository.getCategorieById(categorieId);
});

final categoriesPrincipalesProvider = FutureProvider<List<Categorie>>((
  ref,
) async {
  final repository = ref.read(categorieRepositoryProvider);

  return repository.getCategoriesPrincipales();
});

final sousCategoriesProvider = FutureProvider.family<List<Categorie>, String>((
  ref,
  parentId,
) async {
  final repository = ref.read(categorieRepositoryProvider);

  return repository.getSousCategories(parentId);
});

final rechercheCategoriesProvider =
    FutureProvider.family<List<Categorie>, String>((ref, recherche) async {
      final repository = ref.read(categorieRepositoryProvider);

      return repository.searchCategories(recherche);
    });

/// Stream en temps réel de toutes les catégories (actives et inactives)
final categoriesAdminStreamProvider = StreamProvider<List<Categorie>>((ref) {
  final repository = ref.read(categorieRepositoryProvider);
  return repository.streamCategoriesAdmin();
});

/// FutureProvider de toutes les catégories pour l'admin
final categoriesAdminProvider = FutureProvider<List<Categorie>>((ref) async {
  final repository = ref.read(categorieRepositoryProvider);
  return repository.getAllCategoriesAdmin();
});
