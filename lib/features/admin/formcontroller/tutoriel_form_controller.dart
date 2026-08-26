import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/tutoriels/enums/tutoriel_status.enum.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';

enum VideoSourceType { file, url }

class TutorielFormController extends ChangeNotifier {
  final Ref ref;
  final Tutoriel? initialTutoriel;

  final TextEditingController titreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dureeController = TextEditingController();
  final TextEditingController videoUrlController = TextEditingController();
  final TextEditingController ageMinController = TextEditingController(text: '3');
  final TextEditingController ageMaxController = TextEditingController(text: '10');

  String selectedCategorieId = '';
  List<String> selectedJouetsIds = [];

  // Media
  VideoSourceType videoSourceType = VideoSourceType.url;
  File? selectedVideoFile;
  String? videoUrl;

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
  String? dureeError;
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

  Future<void> _loadCategories() async {
    try {
      isLoadingCategories = true;
      notifyListeners();

      final result = await ref.read(categoriesProvider.future);
      categories = result.where((c) => c.estActive).toList();

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
    dureeController.text = _formatDuree(tutoriel.duree);
    videoUrlController.text = tutoriel.videoUrl;
    videoUrl = tutoriel.videoUrl;
    ageMinController.text = tutoriel.ageMinimum.toString();
    ageMaxController.text = tutoriel.ageMaximum.toString();
    selectedCategorieId = tutoriel.categorieId;
    selectedJouetsIds = List.from(tutoriel.jouetsSuggeres);
    imageUrl = tutoriel.miniatureUrl;
    statut = tutoriel.statut;
    videoSourceType = (tutoriel.videoUrl.contains('res.cloudinary.com') ||
            tutoriel.videoUrl.endsWith('.mp4'))
        ? VideoSourceType.file
        : VideoSourceType.url;
  }

  String _formatDuree(int dureeEnSecondes) {
    final minutes = dureeEnSecondes ~/ 60;
    final secondes = dureeEnSecondes % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secondes.toString().padLeft(2, '0')}';
  }

