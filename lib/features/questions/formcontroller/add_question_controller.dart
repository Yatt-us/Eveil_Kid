import 'package:eveilkid/features/questions/enums/question_type.enum.dart';
import 'package:eveilkid/features/questions/models/question_model.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import 'package:eveilkid/features/questions/providers/question_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';


class AddQuestionController extends ChangeNotifier {
  final WidgetRef ref;
  final String activityId;
  final QuestionType type;

  final TextEditingController questionController = TextEditingController();
  final TextEditingController pointsController = TextEditingController(text: '10');
  final List<TextEditingController> optionControllers = [];
  final List<OptionQuestion> options = [];
  
  String selectedCorrectOptionId = '';
  File? selectedImage;
  bool isLoading = false;
  String? errorMessage;
  String? selectedTrueFalse;

  AddQuestionController({
    required this.ref,
    required this.activityId,
    required this.type,
  }) {
    _initOptions();
  }

  void _initOptions() {
    options.clear();
    optionControllers.clear();
    selectedCorrectOptionId = '';
    selectedTrueFalse = null;

    switch (type) {
      case QuestionType.choixMultiple:
        options.addAll([
          OptionQuestion(id: 'opt_1', texte: ''),
          OptionQuestion(id: 'opt_2', texte: ''),
          OptionQuestion(id: 'opt_3', texte: ''),
        ]);
        optionControllers.addAll([
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ]);
        break;

      case QuestionType.vraiFaux:
        break;

      case QuestionType.association:
        options.addAll([
          OptionQuestion(id: 'assoc_1', texte: ''),
          OptionQuestion(id: 'assoc_2', texte: ''),
          OptionQuestion(id: 'assoc_3', texte: ''),
        ]);
        optionControllers.addAll([
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ]);
        break;

      case QuestionType.classement:
        options.addAll([
          OptionQuestion(id: 'class_1', texte: ''),
          OptionQuestion(id: 'class_2', texte: ''),
          OptionQuestion(id: 'class_3', texte: ''),
        ]);
        optionControllers.addAll([
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ]);
        break;
    }
  }

  void updateCorrectAnswer(String optionId) {
    selectedCorrectOptionId = optionId;
    notifyListeners();
  }

  void updateTrueFalse(String value) {
    selectedTrueFalse = value;
    selectedCorrectOptionId = value == 'vrai' ? 'opt_vrai' : 'opt_faux';
    notifyListeners();
  }

  void updateOptionText(int index, String value) {
    options[index] = options[index].copyWith(texte: value);
    notifyListeners();
  }

  void addOption() {
    final newId = 'opt_${options.length + 1}';
    options.add(OptionQuestion(id: newId, texte: ''));
    optionControllers.add(TextEditingController());
    notifyListeners();
  }

  void removeOption(int index) {
    int minOptions = 2;
    if (type == QuestionType.association || type == QuestionType.classement) {
      minOptions = 3;
    }

    if (options.length <= minOptions) {
      errorMessage = 'Minimum $minOptions éléments';
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
    notifyListeners();
  }

  bool validateForm() {
    if (questionController.text.trim().isEmpty) {
      errorMessage = 'Veuillez saisir une question';
      notifyListeners();
      return false;
    }

    if (pointsController.text.trim().isEmpty) {
      errorMessage = 'Veuillez saisir les points';
      notifyListeners();
      return false;
    }

    switch (type) {
      case QuestionType.choixMultiple:
        final hasEmptyOption = options.any((opt) => opt.texte.trim().isEmpty);
        if (hasEmptyOption) {
          errorMessage = 'Veuillez remplir toutes les options';
          notifyListeners();
          return false;
        }
        if (selectedCorrectOptionId.isEmpty) {
          errorMessage = 'Veuillez sélectionner la bonne réponse';
          notifyListeners();
          return false;
        }
        break;

      case QuestionType.vraiFaux:
        if (selectedCorrectOptionId.isEmpty) {
          errorMessage = 'Veuillez sélectionner Vrai ou Faux';
          notifyListeners();
          return false;
        }
        break;

      case QuestionType.association:
      case QuestionType.classement:
        final hasEmptyElement = options.any((opt) => opt.texte.trim().isEmpty);
        if (hasEmptyElement) {
          errorMessage = 'Veuillez remplir tous les éléments';
          notifyListeners();
          return false;
        }
        break;
    }

    errorMessage = null;
    notifyListeners();
    return true;
  }

  Question buildQuestion() {
    return Question(
      activiteId: activityId,
      enonce: questionController.text.trim(),
      type: type,
      options: options,
      idReponseCorrecte: selectedCorrectOptionId,
      points: int.tryParse(pointsController.text) ?? 10,
      ordre: 0,
      imageUrl: null,
    );
  }

  Future<bool> save() async {
    if (!validateForm()) return false;

    isLoading = true;
    notifyListeners();

    try {
      final question = buildQuestion();
      final notifier = ref.read(questionNotifierProvider.notifier);
      await notifier.createQuestion(question);
      
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
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