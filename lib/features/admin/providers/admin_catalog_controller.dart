import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';

enum AdminStockFilter { all, inStock, lowStock, outOfStock }

enum AdminActiveFilter { all, activeOnly, inactiveOnly }

enum AdminProductSort { recent, priceAsc, priceDesc, stockAsc, stockDesc, popular, name }

class AdminProductFilterState {
  final String searchQuery;
  final String? selectedCategoryId;
  final AdminStockFilter stockFilter;
  final AdminActiveFilter activeFilter;
  final bool popularOnly;
  final AdminProductSort sortBy;

  const AdminProductFilterState({
    this.searchQuery = '',
    this.selectedCategoryId,
    this.stockFilter = AdminStockFilter.all,
    this.activeFilter = AdminActiveFilter.activeOnly,
    this.popularOnly = false,
    this.sortBy = AdminProductSort.recent,
  });

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedCategoryId != null ||
      stockFilter != AdminStockFilter.all ||
      popularOnly;

  AdminProductFilterState copyWith({
    String? searchQuery,
    String? selectedCategoryId,
    bool clearCategory = false,
    AdminStockFilter? stockFilter,
    AdminActiveFilter? activeFilter,
    bool? popularOnly,
    AdminProductSort? sortBy,
  }) {
    return AdminProductFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      stockFilter: stockFilter ?? this.stockFilter,
      activeFilter: activeFilter ?? this.activeFilter,
      popularOnly: popularOnly ?? this.popularOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class AdminProductFilterNotifier extends Notifier<AdminProductFilterState> {
  @override
  AdminProductFilterState build() {
    return const AdminProductFilterState();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
  }

  void setStockFilter(AdminStockFilter filter) {
    state = state.copyWith(stockFilter: filter);
  }

  void setActiveFilter(AdminActiveFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void setPopularOnly(bool popularOnly) {
    state = state.copyWith(popularOnly: popularOnly);
  }

  void setSortBy(AdminProductSort sort) {
    state = state.copyWith(sortBy: sort);
  }

  void resetFilters() {
    state = const AdminProductFilterState();
  }
}

final adminProductFilterProvider =
    NotifierProvider<AdminProductFilterNotifier, AdminProductFilterState>(
  AdminProductFilterNotifier.new,
);

/// Provider des produits filtrés et triés pour le manager
final adminFilteredProductsProvider = Provider<AsyncValue<List<Jouet>>>((ref) {
  final productsAsync = ref.watch(jouetsAdminStreamProvider);
  final filter = ref.watch(adminProductFilterProvider);

  return productsAsync.whenData((products) {
    var filtered = products.where((item) {
      // Filtre recherche textuelle
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase().trim();
        final matchNom = item.nom.toLowerCase().contains(query);
        final matchDesc = item.description.toLowerCase().contains(query);
        final matchCat = item.nomCategorieDenormalise.toLowerCase().contains(query);
        if (!matchNom && !matchDesc && !matchCat) return false;
      }

      // Filtre catégorie
      if (filter.selectedCategoryId != null &&
          filter.selectedCategoryId!.isNotEmpty &&
          item.categorieId != filter.selectedCategoryId) {
        return false;
      }

      // Filtre stock
      switch (filter.stockFilter) {
        case AdminStockFilter.inStock:
          if (item.stockDisponible <= 0) return false;
          break;
        case AdminStockFilter.lowStock:
          if (item.stockDisponible <= 0 || item.stockDisponible > 5) return false;
          break;
        case AdminStockFilter.outOfStock:
          if (item.stockDisponible > 0) return false;
          break;
        case AdminStockFilter.all:
          break;
      }

      // Filtre statut actif
      switch (filter.activeFilter) {
        case AdminActiveFilter.activeOnly:
          if (!item.estActif) return false;
          break;
        case AdminActiveFilter.inactiveOnly:
          if (item.estActif) return false;
          break;
        case AdminActiveFilter.all:
          break;
      }

      // Filtre populaire
      if (filter.popularOnly && !item.estPopulaire) {
        return false;
      }

      return true;
    }).toList();

    // Tri
    switch (filter.sortBy) {
      case AdminProductSort.recent:
        filtered.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        break;
      case AdminProductSort.priceAsc:
        filtered.sort((a, b) => a.prix.compareTo(b.prix));
        break;
      case AdminProductSort.priceDesc:
        filtered.sort((a, b) => b.prix.compareTo(a.prix));
        break;
      case AdminProductSort.stockAsc:
        filtered.sort((a, b) => a.stockDisponible.compareTo(b.stockDisponible));
        break;
      case AdminProductSort.stockDesc:
        filtered.sort((a, b) => b.stockDisponible.compareTo(a.stockDisponible));
        break;
      case AdminProductSort.popular:
        filtered.sort((a, b) => (b.estPopulaire ? 1 : 0).compareTo(a.estPopulaire ? 1 : 0));
        break;
      case AdminProductSort.name:
        filtered.sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
        break;
    }

    return filtered;
  });
});

/// Statistiques catalogue pour le manager
class AdminCatalogStats {
  final int totalProducts;
  final int activeProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  final int popularProducts;
  final int totalCategories;

  const AdminCatalogStats({
    this.totalProducts = 0,
    this.activeProducts = 0,
    this.lowStockProducts = 0,
    this.outOfStockProducts = 0,
    this.popularProducts = 0,
    this.totalCategories = 0,
  });
}

final adminCatalogStatsProvider = Provider<AdminCatalogStats>((ref) {
  final products = ref.watch(jouetsAdminStreamProvider).value ?? [];
  final categories = ref.watch(categoriesAdminStreamProvider).value ?? [];

  int active = 0;
  int lowStock = 0;
  int outOfStock = 0;
  int popular = 0;

  for (final p in products) {
    if (p.estActif) active++;
    if (p.stockDisponible <= 0) {
      outOfStock++;
    } else if (p.stockDisponible <= 5) {
      lowStock++;
    }
    if (p.estPopulaire) popular++;
  }

  return AdminCatalogStats(
    totalProducts: products.length,
    activeProducts: active,
    lowStockProducts: lowStock,
    outOfStockProducts: outOfStock,
    popularProducts: popular,
    totalCategories: categories.length,
  );
});
