import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/questions/enums/question_type.enum.dart';
import 'package:eveilkid/features/questions/models/question_model.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
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
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  final List<OptionQuestion> _options = [];
  String _selectedCorrectOptionId = '';
  String? _imageUrl;
  File? _selectedImage;
  bool _isLoading = true;
  bool _isSaving = false;
  QuestionType _questionType = QuestionType.choixMultiple;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  
  Future<void> _loadQuestion() async {
    setState(() => _isLoading = true);

    try {
      
      final questionAsync = await ref.read(
        questionByIdProvider(
          (activiteId: widget.activityId, questionId: widget.questionId)
        ).future
      );

      if (!mounted) return;

      if (questionAsync != null) {
        _questionController.text = questionAsync.enonce;
        _pointsController.text = questionAsync.points.toString();
        _questionType = questionAsync.type;
        _options.clear();
        _options.addAll(questionAsync.options);
        _selectedCorrectOptionId = questionAsync.idReponseCorrecte;
        _imageUrl = questionAsync.imageUrl;

        _optionControllers.clear();
        for (int i = 0; i < _options.length; i++) {
          _optionControllers.add(TextEditingController(text: _options[i].texte));
        }

        setState(() => _isLoading = false);
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question non trouvée'),
              backgroundColor: AppColors.danger,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Erreur lors du chargement: $e'); 
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _pointsController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modifier ${_questionType.label}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        centerTitle: true,
        
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  const Text(
                    'Question',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      hintText: 'Quel animal est un chat ?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

                  // Image (optionnel)
                  const Text(
                    'Image (optionnel)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _selectedImage != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black.withOpacity(0.6),
                                    radius: 16,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                      onPressed: () {
                                        setState(() {
                                          _selectedImage = null;
                                          _imageUrl = null;
                                        });
                                      },
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : _imageUrl != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: Icon(Icons.broken_image),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black.withOpacity(0.6),
                                        radius: 16,
                                        child: IconButton(
                                          icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                          onPressed: () {
                                            setState(() {
                                              _selectedImage = null;
                                              _imageUrl = null;
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tapez pour ajouter une image',
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Options selon le type
                  _buildOptionsSection(),
                  const SizedBox(height: 24),

                  // Points
                  const Text(
                    'Points',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _pointsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '10',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton Mettre à jour
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _updateQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Mettre à jour',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  
  Widget _buildOptionsSection() {
    switch (_questionType) {
      case QuestionType.choixMultiple:
        return _buildMultipleChoiceOptions();

      case QuestionType.vraiFaux:
        return _buildTrueFalseOptions();

      case QuestionType.association:
        return _buildAssociationOptions();

      case QuestionType.classement:
        return _buildOrderingOptions();
    }
  }

  
  Widget _buildMultipleChoiceOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ..._options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isCorrect = _selectedCorrectOptionId == option.id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Checkbox(
                  value: isCorrect,
                  onChanged: (_) {
                    setState(() {
                      if (isCorrect) {
                        _selectedCorrectOptionId = '';
                      } else {
                        _selectedCorrectOptionId = option.id;
                      }
                    });
                  },
                  activeColor: AppColors.childPrimary,
                ),
                Expanded(
                  child: TextField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(
                      hintText: 'Option ${index + 1}',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: _options.length > 2
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => _removeOption(index),
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _options[index] = option.copyWith(texte: value);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _addOption,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter une option'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
        if (_selectedCorrectOptionId.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '✅ Bonne réponse sélectionnée',
              style: TextStyle(
                color: AppColors.childPrimary,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

 
  Widget _buildTrueFalseOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bonne réponse',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCorrectOptionId = 'opt_vrai';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedCorrectOptionId == 'opt_vrai'
                        ? AppColors.childPrimary
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedCorrectOptionId == 'opt_vrai'
                          ? AppColors.childPrimary
                          : Colors.grey.shade300,
                      width: _selectedCorrectOptionId == 'opt_vrai' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedCorrectOptionId == 'opt_vrai'
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: _selectedCorrectOptionId == 'opt_vrai'
                            ? AppColors.childPrimary
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Vrai',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCorrectOptionId = 'opt_faux';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedCorrectOptionId == 'opt_faux'
                        ? AppColors.childPrimary
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedCorrectOptionId == 'opt_faux'
                          ? AppColors.childPrimary
                          : Colors.grey.shade300,
                      width: _selectedCorrectOptionId == 'opt_faux' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedCorrectOptionId == 'opt_faux'
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: _selectedCorrectOptionId == 'opt_faux'
                            ? AppColors.childPrimary
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Faux',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_selectedCorrectOptionId.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '✅ Bonne réponse sélectionnée',
              style: TextStyle(
                color: AppColors.childPrimary,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  
  Widget _buildAssociationOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Éléments à associer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Définissez les paires d\'association',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ..._options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(
                      hintText: 'Élément ${index + 1}',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: _options.length > 3
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => _removeOption(index),
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _options[index] = option.copyWith(texte: value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Association',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _addOption,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter une paire'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Éléments à classer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Définissez les éléments dans le bon ordre',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ..._options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color:AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(
                      hintText: 'Élément ${index + 1}',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: _options.length > 3
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => _removeOption(index),
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _options[index] = option.copyWith(texte: value);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _addOption,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter un élément'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }


  void _addOption() {
    setState(() {
      final newId = 'opt_${_options.length + 1}';
      _options.add(OptionQuestion(id: newId, texte: ''));
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    int minOptions = 2;
    if (_questionType == QuestionType.association || 
        _questionType == QuestionType.classement) {
      minOptions = 3;
    }

    if (_options.length <= minOptions) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimum $minOptions éléments'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      final removedId = _options[index].id;
      if (_selectedCorrectOptionId == removedId) {
        _selectedCorrectOptionId = '';
      }
      _options.removeAt(index);
      _optionControllers.removeAt(index);
    });
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
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  Future<void> _updateQuestion() async {
    // Validation
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir une question'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_questionType == QuestionType.choixMultiple) {
      final hasEmptyOption = _options.any((opt) => opt.texte.trim().isEmpty);
      if (hasEmptyOption) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez remplir toutes les options'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
      if (_selectedCorrectOptionId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner la bonne réponse'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
    }

    if (_questionType == QuestionType.vraiFaux) {
      if (_selectedCorrectOptionId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner Vrai ou Faux'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
    }

    if (_pointsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir les points'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final question = Question(
        id: widget.questionId,
        activiteId: widget.activityId,
        enonce: _questionController.text.trim(),
        type: _questionType,
        options: _options,
        idReponseCorrecte: _selectedCorrectOptionId,
        points: int.tryParse(_pointsController.text) ?? 10,
        ordre: 0,
      );

      final notifier = ref.read(questionNotifierProvider.notifier);
      await notifier.updateQuestion(question);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question mise à jour avec succès !'),
            backgroundColor: AppColors.childPrimary,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }
}
