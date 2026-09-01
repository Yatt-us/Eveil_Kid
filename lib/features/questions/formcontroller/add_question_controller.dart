import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eveilkid/core/cloudinary/cloudinary_service.dart';
import 'package:eveilkid/features/questions/enums/question_type.enum.dart';
import 'package:eveilkid/features/questions/models/question_model.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import 'package:eveilkid/features/questions/providers/question_provider.dart';

class AddQuestionController extends ChangeNotifier {
  final dynamic ref;
  final String activityId;
  final QuestionType type;
  final Question? existingQuestion;

  final TextEditingController questionController = TextEditingController();
  final TextEditingController pointsController = TextEditingController(text: '10');
  final List<TextEditingController> optionControllers = [];
  final List<OptionQuestion> options = [];
  
  String selectedCorrectOptionId = '';
  File? selectedImage;
  bool isLoading = false;
  String? errorMessage;
  String? selectedTrueFalse;
  String? imageUrl;

  String? questionError;
  String? pointsError;
  String? optionsError;
  String? correctAnswerError;

  AddQuestionController({
    required this.ref,
    required this.activityId,
    required this.type,
    this.existingQuestion,
  }) {
    if (existingQuestion != null) {
      _loadExistingQuestion();
    } else {
      _initOptions();
    }
  }

  void _loadExistingQuestion() {
    questionController.text = existingQuestion!.enonce;
    pointsController.text = existingQuestion!.points.toString();
    options.clear();
    options.addAll(existingQuestion!.options);
    selectedCorrectOptionId = existingQuestion!.idReponseCorrecte;
    imageUrl = existingQuestion!.imageUrl;

    if (type == QuestionType.vraiFaux) {
      if (selectedCorrectOptionId == 'opt_vrai') {
        selectedTrueFalse = 'vrai';
      } else if (selectedCorrectOptionId == 'opt_faux') {
        selectedTrueFalse = 'faux';
      }
    }

    optionControllers.clear();
    for (int i = 0; i < options.length; i++) {
      optionControllers.add(TextEditingController(text: options[i].texte));
    }

    if (type == QuestionType.vraiFaux && options.isEmpty) {
      options.addAll([
        const OptionQuestion(id: 'opt_vrai', texte: 'Vrai'),
        const OptionQuestion(id: 'opt_faux', texte: 'Faux'),
      ]);
    }
    
    _clearErrors();
  }

  void _initOptions() {
    options.clear();
    optionControllers.clear();
    selectedCorrectOptionId = '';
    selectedTrueFalse = null;
    _clearErrors();

    switch (type) {
      case QuestionType.choixMultiple:
        options.addAll([
          const OptionQuestion(id: 'opt_1', texte: ''),
          const OptionQuestion(id: 'opt_2', texte: ''),
          const OptionQuestion(id: 'opt_3', texte: ''),
        ]);
        optionControllers.addAll([
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ]);
        break;

      case QuestionType.vraiFaux:
        options.addAll([
          const OptionQuestion(id: 'opt_vrai', texte: 'Vrai'),
          const OptionQuestion(id: 'opt_faux', texte: 'Faux'),
        ]);
        break;

      case QuestionType.association:
        options.addAll([
          const OptionQuestion(id: 'assoc_1', texte: ''),
          const OptionQuestion(id: 'assoc_2', texte: ''),
          const OptionQuestion(id: 'assoc_3', texte: ''),
        ]);
        optionControllers.addAll([
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ]);
        break;

      case QuestionType.classement:
        options.addAll([
          const OptionQuestion(id: 'class_1', texte: ''),
          const OptionQuestion(id: 'class_2', texte: ''),
          const OptionQuestion(id: 'class_3', texte: ''),
        ]);
        optionControllers.addAll([
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ]);
        break;
    }
  }

  void _clearErrors() {
    errorMessage = null;
    questionError = null;
    pointsError = null;
    optionsError = null;
    correctAnswerError = null;
  }

  void updateCorrectAnswer(String optionId) {
    selectedCorrectOptionId = optionId;
    correctAnswerError = null; 
    notifyListeners();
  }

  void updateTrueFalse(String value) {
    selectedTrueFalse = value;
    selectedCorrectOptionId = value == 'vrai' ? 'opt_vrai' : 'opt_faux';
    correctAnswerError = null; 
    notifyListeners();
  }

  void updateOptionText(int index, String value) {
    if (index < options.length) {
      options[index] = options[index].copyWith(texte: value);
      if (optionsError != null) {
        optionsError = null;
        notifyListeners();
      }
    }
  }

  void addOption() {
    final newId = 'opt_${options.length + 1}';
    options.add(OptionQuestion(id: newId, texte: ''));
    optionControllers.add(TextEditingController());
    if (optionsError != null) {
      optionsError = null;
    }
    notifyListeners();
  }

