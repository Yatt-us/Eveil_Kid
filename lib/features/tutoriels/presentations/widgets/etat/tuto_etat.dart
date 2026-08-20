import 'package:flutter/material.dart';

class TutorielEmptyState extends StatelessWidget {
  const TutorielEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 70,
            color: Colors.grey,
          ),

          SizedBox(height: 16),

          Text(
            'Aucun tutoriel disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}