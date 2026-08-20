import 'package:flutter/material.dart';

class TutorielSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;

  const TutorielSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F2F7),
              borderRadius: BorderRadius.circular(40),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Rechercher un tutoriel...',
                hintStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 36,
                  color: Colors.black,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 22,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        GestureDetector(
          onTap: onFilterPressed,
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F2F7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.filter_list,
              size: 36,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}