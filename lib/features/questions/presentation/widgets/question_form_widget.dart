import 'package:flutter/material.dart';

class QuestionFormWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;

  const QuestionFormWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Question',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            errorText: errorText,
            errorMaxLines: 2,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          maxLines: 2,
          onChanged: (_) {
            // Le controller gère la validation
          },
        ),
      ],
    );
  }
}