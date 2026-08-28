import 'package:flutter/material.dart';
import 'package:eveilkid/features/activites/enums/publication_status.enum.dart';

import '../../models/activity.dart';

class CategorieCard extends StatelessWidget {
  final Activite activite;
  final double progression; // Valeur entre 0.0 et 1.0 issue de Firestore/State
  final VoidCallback onTap;

  const CategorieCard({
    super.key,
    required this.activite,
    required this.progression,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool estTerminee = activite.statut == PublicationStatus.archive || progression >= 1.0;
    final int pourcentage = (progression * 100).round();

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Image/Icone du thème
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: activite.imageUrl != null && activite.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(activite.imageUrl!, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.category, color: Colors.amber, size: 32),
              ),
              const SizedBox(width: 16),

              // Informations du thème
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activite.titre,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${activite.ordreAffichage > 0 ? activite.ordreAffichage : 6} activités',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Jauge de progression ou Coche "Terminée"
              if (estTerminee)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2EA650),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Terminée',
                      style: TextStyle(
                        color: Color(0xFF2EA650),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: 54,
                  height: 54,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          value: progression,
                          strokeWidth: 5,
                          backgroundColor: Colors.purple.shade50,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                        ),
                      ),
                      Text(
                        '$pourcentage%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}