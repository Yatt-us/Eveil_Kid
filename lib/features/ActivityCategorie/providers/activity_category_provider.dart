import 'package:eveilkid/features/ActivityCategorie/repository/activity_category_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_category_model.dart';


// Provider du repository
final activiteCategorieRepositoryProvider = Provider<ActiviteCategorieRepository>((ref) {
  return ActiviteCategorieRepository();
});

// Provider pour les catégories actives
final categoriesActivesProvider = FutureProvider<List<ActiviteCategorie>>((ref) async {
  final repository = ref.read(activiteCategorieRepositoryProvider);
  return repository.getCategoriesActives();
});

// Provider pour toutes les catégories
final allCategoriesProvider = FutureProvider<List<ActiviteCategorie>>((ref) async {
  final repository = ref.read(activiteCategorieRepositoryProvider);
  return repository.getAllCategories();
});

// Provider pour une catégorie par ID
final categorieByIdProvider = FutureProvider.family<ActiviteCategorie?, String>((ref, id) async {
  final repository = ref.read(activiteCategorieRepositoryProvider);
  return repository.getCategorieById(id);
});

final categoriesMapProvider = FutureProvider<Map<String, String>>((ref) {
  final categories = ref.watch(categoriesActivesProvider);
  return categories.when(
    data: (data) {
      final map = <String, String>{};
      for (var category in data) {
        if (category.id != null) {
          map[category.id!] = category.nom;
        }
      }
      return map;
    },
    loading: () => <String, String>{},
    error: (_, _) => <String, String>{},
  );
});