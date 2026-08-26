import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import 'package:flutter/material.dart';


class MultipleChoiceOptions extends StatelessWidget {
  final List<OptionQuestion> options;
  final List<TextEditingController> controllers;
  final String selectedCorrectOptionId;
  final Function(int, String) onOptionChanged;
  final Function(String) onCorrectAnswerChanged;
  final VoidCallback onAddOption;
  final Function(int) onRemoveOption;
  final String? optionsError;
  final String? correctAnswerError;

  const MultipleChoiceOptions({
    super.key,
    required this.options,
    required this.controllers,
    required this.selectedCorrectOptionId,
    required this.onOptionChanged,
    required this.onCorrectAnswerChanged,
    required this.onAddOption,
    required this.onRemoveOption,
    this.optionsError,
    this.correctAnswerError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isCorrect = selectedCorrectOptionId == option.id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    onCorrectAnswerChanged(
                      isCorrect ? '' : option.id
                    );
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCorrect ? AppColors.primary : Colors.white,
                      border: Border.all(
                        color: isCorrect ? AppColors.primary : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isCorrect
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controllers[index],
                    decoration: InputDecoration(
                      hintText: 'Option ${index + 1}',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (value) => onOptionChanged(index, value),
                  ),
                ),
                if (options.length > 2)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                    onPressed: () => onRemoveOption(index),
                    padding: const EdgeInsets.only(left: 4),
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        TextButton(
          onPressed: onAddOption,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
          ),
          child: const Row(
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 4),
              Text(
                'Ajouter une option',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        
        if (optionsError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              optionsError!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        if (correctAnswerError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              correctAnswerError!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        if (selectedCorrectOptionId.isNotEmpty && correctAnswerError == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'Bonne réponse sélectionnée',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}