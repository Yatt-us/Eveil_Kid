import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import 'package:flutter/material.dart';


class OrderingOptions extends StatelessWidget {
  final List<OptionQuestion> options;
  final List<TextEditingController> controllers;
  final Function(int, String) onOptionChanged;
  final VoidCallback onAddOption;
  final Function(int) onRemoveOption;

  const OrderingOptions({
    super.key,
    required this.options,
    required this.controllers,
    required this.onOptionChanged,
    required this.onAddOption,
    required this.onRemoveOption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Éléments à classer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Définissez les éléments dans le bon ordre',
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
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                'Ajouter un élément',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}