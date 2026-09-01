import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
        maxWidth: 1000,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        _controller.selectImage(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Nouvelle Question',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.type.label,
              style: TextStyle(
                fontSize: 11.5,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Énoncé de la question
                      _buildCardContainer(
                        theme: theme,
                        isDark: isDark,
                        child: QuestionFormWidget(
                          controller: _controller.questionController,
                          hintText: 'Ex : Quel animal a une longue trompe ?',
                          errorText: _controller.questionError,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 2. Illustration
                      _buildCardContainer(
                        theme: theme,
                        isDark: isDark,
                        child: ImagePickerWidget(
                          selectedImage: _controller.selectedImage,
                          imageUrl: _controller.imageUrl,
                          onImageRemoved: _controller.removeImage,
                          onImageTap: _pickImage,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 3. Options de réponses
                      _buildCardContainer(
                        theme: theme,
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.checklist_rounded,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Réponses & Propositions',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 14),
                            _buildOptionsSection(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 4. Points
                      _buildCardContainer(
                        theme: theme,
                        isDark: isDark,
                        child: PointsWidget(
                          controller: _controller.pointsController,
                          errorText: _controller.pointsError,
                        ),
                      ),

                      if (_controller.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        ErrorMessageWidget(
                          message: _controller.errorMessage,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // 5. Bouton d'enregistrement
                      SaveButtonWidget(
                        onPressed: _controller.isLoading ? null : () => _saveQuestion(),
                        label: _controller.isLoading ? 'Enregistrement...' : 'Enregistrer la question',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContainer({
    required ThemeData theme,
    required bool isDark,
    required Widget child,
  }) {
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
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