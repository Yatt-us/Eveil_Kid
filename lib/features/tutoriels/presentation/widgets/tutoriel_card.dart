import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:flutter/material.dart';


class TutorielCard extends StatelessWidget {
final Tutoriel tutoriel;

  const TutorielCard({
    super.key,
    required this.tutoriel,
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Partie Image avec la durée de la vidéo
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  tutoriel.miniatureUrl, // Ou Image.network selon votre source
                  width: 140,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tutoriel.durationLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Partie Texte (Titre + Badge d'âge)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tutoriel.titre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
  '${tutoriel.ageMinimum}-${tutoriel.ageMaximum} ans', // Interpolation propre
  style: TextStyle(
    fontSize: 12,
    color: Colors.grey[800],
    fontWeight: FontWeight.w500,
  ),
),


                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
  
