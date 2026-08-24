import 'package:eveilkid/core/provider/bottom_nav_bar_provider.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/tutoriels/providers/tutorielProvider.dart';
import 'package:eveilkid/shared/widgets/app_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TutorielPage extends ConsumerWidget {
  const TutorielPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorielsAsync = ref.watch(tutorielsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ref.read(bottomIndexProvider.notifier).setIndex(0);
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Tutoriels')),

      body: tutorielsAsync.when(
        // Données chargées
        data: (tutoriels) {
          if (tutoriels.isEmpty) {
            return const Center(child: Text('Aucun tutoriel disponible'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tutoriels.length,
            itemBuilder: (context, index) {
              final tutoriel = tutoriels[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Miniature
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        tutoriel.miniatureUrl,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                          );
                        },
                      ),
                    ),

                    // Informations
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tutoriel.titre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            tutoriel.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 18),

                              const SizedBox(width: 5),

                              Text('${tutoriel.duree} secondes'),

                              const Spacer(),

                              Text(
                                '${tutoriel.ageMinimum}-${tutoriel.ageMaximum} ans',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },

        // Chargement
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        // Erreur
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),

                  const SizedBox(height: 16),

                  const Text(
                    'Une erreur est survenue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(error.toString(), textAlign: TextAlign.center),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(tutorielsProvider);
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    ),
  );
  }
}