  void removeOption(int index) {
    int minOptions = 2;
    if (type == QuestionType.association || type == QuestionType.classement) {
      minOptions = 3;
    }

    if (options.length <= minOptions) {
      errorMessage = 'Minimum $minOptions éléments requis';
      notifyListeners();
      return;
    }

    final removedId = options[index].id;
    if (selectedCorrectOptionId == removedId) {
      selectedCorrectOptionId = '';
    }
    options.removeAt(index);
    optionControllers.removeAt(index);
    notifyListeners();
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

  void _syncOptionsFromControllers() {
    for (int i = 0; i < options.length && i < optionControllers.length; i++) {
      options[i] = options[i].copyWith(texte: optionControllers[i].text.trim());
    }
  }

  bool validateForm() {
    _clearErrors();
    _syncOptionsFromControllers();
    bool isValid = true;

    if (questionController.text.trim().isEmpty) {
      questionError = 'Veuillez saisir un énoncé de question';
      isValid = false;
    }

    if (pointsController.text.trim().isEmpty) {
      pointsError = 'Veuillez saisir les points';
      isValid = false;
    } else {
      final points = int.tryParse(pointsController.text.trim());
      if (points == null || points < 0) {
        pointsError = 'Les points doivent être un nombre supérieur ou égal à 0';
        isValid = false;
      }
    }

    switch (type) {
      case QuestionType.choixMultiple:
        final hasEmptyOption = options.any((opt) => opt.texte.trim().isEmpty);
        if (hasEmptyOption) {
          optionsError = 'Veuillez remplir toutes les options de réponses';
          isValid = false;
        }
        if (selectedCorrectOptionId.isEmpty) {
          correctAnswerError = 'Veuillez sélectionner la bonne réponse';
          isValid = false;
        }
        break;

      case QuestionType.vraiFaux:
        if (selectedCorrectOptionId.isEmpty) {
          correctAnswerError = 'Veuillez sélectionner Vrai ou Faux';
          isValid = false;
        }
        break;

      case QuestionType.association:
      case QuestionType.classement:
        final hasEmptyElement = options.any((opt) => opt.texte.trim().isEmpty);
        if (hasEmptyElement) {
          optionsError = 'Veuillez remplir tous les éléments';
          isValid = false;
        }
        break;
    }

    if (!isValid) {
      errorMessage = 'Veuillez corriger les erreurs ci-dessus';
    } else {
      errorMessage = null;
    }

    notifyListeners();
    return isValid;
  }

  Question buildQuestion() {
    _syncOptionsFromControllers();

    if (type == QuestionType.vraiFaux && options.isEmpty) {
      options.addAll([
        const OptionQuestion(id: 'opt_vrai', texte: 'Vrai'),
        const OptionQuestion(id: 'opt_faux', texte: 'Faux'),
      ]);
    }

    return Question(
      id: existingQuestion?.id,
      activiteId: activityId,
      enonce: questionController.text.trim(),
      type: type,
      options: options,
      idReponseCorrecte: selectedCorrectOptionId,
      points: int.tryParse(pointsController.text.trim()) ?? 10,
      ordre: existingQuestion?.ordre ?? 0,
      imageUrl: imageUrl,
      estArchive: existingQuestion?.estArchive ?? false,
    );
  }

  Future<bool> save() async {
    if (!validateForm()) return false;

    isLoading = true;
    notifyListeners();

    try {
      if (selectedImage != null) {
        final cloudinary = ref.read(cloudinaryServiceProvider);
        imageUrl = await cloudinary.uploadImage(
          selectedImage!,
          folder: 'questions/$activityId',
        );
      }
      final question = buildQuestion();
      final notifier = ref.read(questionNotifierProvider.notifier);
      notifier.setActiviteId(activityId);
      await notifier.createQuestion(question);
      
      _invalidateCaches(question.id);

      isLoading = false;
      _clearErrors();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> update() async {
    if (!validateForm()) return false;

    isLoading = true;
    notifyListeners();

    try {
      if (selectedImage != null) {
        final cloudinary = ref.read(cloudinaryServiceProvider);
        imageUrl = await cloudinary.uploadImage(
          selectedImage!,
          folder: 'questions/$activityId',
        );
      }
      final question = buildQuestion();
      final notifier = ref.read(questionNotifierProvider.notifier);
      notifier.setActiviteId(activityId);
      await notifier.updateQuestion(question);
      
      _invalidateCaches(question.id);

      isLoading = false;
      _clearErrors();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _invalidateCaches(String? questionId) {
    ref.invalidate(questionsByActiviteProvider(activityId));
    if (questionId != null) {
      ref.invalidate(
        questionByIdProvider((activiteId: activityId, questionId: questionId)),
      );
    }
    ref.invalidate(questionNotifierProvider);
  }

  @override
  void dispose() {
    questionController.dispose();
    pointsController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}