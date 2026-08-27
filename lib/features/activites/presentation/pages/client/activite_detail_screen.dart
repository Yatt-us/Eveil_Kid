import 'package:flutter/material.dart';

import '../../../models/activity.dart';

class ActiviteDetailScreen extends StatelessWidget {
  final Activite activite;

  const ActiviteDetailScreen({super.key, required this.activite});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activite.titre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activite.imageUrl != null && activite.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  activite.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Chip(avatar: const Icon(Icons.timer, size: 16), label: Text('${activite.dureeEnMinutes} min')),
                Chip(avatar: const Icon(Icons.face, size: 16), label: Text('${activite.ageMinimum}-${activite.ageMaximum} ans')),
                Chip(avatar: const Icon(Icons.star, size: 16, color: Colors.amber), label: Text('${activite.points} pts')),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(activite.description),
            const SizedBox(height: 20),
            if (activite.materiels.isNotEmpty) ...[
              Text(
                'Matériel nécessaire',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...activite.materiels.map((m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text(m)),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
            ],
            if (activite.objectifsApprentissage.isNotEmpty) ...[
              Text(
                'Objectifs d\'apprentissage',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...activite.objectifsApprentissage.map((obj) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 18, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(child: Text(obj)),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}