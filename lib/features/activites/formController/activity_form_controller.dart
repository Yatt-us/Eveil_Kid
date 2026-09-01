import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:eveilkid/features/ActivityCategorie/models/activity_category_model.dart';
import 'package:eveilkid/features/ActivityCategorie/providers/activity_category_provider.dart';
import 'package:eveilkid/features/activites/enums/publication_status.enum.dart';
import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';

class ActivityFormController extends ChangeNotifier {
  String? titreError;
  String? descriptionError;
  String? categorieError;
  String? dureeError;
  String? pointsError;
  final dynamic ref;
  final Activite? initialActivite;

  final TextEditingController titreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dureeController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();

  String selectedCategorieId = '';
  String selectedDifficulte = 'facile';
  PublicationStatus selectedStatut = PublicationStatus.brouillon;
  int ageMinimum = 3;
  int ageMaximum = 6;
  File? selectedImage;
  String? imageUrl;

  bool isLoading = false;
  String? errorMessage;

  List<ActiviteCategorie> categories = [];
  bool isLoadingCategories = true;

  ActivityFormController(
    this.ref, {
    this.initialActivite,
  }) {
    if (initialActivite != null) {
      _loadExistingData();
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      isLoadingCategories = true;
      notifyListeners();

      final result = await ref.read(categoriesActivesProvider.future);
      categories = result;
      isLoadingCategories = false;
      errorMessage = null;
      notifyListeners();

      if (selectedCategorieId.isEmpty && categories.isNotEmpty) {
        selectedCategorieId = categories.first.id ?? '';
        notifyListeners();
      }
    } catch (e) {
      isLoadingCategories = false;
      errorMessage = 'Erreur lors du chargement des catégories : $e';
      notifyListeners();
    }
  }

  void _loadExistingData() {
    final activite = initialActivite!;
    titreController.text = activite.titre;
    descriptionController.text = activite.description;
    dureeController.text = activite.dureeEnMinutes.toString();
    pointsController.text = activite.points.toString();
    selectedCategorieId = activite.categorieId;
    selectedDifficulte = activite.difficulte;
    selectedStatut = activite.statut;
    ageMinimum = activite.ageMinimum;
    ageMaximum = activite.ageMaximum;
    imageUrl = activite.imageUrl;
  }

  void resetForm() {
    titreController.clear();
    descriptionController.clear();
    dureeController.clear();
    pointsController.clear();

    selectedCategorieId = categories.isNotEmpty ? (categories.first.id ?? '') : '';
    selectedDifficulte = 'facile';
    selectedStatut = PublicationStatus.brouillon;
    ageMinimum = 3;
    ageMaximum = 6;

    selectedImage = null;
    imageUrl = null;
    errorMessage = null;

    notifyListeners();
  }

  void resetFormKeepImage() {
    titreController.clear();
    descriptionController.clear();
    dureeController.clear();
    pointsController.clear();

    selectedCategorieId = categories.isNotEmpty ? (categories.first.id ?? '') : '';
    selectedDifficulte = 'facile';
    selectedStatut = PublicationStatus.brouillon;
    ageMinimum = 3;
    ageMaximum = 6;

    errorMessage = null;
    notifyListeners();
  }

  void updateCategorie(String categorieId) {
    selectedCategorieId = categorieId;
    notifyListeners();
  }

  void updateDifficulte(String difficulte) {
    selectedDifficulte = difficulte;
    notifyListeners();
  }

  void updateStatut(PublicationStatus statut) {
    selectedStatut = statut;
    notifyListeners();
  }

  void updateAgeMinimum(int age) {
    if (age <= ageMaximum) {
      ageMinimum = age;
      notifyListeners();
    }
  }

  void updateAgeMaximum(int age) {
    if (age >= ageMinimum) {
      ageMaximum = age;
      notifyListeners();
    }
  }

  void selectImage(File image) {
    selectedImage = image;
    notifyListeners();
  }

  void removeImage() {
    selectedImage = null;
    imageUrl = null;
    notifyListeners();
  }

