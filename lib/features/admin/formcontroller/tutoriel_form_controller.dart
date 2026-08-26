import 'dart:io';
import 'package:eveilkid/features/tutoriels/enums/tutoriel_status.enum.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/ActivityCategorie/models/activity_category_model.dart';
import 'package:eveilkid/features/ActivityCategorie/providers/activity_category_provider.dart';

class TutorielFormController extends ChangeNotifier {
  final Ref ref;
  final Tutoriel? initialTutoriel;


  final TextEditingController titreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dureeController = TextEditingController();
  final TextEditingController videoUrlController = TextEditingController();

  String selectedCategorieId = '';
  List<String> selectedJouetsIds = [];

  File? selectedImage;
  String? imageUrl;

  bool isLoading = false;
  bool isLoadingCategories = true;
  String? errorMessage;

  String? titreError;
  String? descriptionError;
  String? categorieError;
  String? dureeError;
  String? videoUrlError;
  String? imageError;

  List<ActiviteCategorie> categories = [];

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

      final result = await ref.read(categoriesActivesProvider.future);
      categories = result;

      isLoadingCategories = false;
      errorMessage = null;
      notifyListeners();

      if (selectedCategorieId.isEmpty && categories.isNotEmpty) {
        selectedCategorieId = categories.first.id!;
        notifyListeners();
      }
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
    selectedCategorieId = tutoriel.categorieId;
    selectedJouetsIds = List.from(tutoriel.jouetsSuggeres);
    imageUrl = tutoriel.miniatureUrl;
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
    return 0;
  }


  void updateCategorie(String categorieId) {
    selectedCategorieId = categorieId;
    categorieError = null;
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

  

  void _clearErrors() {
    titreError = null;
    descriptionError = null;
    categorieError = null;
    dureeError = null;
    videoUrlError = null;
    imageError = null;
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
      dureeError = 'Veuillez saisir une durée';
      isValid = false;
    } else {
      final duree = _parseDuree(dureeController.text.trim());
      if (duree <= 0) {
        dureeError = 'Format invalide (ex: 05:24)';
        isValid = false;
      }
    }

    if (videoUrlController.text.trim().isEmpty) {
      videoUrlError = 'Veuillez saisir une URL vidéo';
      isValid = false;
    } else if (!_isValidUrl(videoUrlController.text.trim())) {
      videoUrlError = 'URL invalide';
      isValid = false;
    }

    if (selectedImage == null && (imageUrl == null || imageUrl!.isEmpty)) {
      imageError = 'Veuillez sélectionner une image de couverture';
      isValid = false;
    }

    if (!isValid) {
      errorMessage = 'Veuillez corriger les erreurs ci-dessous';
    }

    notifyListeners();
    return isValid;
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isAbsolute);
  }

  
  Tutoriel buildTutoriel() {
    final dureeEnSecondes = _parseDuree(dureeController.text.trim());

    return Tutoriel(
      tutorielId: initialTutoriel?.tutorielId,
      categorieId: selectedCategorieId,
      jouetLieId: null,
      createurId: 'admin',
      titre: titreController.text.trim(),
      description: descriptionController.text.trim(),
      jouetsSuggeres: selectedJouetsIds,
      videoUrl: videoUrlController.text.trim(),
      miniatureUrl: imageUrl ?? '',
      duree: dureeEnSecondes,
      ageMinimum: 3,
      ageMaximum: 12,
      statut: initialTutoriel?.statut ?? TutorielStatus.brouillon,
      dateCreation: initialTutoriel?.dateCreation ?? DateTime.now(),
      dateModification: DateTime.now(),
    );
  }

  Future<bool> save() async {
    if (!validateForm()) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final repository = ref.read(tutorielRepositoryProvider);
      final tutoriel = buildTutoriel();

      Tutoriel? savedTutoriel;

      if (initialTutoriel == null) {
        savedTutoriel = await repository.createTutoriel(tutoriel);
        debugPrint('✅ Tutoriel créé: ${savedTutoriel.titre}');
      } else {
        savedTutoriel = await repository.updateTutoriel(tutoriel);
        debugPrint('✅ Tutoriel mis à jour: ${savedTutoriel.titre}');
      }

      if (selectedImage != null && savedTutoriel.tutorielId != null) {
        try {
          final imageUrl = await repository.uploadMiniature(
            savedTutoriel.tutorielId!,
            selectedImage!
          );
          this.imageUrl = imageUrl;
          debugPrint('✅ Image uploadée avec succès');
        } catch (e) {
          debugPrint('⚠️ Erreur lors de l\'upload: $e');
          errorMessage = 'Tutoriel enregistré mais erreur lors de l\'upload de l\'image';
          notifyListeners();
        }
      }

      ref.invalidate(adminTutorielsProvider);
      ref.invalidate(tutorielsProvider);

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

  void resetForm() {
    titreController.clear();
    descriptionController.clear();
    dureeController.clear();
    videoUrlController.clear();
    selectedCategorieId = categories.isNotEmpty ? categories.first.id! : '';
    selectedJouetsIds = [];
    selectedImage = null;
    imageUrl = null;
    _clearErrors();
    notifyListeners();
  }

  @override
  void dispose() {
    titreController.dispose();
    descriptionController.dispose();
    dureeController.dispose();
    videoUrlController.dispose();
    super.dispose();
  }
}


final tutorielFormControllerProvider = Provider.family<TutorielFormController, Tutoriel?>(
  (ref, initialTutoriel) {
    return TutorielFormController(ref, initialTutoriel: initialTutoriel);
  },
);