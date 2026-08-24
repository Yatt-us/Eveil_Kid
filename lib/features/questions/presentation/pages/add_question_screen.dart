import 'package:eveilkid/core/constants/app_colors.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../enums/question_type.enum.dart';

class AddQuestionScreen extends ConsumerStatefulWidget {
  final String activityId;
  final QuestionType type;

  const AddQuestionScreen({
    super.key,
    required this.activityId,
    required this.type,
  });

  @override
  ConsumerState<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends ConsumerState<AddQuestionScreen> {
  late AddQuestionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AddQuestionController(
      ref: ref,
      activityId: widget.activityId,
      type: widget.type,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _saveQuestion() async {
    final success = await _controller.save();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question ajoutée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type.label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListenableBuilder(
  listenable: _controller,
  builder: (context, _) {
    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuestionFormWidget(
              controller: _controller.questionController,
              hintText: 'Quel animal est un chat ?',
              errorText: _controller.questionError,
            ),

            const SizedBox(height: 20),

            ImagePickerWidget(
              selectedImage: _controller.selectedImage,
              imageUrl: _controller.imageUrl,
              onImageRemoved: _controller.removeImage,
              onImageTap: _pickImage,
            ),

            const SizedBox(height: 24),

            _buildOptionsSection(),

            const SizedBox(height: 24),

            PointsWidget(
              controller: _controller.pointsController,
              errorText: _controller.pointsError,
            ),

            const SizedBox(height: 24),

            ErrorMessageWidget(
              message: _controller.errorMessage,
            ),

            const SizedBox(height: 8),

            SaveButtonWidget(
              onPressed: _saveQuestion,
            ),
          ],
        ),
      ),
    );
  },
),
    );
  }

  Widget _buildOptionsSection() {
  switch (widget.type) {
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