  bool validateForm() {
    titreError = null;
    descriptionError = null;
    categorieError = null;
    dureeError = null;
    pointsError = null;
    errorMessage = null;

    bool isValid = true;

    if (titreController.text.trim().isEmpty) {
      titreError = 'Veuillez saisir un titre';
      isValid = false;
    }

    if (descriptionController.text.trim().isEmpty) {
      descriptionError = 'Veuillez saisir une description';
      isValid = false;
    }

    if (selectedCategorieId.isEmpty) {
      categorieError = 'Veuillez sélectionner une catégorie';
      isValid = false;
    }

    if (dureeController.text.trim().isEmpty) {
      dureeError = 'Veuillez saisir une durée';
      isValid = false;
    } else {
      final duree = int.tryParse(dureeController.text.trim());
      if (duree == null || duree <= 0) {
        dureeError = 'La durée doit être un nombre supérieur à 0';
        isValid = false;
      }
    }

    if (pointsController.text.trim().isEmpty) {
      pointsError = 'Veuillez saisir les points';
      isValid = false;
    } else {
      final points = int.tryParse(pointsController.text.trim());
      if (points == null || points < 0) {
        pointsError = 'Les points doivent être un nombre valide (>= 0)';
        isValid = false;
      }
    }

    if (!isValid) {
      errorMessage = 'Veuillez corriger les erreurs ci-dessous';
    }

    notifyListeners();
    return isValid;
  }

  Activite buildActivite() {
    return Activite(
      id: initialActivite?.id,
      titre: titreController.text.trim(),
      description: descriptionController.text.trim(),
      categorieId: selectedCategorieId,
      difficulte: selectedDifficulte,
      ageMinimum: ageMinimum,
      ageMaximum: ageMaximum,
      dureeEnMinutes: int.tryParse(dureeController.text.trim()) ?? 5,
      points: int.tryParse(pointsController.text.trim()) ?? 0,
      imageUrl: imageUrl,
      dateCreation: initialActivite?.dateCreation ?? DateTime.now(),
      dateModification: DateTime.now(),
      statut: selectedStatut,
    );
  }

  Future<bool> save({bool resetAfterSave = true}) async {
    if (!validateForm()) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final notifier = ref.read(activityNotifierProvider.notifier);
      final activite = buildActivite();

      final Activite savedActivite;

      if (initialActivite == null) {
        savedActivite = await notifier.createActivity(activite);
        if (resetAfterSave) {
          resetForm();
        }
        debugPrint('✅ Activité créée avec succès: ${savedActivite.titre}');
      } else {
        savedActivite = await notifier.updateActivity(activite);
        if (resetAfterSave) {
          resetForm();
        } else {
          _updateAfterSave(savedActivite);
        }
        debugPrint('✅ Activité mise à jour avec succès: ${savedActivite.titre}');
      }

      // Upload de l'image si une nouvelle a été sélectionnée
      if (selectedImage != null && savedActivite.id != null) {
        try {
          final uploadedUrl = await notifier.uploadImage(
            savedActivite.id!,
            selectedImage!,
          );
          imageUrl = uploadedUrl;
          selectedImage = null;
          debugPrint('✅ Image uploadée avec succès');
        } catch (e) {
          debugPrint('⚠️ Erreur lors de l\'upload de l\'image: $e');
          errorMessage = 'Activité enregistrée mais erreur lors de l\'upload de l\'image: $e';
          notifyListeners();
        }
      }

      // Invalider les caches pour une mise à jour instantanée
      ref.invalidate(adminActivitesProvider);
      ref.invalidate(activitesProvider);
      if (savedActivite.id != null) {
        ref.invalidate(activiteByIdProvider(savedActivite.id!));
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      debugPrint('❌ Erreur lors de l\'enregistrement: $e');
      return false;
    }
  }

  void _updateAfterSave(Activite savedActivite) {
    titreController.text = savedActivite.titre;
    descriptionController.text = savedActivite.description;
    dureeController.text = savedActivite.dureeEnMinutes.toString();
    pointsController.text = savedActivite.points.toString();
    selectedCategorieId = savedActivite.categorieId;
    selectedDifficulte = savedActivite.difficulte;
    selectedStatut = savedActivite.statut;
    ageMinimum = savedActivite.ageMinimum;
    ageMaximum = savedActivite.ageMaximum;
    imageUrl = savedActivite.imageUrl;

    notifyListeners();
  }

  Future<void> reloadCategories() async {
    await _loadCategories();
  }

  @override
  void dispose() {
    titreController.dispose();
    descriptionController.dispose();
    dureeController.dispose();
    pointsController.dispose();
    super.dispose();
  }
}

final activityFormControllerProvider = ChangeNotifierProvider.family<ActivityFormController, Activite?>(
  (ref, initialActivite) {
    return ActivityFormController(
      ref,
      initialActivite: initialActivite,
    );
  },
);