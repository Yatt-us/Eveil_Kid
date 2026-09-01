import 'package:flutter/material.dart';

class CarteActiviteEnfant extends StatelessWidget {
  final String titre;
  final String duree;
  final String imageUrl;
  final double progression;
  final VoidCallback? onTap;

  const CarteActiviteEnfant({
    super.key,
    required this.titre,
    required this.duree,
    required this.imageUrl,
    required this.progression,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image de l'activité
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: const Color(0xFFF3EEFF),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return const Icon(
                          Icons.extension,
                          color: Color(0xFF8B5CF6),
                          size: 30,
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        imageUrl,
                        style: const TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
            ),

            const SizedBox(width: 12),

            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF242424),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    duree,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 7),

                  // Barre de progression
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progression,
                      minHeight: 5,
                      backgroundColor: const Color(0xFFEDEDED),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(
                        Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Cercle de progression
            SizedBox(
              width: 43,
              height: 43,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progression,
                    strokeWidth: 4,
                    backgroundColor:
                        const Color(0xFFE9E9E9),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(
                      Color(0xFF8B5CF6),
                    ),
                  ),
                  Text(
                    '${(progression * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AED),
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