  int _parseDuree(String duree) {
    final parts = duree.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final secondes = int.tryParse(parts[1]) ?? 0;
      return minutes * 60 + secondes;
    }
    final directSeconds = int.tryParse(duree);
    if (directSeconds != null) return directSeconds;
    return 0;
  }

  void setVideoSourceType(VideoSourceType type) {
    videoSourceType = type;
    videoError = null;
    notifyListeners();
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
    notifyListeners();
  }

  void selectVideoFile(File video) {
    selectedVideoFile = video;
    videoError = null;
    notifyListeners();
  }

  void removeVideoFile() {
    selectedVideoFile = null;
    notifyListeners();
  }

  void _clearErrors() {
    titreError = null;
    descriptionError = null;
    categorieError = null;
    dureeError = null;
    videoError = null;
    imageError = null;
    ageError = null;
    errorMessage = null;
  }

  bool validateForm() {
    _clearErrors();
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
      dureeError = 'Veuillez saisir une durée (ex: 05:24)';
      isValid = false;
    } else {
      final duree = _parseDuree(dureeController.text.trim());
      if (duree <= 0) {
        dureeError = 'Format invalide (ex: 05:24)';
        isValid = false;
      }
    }

    final ageMin = int.tryParse(ageMinController.text.trim());
    final ageMax = int.tryParse(ageMaxController.text.trim());
    if (ageMin == null || ageMax == null || ageMin < 0 || ageMax < ageMin) {
      ageError = 'Tranche d\'âge invalide';
      isValid = false;
    }

    // Validation Vidéo
    if (videoSourceType == VideoSourceType.file) {
      if (selectedVideoFile == null && (videoUrl == null || videoUrl!.isEmpty)) {
        videoError = 'Veuillez sélectionner un fichier vidéo';
        isValid = false;
      }
    } else {
      final url = videoUrlController.text.trim();
      if (url.isEmpty) {
        videoError = 'Veuillez saisir l\'URL de la vidéo';
        isValid = false;
      } else if (!Uri.tryParse(url)!.hasScheme) {
        videoError = 'URL invalide (doit commencer par https://)';
        isValid = false;
      }
    }

    // Validation Miniature
    if (selectedImage == null && (imageUrl == null || imageUrl!.isEmpty)) {
      imageError = 'Veuillez ajouter une miniature / image de couverture';
      isValid = false;
    }

    if (!isValid) {
      errorMessage = 'Veuillez corriger les erreurs ci-dessous';
    }

    notifyListeners();
    return isValid;
  }

  Tutoriel buildTutoriel({
    String? finalImageUrl,
    String? finalVideoUrl,
  }) {
    final dureeEnSecondes = _parseDuree(dureeController.text.trim());
    final ageMin = int.tryParse(ageMinController.text.trim()) ?? 3;
    final ageMax = int.tryParse(ageMaxController.text.trim()) ?? 10;

    return Tutoriel(
      tutorielId: initialTutoriel?.tutorielId,
      categorieId: selectedCategorieId,
      jouetLieId: selectedJouetsIds.isNotEmpty ? selectedJouetsIds.first : null,
      createurId: initialTutoriel?.createurId ?? 'admin',
      titre: titreController.text.trim(),
      description: descriptionController.text.trim(),
      jouetsSuggeres: selectedJouetsIds,
      videoUrl: finalVideoUrl ??
          (videoSourceType == VideoSourceType.url
              ? videoUrlController.text.trim()
              : (videoUrl ?? '')),
      miniatureUrl: finalImageUrl ?? imageUrl ?? '',
      duree: dureeEnSecondes,
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

      // 1. Upload de la miniature sur Cloudinary SI une nouvelle image est sélectionnée
      String finalMiniatureUrl = imageUrl ?? '';
      if (selectedImage != null) {
        uploadStatusText = 'Téléversement de la miniature sur Cloudinary...';
        notifyListeners();

        finalMiniatureUrl = await repository.uploadMiniatureDirect(
          selectedImage!,
          tutorielId: existingId,
        );
        imageUrl = finalMiniatureUrl;
      }

      // 2. Upload du fichier vidéo sur Cloudinary SI un nouveau fichier vidéo est sélectionné
      String finalVideoUrl = videoUrlController.text.trim();
      if (videoSourceType == VideoSourceType.file) {
        if (selectedVideoFile != null) {
          uploadStatusText = 'Téléversement de la vidéo sur Cloudinary (cela peut prendre un instant)...';
          notifyListeners();

          finalVideoUrl = await repository.uploadVideoDirect(
            selectedVideoFile!,
            tutorielId: existingId,
          );
          videoUrl = finalVideoUrl;
        } else if (videoUrl != null && videoUrl!.isNotEmpty) {
          finalVideoUrl = videoUrl!;
        }
      }

      // 3. TOUS les uploads ont réussi avec succès ! On enregistre maintenant dans Firestore
      uploadStatusText = 'Enregistrement dans la base de données...';
      notifyListeners();

      final tutorielToSave = buildTutoriel(
        finalImageUrl: finalMiniatureUrl,
        finalVideoUrl: finalVideoUrl,
      );

      if (initialTutoriel == null) {
        await repository.createTutoriel(tutorielToSave);
      } else {
        await repository.updateTutoriel(tutorielToSave);
      }

      // Invalidation des providers
      ref.invalidate(adminTutorielsProvider);
      ref.invalidate(tutorielsProvider);

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
    dureeController.clear();
    videoUrlController.clear();
    ageMinController.text = '3';
    ageMaxController.text = '10';
    selectedCategorieId = categories.isNotEmpty ? categories.first.categorieId : '';
    selectedJouetsIds = [];
    selectedImage = null;
    selectedVideoFile = null;
    imageUrl = null;
    videoUrl = null;
    statut = TutorielStatus.publie;
    videoSourceType = VideoSourceType.url;
    _clearErrors();
    notifyListeners();
  }

  @override
  void dispose() {
    titreController.dispose();
    descriptionController.dispose();
    dureeController.dispose();
    videoUrlController.dispose();
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