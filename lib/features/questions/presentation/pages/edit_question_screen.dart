import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/questions/enums/question_type.enum.dart';
import 'package:eveilkid/features/questions/formcontroller/add_question_controller.dart';
import 'package:eveilkid/features/questions/presentation/widgets/association_options.dart';
import 'package:eveilkid/features/questions/presentation/widgets/error_message_widget.dart';
import 'package:eveilkid/features/questions/presentation/widgets/image_picker_widget.dart';
import 'package:eveilkid/features/questions/presentation/widgets/multiple_choice_options.dart';
import 'package:eveilkid/features/questions/presentation/widgets/ordering_options.dart';
import 'package:eveilkid/features/questions/presentation/widgets/points_widget.dart';
import 'package:eveilkid/features/questions/presentation/widgets/question_form_widget.dart';
import 'package:eveilkid/features/questions/presentation/widgets/save_button_widget.dart';
import 'package:eveilkid/features/questions/presentation/widgets/true_false_options.dart';
import 'package:eveilkid/features/questions/providers/question_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditQuestionScreen extends ConsumerStatefulWidget {
  final String activityId;
  final String questionId;

  const EditQuestionScreen({
    super.key,
    required this.activityId,
    required this.questionId,
  });

  @override
  ConsumerState<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends ConsumerState<EditQuestionScreen> {
  late AddQuestionController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    try {
      final questionAsync = await ref.read(
        questionByIdProvider(
          (activiteId: widget.activityId, questionId: widget.questionId)
        ).future
      );

      if (!mounted) return;

      if (questionAsync != null) {
        _controller = AddQuestionController(
          ref: ref,
          activityId: widget.activityId,
          type: questionAsync.type,
          existingQuestion: questionAsync,
        );
        setState(() => _isLoading = false);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question non trouvée'),
              backgroundColor: AppColors.danger
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Erreur lors du chargement: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        _controller.selectImage(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger
          ),
        );
      }
    }
  }

  Future<void> _updateQuestion() async {
    final success = await _controller.update();
    if (success && mounted) {

      ref.invalidate(questionsByActiviteProvider(widget.activityId));
      ref.invalidate(
        questionByIdProvider(
          (activiteId: widget.activityId, questionId: widget.questionId)
        )
      );
      
      
      final notifier = ref.read(questionNotifierProvider.notifier);
      await notifier.loadQuestions(widget.activityId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question mise à jour avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modifier ${_controller.type.label}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question avec erreur
                    QuestionFormWidget(
                      controller: _controller.questionController,
                      hintText: 'Modifiez votre question...',
                      errorText: _controller.questionError,
                    ),
                    const SizedBox(height: 20),

                    // Image
                    ImagePickerWidget(
                      selectedImage: _controller.selectedImage,
                      imageUrl: _controller.imageUrl,
                      onImageRemoved: _controller.removeImage,
                      onImageTap: _pickImage,
                    ),
                    const SizedBox(height: 24),

                    // Options selon le type
                    _buildOptionsSection(),
                    const SizedBox(height: 24),

                    // Points avec erreur
                    PointsWidget(
                      controller: _controller.pointsController,
                      errorText: _controller.pointsError,
                    ),
                    const SizedBox(height: 24),

                    // Erreur
                    ErrorMessageWidget(message: _controller.errorMessage),

                    // Bouton Mettre à jour
                    SaveButtonWidget(
                      onPressed: _updateQuestion,
                      label: 'Mettre à jour',
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      height: 40,
                     
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(
                            color: AppColors.danger,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                    ),

                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOptionsSection() {
    switch (_controller.type) {
      case QuestionType.choixMultiple:
        return MultipleChoiceOptions(
          options: _controller.options,
          controllers: _controller.optionControllers,
          selectedCorrectOptionId: _controller.selectedCorrectOptionId,
          onOptionChanged: _controller.updateOptionText,
          onCorrectAnswerChanged: _controller.updateCorrectAnswer,
          onAddOption: _controller.addOption,
          onRemoveOption: _controller.removeOption,
          optionsError: _controller.optionsError,
          correctAnswerError: _controller.correctAnswerError,
        );

      case QuestionType.vraiFaux:
        return TrueFalseOptions(
          selectedTrueFalse: _controller.selectedTrueFalse,
          onChanged: _controller.updateTrueFalse,
          errorText: _controller.correctAnswerError,
        );

      case QuestionType.association:
        return AssociationOptions(
          options: _controller.options,
          controllers: _controller.optionControllers,
          onOptionChanged: _controller.updateOptionText,
          onAddOption: _controller.addOption,
          onRemoveOption: _controller.removeOption,
          optionsError: _controller.optionsError,
        );

      case QuestionType.classement:
        return OrderingOptions(
          options: _controller.options,
          controllers: _controller.optionControllers,
          onOptionChanged: _controller.updateOptionText,
          onAddOption: _controller.addOption,
          onRemoveOption: _controller.removeOption,
          optionsError: _controller.optionsError,
        );
    }
  }
}