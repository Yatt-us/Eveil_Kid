import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/cloudinary/cloudinary_service.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/tutoriels/enums/tutoriel_status.enum.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/providers/cloudinary_duration_provider.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';

class TutorielFormController extends ChangeNotifier {
  final Ref ref;
  Tutoriel? initialTutoriel;

  final TextEditingController titreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ageMinController =
      TextEditingController(text: '3');
  final TextEditingController ageMaxController =
      TextEditingController(text: '10');

  String selectedCategorieId = '';
  List<String> selectedJouetsIds = [];

  // Media (Fichiers uniquement)
  File? selectedVideoFile;
  String? videoUrl;
  int duree = 0;

  File? selectedImage;
  String? imageUrl;

  // Statut
  TutorielStatus statut = TutorielStatus.publie;

  // Loading & State
  bool isLoading = false;
  bool isLoadingCategories = true;
  String? uploadStatusText;
  String? errorMessage;

  // Erreurs de champs
  String? titreError;
  String? descriptionError;
  String? categorieError;
  String? videoError;
  String? imageError;
  String? ageError;

  List<Categorie> categories = [];

  TutorielFormController(
    this.ref, {
    this.initialTutoriel,
  }) {
    if (initialTutoriel != null) {
      _loadExistingData();
    }
    _loadCategories();
  }

  void initFromTutoriel(Tutoriel tutoriel) {
    initialTutoriel = tutoriel;
    _loadExistingData();
    notifyListeners();
  }

  Future<void> _loadCategories() async {
    try {
      isLoadingCategories = true;
      notifyListeners();

      List<Categorie> result = [];
      try {
        result = await ref.read(categoriesAdminProvider.future);
      } catch (_) {
        result = await ref.read(categoriesProvider.future);
      }

      categories = result;
      isLoadingCategories = false;
      errorMessage = null;

      if (selectedCategorieId.isEmpty && categories.isNotEmpty) {
        selectedCategorieId = categories.first.categorieId;
      }
      notifyListeners();
    } catch (e) {
      isLoadingCategories = false;
      errorMessage = 'Erreur lors du chargement des catégories : $e';
      notifyListeners();
    }
  }

  void _loadExistingData() {
    final tutoriel = initialTutoriel!;
    titreController.text = tutoriel.titre;
    descriptionController.text = tutoriel.description;
    videoUrl = tutoriel.videoUrl;
    duree = tutoriel.duree;
    ageMinController.text = tutoriel.ageMinimum.toString();
    ageMaxController.text = tutoriel.ageMaximum.toString();
    selectedCategorieId = tutoriel.categorieId;
    selectedJouetsIds = List.from(tutoriel.jouetsSuggeres);
    imageUrl = tutoriel.miniatureUrl;
    statut = tutoriel.statut;
  }

  void updateCategorie(String categorieId) {
    selectedCategorieId = categorieId;
    categorieError = null;
    notifyListeners();
  }

  void setStatut(TutorielStatus newStatut) {
    statut = newStatut;
    notifyListeners();
  }

  void toggleJouet(String jouetId) {
    if (selectedJouetsIds.contains(jouetId)) {
      selectedJouetsIds.remove(jouetId);
    } else {
      selectedJouetsIds.add(jouetId);
    }
    notifyListeners();
  }

  void selectImage(File image) {
    selectedImage = image;
    imageError = null;
    notifyListeners();
  }

  void removeImage() {
    selectedImage = null;
    imageUrl = null;
    imageError = null;
    notifyListeners();
  }

  void selectVideoFile(File video) {
    selectedVideoFile = video;
    videoError = null;
    notifyListeners();
  }

  void removeVideoFile() {
    selectedVideoFile = null;
    videoUrl = null;
    duree = 0;
    videoError = null;
    notifyListeners();
  }

  void _clearErrors() {
    titreError = null;
    descriptionError = null;
    categorieError = null;
    videoError = null;
    imageError = null;
    ageError = null;
    errorMessage = null;
  }

  bool validateForm() {
    _clearErrors();
    bool isValid = true;

    if (titreController.text.trim().isEmpty) {
      titreError = 'Le titre est obligatoire';
      isValid = false;
    } else if (titreController.text.trim().length < 3) {
      titreError = 'Le titre doit contenir au moins 3 caractères';
      isValid = false;
    }

    if (descriptionController.text.trim().isEmpty) {
      descriptionError = 'La description est obligatoire';
      isValid = false;
    } else if (descriptionController.text.trim().length < 10) {
      descriptionError =
          'La description doit contenir au moins 10 caractères';
      isValid = false;
    }

    if (selectedCategorieId.isEmpty) {
      if (initialTutoriel != null && initialTutoriel!.categorieId.isNotEmpty) {
        selectedCategorieId = initialTutoriel!.categorieId;
      } else if (categories.isNotEmpty) {
        selectedCategorieId = categories.first.categorieId;
      } else {
        categorieError = 'Veuillez sélectionner une catégorie';
        isValid = false;
      }
    }

    final ageMin = int.tryParse(ageMinController.text.trim());
    final ageMax = int.tryParse(ageMaxController.text.trim());
    if (ageMin == null || ageMax == null || ageMin < 0 || ageMax < ageMin) {
      ageError = 'Tranche d\'âge invalide';
      isValid = false;
    }

    // Validation Vidéo (Fichier ou URL existante)
    if (selectedVideoFile == null && (videoUrl == null || videoUrl!.isEmpty)) {
      videoError = 'Veuillez sélectionner un fichier vidéo';
      isValid = false;
    }

    // Validation Miniature (Fichier ou URL existante)
    if (selectedImage == null && (imageUrl == null || imageUrl!.isEmpty)) {
      imageError = 'Veuillez ajouter une miniature';
      isValid = false;
    }

    if (!isValid) {
      errorMessage = 'Veuillez corriger les erreurs dans le formulaire ci-dessous';
    }

    notifyListeners();
    return isValid;
  }

