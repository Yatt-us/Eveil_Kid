import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/repository/enfant_repository.dart';
import 'package:flutter/material.dart';

/// Provider responsable de la gestion de l'état des enfants.
///
/// Il fait le lien entre :
/// - l'interface Flutter
/// - le Repository
/// - les données des enfants
class EnfantProvider extends ChangeNotifier {
  // ============================================================
  // REPOSITORY
  // ============================================================

  /// Repository utilisé pour communiquer avec Firebase.
  final EnfantRepository _enfantRepository;

  /// Constructeur du Provider.
  EnfantProvider(this._enfantRepository);

  // ============================================================
  // ÉTATS PRIVÉS
  // ============================================================

  /// Liste de tous les enfants du parent connecté.
  final List<EnfantModel> _enfants = [];

  /// Enfant actuellement sélectionné.
  EnfantModel? _enfantSelectionne;

  /// Indique si une opération est en cours.
  bool _isLoading = false;

  /// Contient le message d'erreur s'il y en a un.
  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  /// Retourne la liste des enfants.
  ///
  /// List.unmodifiable empêche l'interface de modifier
  /// directement la liste.
  List<EnfantModel> get enfants => List.unmodifiable(_enfants);

  /// Retourne l'enfant actuellement sélectionné.
  EnfantModel? get enfantSelectionne => _enfantSelectionne;

  /// Retourne true lorsqu'une opération est en cours.
  bool get isLoading => _isLoading;

  /// Retourne le message d'erreur.
  String? get errorMessage => _errorMessage;

  // ============================================================
  // CHARGER LES ENFANTS DU PARENT
  // ============================================================

  Future<void> chargerEnfants(String parentId) async {
    try {
      // On indique que le chargement commence.
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      // On demande au Repository de récupérer
      // les enfants du parent.
      final List<EnfantModel> enfants =
          await _enfantRepository.recupererEnfantsDuParent(parentId);

      // On vide l'ancienne liste.
      _enfants.clear();

      // On ajoute les nouveaux enfants.
      _enfants.addAll(enfants);

      // Si aucun enfant n'est sélectionné
      // et que la liste contient au moins un enfant,
      // on sélectionne automatiquement le premier.
      if (_enfantSelectionne == null && _enfants.isNotEmpty) {
        _enfantSelectionne = _enfants.first;
      }

      // Si l'enfant sélectionné n'existe plus dans la liste,
      // on sélectionne le premier enfant disponible.
      if (_enfantSelectionne != null &&
          !_enfants.any(
            (enfant) =>
                enfant.enfantId == _enfantSelectionne!.enfantId,
          )) {
        _enfantSelectionne =
            _enfants.isNotEmpty ? _enfants.first : null;
      }
    } catch (e) {
      // En cas d'erreur, on sauvegarde le message.
      _errorMessage =
          'Erreur lors du chargement des enfants : $e';
    } finally {
      // Le chargement est terminé.
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // RÉCUPÉRER UN ENFANT
  // ============================================================

  Future<EnfantModel?> recupererEnfant(String enfantId) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      // Demande au Repository de récupérer l'enfant.
      final EnfantModel? enfant =
          await _enfantRepository.recupererEnfant(enfantId);

      return enfant;
    } catch (e) {
      _errorMessage =
          'Erreur lors de la récupération de l\'enfant : $e';

      return null;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // SÉLECTIONNER UN ENFANT
  // ============================================================

  void selectionnerEnfant(EnfantModel enfant) {
    // On sauvegarde l'enfant choisi.
    _enfantSelectionne = enfant;

    // Informe l'interface que l'état a changé.
    notifyListeners();
  }

  // ============================================================
  // DÉSÉLECTIONNER L'ENFANT
  // ============================================================

  void deselectionnerEnfant() {
    // On supprime l'enfant actuellement sélectionné.
    _enfantSelectionne = null;

    notifyListeners();
  }

  // ============================================================
  // AJOUTER UN ENFANT
  // ============================================================

  Future<bool> ajouterEnfant(EnfantModel enfant) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      // Enregistrement de l'enfant dans Firebase.
      await _enfantRepository.ajouterEnfant(enfant);

      // Ajout de l'enfant dans la liste locale.
      _enfants.add(enfant);

      // Si aucun enfant n'est sélectionné,
      // on sélectionne automatiquement le nouvel enfant.
      if (_enfantSelectionne == null) {
        _enfantSelectionne = enfant;
      }

      return true;
    } catch (e) {
      _errorMessage =
          'Erreur lors de l\'ajout de l\'enfant : $e';

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // MODIFIER UN ENFANT
  // ============================================================

  Future<bool> modifierEnfant(EnfantModel enfant) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      // Modification dans Firebase.
      await _enfantRepository.modifierEnfant(enfant);

      // Recherche de l'enfant dans la liste locale.
      final int index = _enfants.indexWhere(
        (element) => element.enfantId == enfant.enfantId,
      );

      // Si l'enfant existe dans la liste,
      // on remplace l'ancienne version par la nouvelle.
      if (index != -1) {
        _enfants[index] = enfant;
      }

      // Si c'est l'enfant actuellement sélectionné,
      // on met également à jour la sélection.
      if (_enfantSelectionne?.enfantId == enfant.enfantId) {
        _enfantSelectionne = enfant;
      }

      return true;
    } catch (e) {
      _errorMessage =
          'Erreur lors de la modification de l\'enfant : $e';

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // SUPPRIMER UN ENFANT
  // ============================================================

  Future<bool> supprimerEnfant(String enfantId) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      // Suppression dans Firebase.
      await _enfantRepository.supprimerEnfant(enfantId);

      // Suppression dans la liste locale.
      _enfants.removeWhere(
        (enfant) => enfant.enfantId == enfantId,
      );

      // Si l'enfant supprimé était sélectionné,
      // on sélectionne un autre enfant.
      if (_enfantSelectionne?.enfantId == enfantId) {
        if (_enfants.isNotEmpty) {
          _enfantSelectionne = _enfants.first;
        } else {
          _enfantSelectionne = null;
        }
      }

      return true;
    } catch (e) {
      _errorMessage =
          'Erreur lors de la suppression de l\'enfant : $e';

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // METTRE À JOUR LA PHOTO
  // ============================================================

  Future<bool> mettreAJourPhoto(
    String enfantId,
    String photoUrl,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      // Modification de la photo dans Firebase.
      await _enfantRepository.mettreAJourPhoto(
        enfantId,
        photoUrl,
      );

      // Recherche de l'enfant dans la liste.
      final int index = _enfants.indexWhere(
        (enfant) => enfant.enfantId == enfantId,
      );

      if (index != -1) {
        // Création d'une nouvelle version de l'enfant
        // avec la nouvelle photo.
        final EnfantModel enfantModifie =
            _enfants[index].copyWith(
          avatarUrl: photoUrl,
          dateModification: DateTime.now(),
        );

        // Remplacement dans la liste.
        _enfants[index] = enfantModifie;

        // Si c'est l'enfant sélectionné,
        // on met également à jour sa photo.
        if (_enfantSelectionne?.enfantId == enfantId) {
          _enfantSelectionne = enfantModifie;
        }
      }

      return true;
    } catch (e) {
      _errorMessage =
          'Erreur lors de la mise à jour de la photo : $e';

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // EFFACER LE MESSAGE D'ERREUR
  // ============================================================

  void clearError() {
    // On supprime le message d'erreur.
    _errorMessage = null;

    notifyListeners();
  }
}