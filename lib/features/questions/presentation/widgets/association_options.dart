import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import 'package:flutter/material.dart';


class AssociationOptions extends StatelessWidget {
  final List<OptionQuestion> options;
  final List<TextEditingController> controllers;
  final Function(int, String) onOptionChanged;
  final VoidCallback onAddOption;
  final Function(int) onRemoveOption;
  final String? optionsError;

  const AssociationOptions({
    super.key,
    required this.options,
    required this.controllers,
    required this.onOptionChanged,
    required this.onAddOption,
    required this.onRemoveOption,
    this.optionsError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Éléments à associer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Définissez les paires d\'association',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controllers[index],
                    decoration: InputDecoration(
                      hintText: 'Élément ${index + 1}',
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
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Association',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                if (options.length > 3)
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
                'Ajouter une paire',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        // ✅ Afficher l'erreur
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
      ],
    );
  }
}