  Tutoriel buildTutoriel({
    String? finalImageUrl,
    String? finalVideoUrl,
    int? finalDuree,
  }) {
    final ageMin = int.tryParse(ageMinController.text.trim()) ?? 3;
    final ageMax = int.tryParse(ageMaxController.text.trim()) ?? 10;

    return Tutoriel(
      tutorielId: initialTutoriel?.tutorielId,
      categorieId: selectedCategorieId,
      jouetLieId:
          selectedJouetsIds.isNotEmpty ? selectedJouetsIds.first : null,
      createurId: initialTutoriel?.createurId ?? 'admin',
      titre: titreController.text.trim(),
      description: descriptionController.text.trim(),
      jouetsSuggeres: selectedJouetsIds,
      videoUrl: finalVideoUrl ?? videoUrl ?? '',
      miniatureUrl: finalImageUrl ?? imageUrl ?? '',
      duree: finalDuree ?? duree,
      ageMinimum: ageMin,
      ageMaximum: ageMax,
      statut: statut,
      dateCreation: initialTutoriel?.dateCreation ?? DateTime.now(),
      dateModification: DateTime.now(),
    );
  }

  Future<bool> save() async {
    if (!validateForm()) return false;

    isLoading = true;
    errorMessage = null;
    uploadStatusText = 'Téléversement des médias...';
    notifyListeners();

    try {
      final repository = ref.read(tutorielRepositoryProvider);
      final existingId = initialTutoriel?.tutorielId;

      // 1. Upload de la miniature SI une nouvelle image est sélectionnée
      String finalMiniatureUrl = imageUrl ?? '';
      if (selectedImage != null) {
        uploadStatusText = 'Téléversement de la miniature...';
        notifyListeners();

        finalMiniatureUrl = await repository.uploadMiniatureDirect(
          selectedImage!,
          tutorielId: existingId,
        );
        imageUrl = finalMiniatureUrl;
      }

      // 2. Upload du fichier vidéo SI un nouveau fichier vidéo est sélectionné
      String finalVideoUrl = videoUrl ?? '';
      int finalDuree = duree;

      if (selectedVideoFile != null) {
        uploadStatusText =
            'Téléversement du fichier vidéo (cela peut prendre un instant)...';
        notifyListeners();

        finalVideoUrl = await repository.uploadVideoDirect(
          selectedVideoFile!,
          tutorielId: existingId,
        );
        videoUrl = finalVideoUrl;

        // Détection et stockage de la durée
        uploadStatusText = 'Calcul de la durée de la vidéo...';
        notifyListeners();
        final durationSec = await ref
            .read(cloudinaryServiceProvider)
            .getVideoDuration(finalVideoUrl);
        finalDuree = durationSec.round();
        duree = finalDuree;
      } else if (finalDuree <= 0 && finalVideoUrl.isNotEmpty) {
        final durationSec = await ref
            .read(cloudinaryServiceProvider)
            .getVideoDuration(finalVideoUrl);
        if (durationSec > 0) {
          finalDuree = durationSec.round();
          duree = finalDuree;
        }
      }

      // 3. Enregistrement dans Firestore
      uploadStatusText = 'Enregistrement dans la base de données...';
      notifyListeners();

      final tutorielToSave = buildTutoriel(
        finalImageUrl: finalMiniatureUrl,
        finalVideoUrl: finalVideoUrl,
        finalDuree: finalDuree,
      );

      if (initialTutoriel == null) {
        await repository.createTutoriel(tutorielToSave);
      } else {
        await repository.updateTutoriel(tutorielToSave);
      }

      // Invalidation des providers
      ref.invalidate(adminTutorielsProvider);
      ref.invalidate(tutorielsProvider);
      if (existingId != null && existingId.isNotEmpty) {
        ref.invalidate(tutorielByIdProvider(existingId));
        ref.invalidate(tutorielStreamByIdProvider(existingId));
      } else if (tutorielToSave.tutorielId != null && tutorielToSave.tutorielId!.isNotEmpty) {
        ref.invalidate(tutorielByIdProvider(tutorielToSave.tutorielId!));
        ref.invalidate(tutorielStreamByIdProvider(tutorielToSave.tutorielId!));
      }
      if (finalVideoUrl.isNotEmpty) {
        ref.invalidate(cloudinaryVideoDurationProvider(finalVideoUrl));
      }

      isLoading = false;
      uploadStatusText = null;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Erreur: $e';
      isLoading = false;
      uploadStatusText = null;
      notifyListeners();
      debugPrint('❌ Erreur lors de l\'enregistrement: $e');
      return false;
    }
  }

  void resetForm() {
    titreController.clear();
    descriptionController.clear();
    ageMinController.text = '3';
    ageMaxController.text = '10';
    selectedCategorieId =
        categories.isNotEmpty ? categories.first.categorieId : '';
    selectedJouetsIds = [];
    selectedImage = null;
    selectedVideoFile = null;
    imageUrl = null;
    videoUrl = null;
    duree = 0;
    statut = TutorielStatus.publie;
    _clearErrors();
    notifyListeners();
  }

  @override
  void dispose() {
    titreController.dispose();
    descriptionController.dispose();
    ageMinController.dispose();
    ageMaxController.dispose();
    super.dispose();
  }
}

final tutorielFormControllerProvider =
    Provider.family<TutorielFormController, Tutoriel?>(
  (ref, initialTutoriel) {
    return TutorielFormController(ref, initialTutoriel: initialTutoriel);
  },
);