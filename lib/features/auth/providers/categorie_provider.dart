import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/auth/repository/categorie_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categorie.dart';




final categorieRepositoryProvider =
    Provider<CategorieRepository>((ref) {
  return CategorieRepository(
    FirebaseFirestore.instance,
  );
});

final categoriesProvider =
    FutureProvider<List<Categorie>>((ref) async {
  final repository =
      ref.read(categorieRepositoryProvider);

  return repository.getCategories();
});

final categorieByIdProvider =
    FutureProvider.family<Categorie?, String>(
  (ref, categorieId) async {
    final repository =
        ref.read(categorieRepositoryProvider);

    return repository.getCategorieById(categorieId);
  },
);

final categoriesPrincipalesProvider =
    FutureProvider<List<Categorie>>((ref) async {
  final repository =
      ref.read(categorieRepositoryProvider);

  return repository.getCategoriesPrincipales();
});


final sousCategoriesProvider =
    FutureProvider.family<List<Categorie>, String>(
  (ref, parentId) async {
    final repository =
        ref.read(categorieRepositoryProvider);

    return repository.getSousCategories(parentId);
  },
);

final rechercheCategoriesProvider =
    FutureProvider.family<List<Categorie>, String>(
  (ref, recherche) async {
    final repository =
        ref.read(categorieRepositoryProvider);

    return repository.searchCategories(recherche);
  },
);