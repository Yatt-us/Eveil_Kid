import 'package:flutter/material.dart';

import '../../models/activity.dart';

class ActiviteCard extends StatelessWidget {
  final Activite activite;
  final VoidCallback onTap;

  const ActiviteCard({
    super.key,
    required this.activite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activite.imageUrl != null && activite.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  activite.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(height: 80, child: Center(child: Icon(Icons.image_not_supported))),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          activite.titre,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Chip(
                        label: Text(
                          '${activite.points} pts',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.amber.shade100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activite.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text('${activite.dureeEnMinutes} min', style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(width: 16),
                      Icon(Icons.child_care, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text('${activite.ageMinimum}-${activite.ageMaximum} ans', style: TextStyle(color: Colors.grey[700])),
                    ],
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