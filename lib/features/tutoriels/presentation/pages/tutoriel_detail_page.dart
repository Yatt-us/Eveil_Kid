import 'package:eveilkid/features/tutoriels/providers/tutorielProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class TutorielDetailPage extends ConsumerWidget {
  final String tutorielId;

  const TutorielDetailPage({
    super.key,
    required this.tutorielId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorielAsync = ref.watch(
      tutorielByIdProvider(tutorielId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du tutoriel'),
      ),

      body: tutorielAsync.when(
        data: (tutoriel) {
          if (tutoriel == null) {
            return const Center(
              child: Text('Tutoriel introuvable'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Miniature
                Image.network(
                  tutoriel.miniatureUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Titre
                      Text(
                        tutoriel.titre,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Âge
                      Row(
                        children: [
                          const Icon(Icons.child_care),

                          const SizedBox(width: 8),

                          Text(
                            '${tutoriel.ageMinimum} - '
                            '${tutoriel.ageMaximum} ans',
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Durée
                      Row(
                        children: [
                          const Icon(Icons.access_time),

                          const SizedBox(width: 8),

                          Text(
                            '${tutoriel.duree} secondes',
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        tutoriel.description,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bouton vidéo
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Nous ajouterons le lecteur vidéo ici.
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text(
                            'Regarder le tutoriel',
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Jouets suggérés
                      const Text(
                        'Jouets suggérés',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (tutoriel.jouetsSuggeres.isEmpty)
                        const Text(
                          'Aucun jouet suggéré',
                        )
                      else
                        ...tutoriel.jouetsSuggeres.map(
                          (jouetId) {
                            return ListTile(
                              leading: const Icon(
                                Icons.toys,
                              ),
                              title: Text(
                                'Jouet $jouetId',
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },

        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },

        error: (error, stackTrace) {
          return Center(
            child: Text(
              'Erreur : $error',
            ),
          );
        },
      ),
    );
  }
}
