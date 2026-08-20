import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:flutter/material.dart';

class TutorielCard extends StatelessWidget {
  final Tutoriel tutoriel;
  final VoidCallback? onTap;

  const TutorielCard({
    super.key,
    required this.tutoriel,
    this.onTap,
  });

  String _formatDuration(num duration) {
    final totalSeconds = duration.toInt();

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _getAgeLabel() {
    return '${tutoriel.ageMinimum.toInt()}-'
        '${tutoriel.ageMaximum.toInt()} ans';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // =========================
            // MINIATURE
            // =========================
            SizedBox(
              width: 280,
              height: 190,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.network(
                      tutoriel.videoUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,

                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                          ),
                        );
                      },

                      loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                      ) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),

                  // =========================
                  // DURÉE
                  // =========================
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatDuration(tutoriel.duree),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 32),

            // =========================
            // INFORMATIONS
            // =========================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutoriel.titre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F2F7),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      _getAgeLabel(),
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}