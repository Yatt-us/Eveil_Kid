import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/activites/enums/publication_status.enum.dart';
import '../../../providers/client/activity.dart';
import '../../widgets/categorie_card.dart';
import 'quiz_screen.dart';

class ActivitesScreen extends ConsumerWidget {
  const ActivitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(activiteFilterProvider);
    final activitesAsync = ref.watch(activitesStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Activités',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Selecteur personnalisé Figma (Toutes / En cours / Terminées)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                _buildFilterChip(context, ref, title: 'Toutes', index: 0, currentIndex: currentFilter),
                const SizedBox(width: 8),
                _buildFilterChip(context, ref, title: 'En cours', index: 1, currentIndex: currentFilter),
                const SizedBox(width: 8),
                _buildFilterChip(context, ref, title: 'Terminées', index: 2, currentIndex: currentFilter),
              ],
            ),
          ),

          // Liste Firebase dynamique
          Expanded(
            child: activitesAsync.when(
              data: (activites) {
                final filtres = activites.where((a) {
                  final double prog = (a.points / 100).clamp(0.0, 1.0);
                  if (currentFilter == 1) return prog > 0.0 && prog < 1.0;
                  if (currentFilter == 2) return prog >= 1.0 || a.statut == PublicationStatus.archive;
                  return true;
                }).toList();

                if (filtres.isEmpty) {
                  return const Center(
                    child: Text('Aucune activité dans cette catégorie.'),
                  );
                }

                return ListView.builder(
                  itemCount: filtres.length,
                  itemBuilder: (context, index) {
                    final activite = filtres[index];
                    
                    // Progression calculée dynamiquement à partir des points de l'activité
                    final double progressionCalculee = (activite.points / 100).clamp(0.0, 1.0);

                    return CategorieCard(
                      activite: activite,
                      progression: progressionCalculee,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(activite: activite),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur : $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, WidgetRef ref, {required String title, required int index, required int currentIndex}) {
    final isSelected = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(activiteFilterProvider.notifier).setFilter(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2EA650) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}