import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/activite_enums.dart';
import '../models/activite.dart';
import '../repository/activite_repository.dart';

/// Provider pour l'instance du repository
final activiteRepositoryProvider = Provider<ActiviteRepository>((ref) {
  return ActiviteRepository();
});

/// État de la liste des activités
class ActivitesState {
  final List<Activite> activites;
  final StatutActivite filtreStatut;
  final CategorieActivite? filtreCategorie;
  final String query;
  final bool isLoading;
  final String? errorMessage;

  const ActivitesState({
    this.activites = const [],
    this.filtreStatut = StatutActivite.toutes,
    this.filtreCategorie,
    this.query = '',
    this.isLoading = false,
    this.errorMessage,
  });

  /// Liste des activités après application des filtres et de la recherche
  List<Activite> get activitesFiltrees {
    return activites.where((act) {
      // Filtre par statut
      if (filtreStatut == StatutActivite.enCours && act.statut != StatutActivite.enCours) {
        return false;
      }
      if (filtreStatut == StatutActivite.terminees && act.statut != StatutActivite.terminees) {
        return false;
      }

      // Filtre par catégorie
      if (filtreCategorie != null && act.categorie != filtreCategorie) {
        return false;
      }

      // Filtre par terme de recherche
      if (query.isNotEmpty) {
        final q = query.toLowerCase().trim();
        final matchTitre = act.titre.toLowerCase().contains(q);
        final matchDesc = act.description.toLowerCase().contains(q);
        if (!matchTitre && !matchDesc) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  ActivitesState copyWith({
    List<Activite>? activites,
    StatutActivite? filtreStatut,
    CategorieActivite? filtreCategorie,
    bool clearCategorie = false,
    String? query,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ActivitesState(
      activites: activites ?? this.activites,
      filtreStatut: filtreStatut ?? this.filtreStatut,
      filtreCategorie: clearCategorie ? null : filtreCategorie ?? this.filtreCategorie,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier Riverpod pour la gestion de la liste des activités
class ActivitesNotifier extends Notifier<ActivitesState> {
  late final ActiviteRepository _repository;

  @override
  ActivitesState build() {
    _repository = ref.read(activiteRepositoryProvider);
    // Déclenchement asynchrone du chargement initial
    Future.microtask(() => chargerActivites());
    return const ActivitesState(isLoading: true);
  }

  /// Chargement des activités depuis Firestore
  Future<void> chargerActivites() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.getAllActivites();
      if (!ref.mounted) return;
      state = state.copyWith(
        activites: list,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger les activités : $e',
      );
    }
  }

  /// Changement du filtre de statut (Toutes, En cours, Terminées)
  void changerFiltreStatut(StatutActivite statut) {
    state = state.copyWith(filtreStatut: statut);
  }

  /// Changement ou désactivation du filtre par catégorie
  void changerFiltreCategorie(CategorieActivite? categorie) {
    if (categorie == null || state.filtreCategorie == categorie) {
      state = state.copyWith(clearCategorie: true);
    } else {
      state = state.copyWith(filtreCategorie: categorie);
    }
  }

  /// Recherche textuelle
  void rechercher(String text) {
    state = state.copyWith(query: text);
  }

  /// Mise à jour de la progression d'une activité locale
  void actualiserProgressionActivite(String activiteId, double progression, StatutActivite statut) {
    final updatedList = state.activites.map((act) {
      if (act.id == activiteId) {
        return act.copyWith(progression: progression, statut: statut);
      }
      return act;
    }).toList();

    state = state.copyWith(activites: updatedList);
    _repository.updateProgression(activiteId, progression, statut);
  }
}

/// Provider global pour la liste des activités
final activitesProvider = NotifierProvider<ActivitesNotifier, ActivitesState>(
  ActivitesNotifier.new,
);
