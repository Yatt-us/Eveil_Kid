import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importez votre provider de gestion d'enfant réécrit sous Riverpod
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';

import '../widgets/carte_activite_enfant.dart';

class ActivitesEnfantPage extends ConsumerStatefulWidget {
  const ActivitesEnfantPage({super.key});

  @override
  ConsumerState<ActivitesEnfantPage> createState() => _ActivitesEnfantPageState();
}

class _ActivitesEnfantPageState extends ConsumerState<ActivitesEnfantPage> {
  int filtreSelectionne = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parentId = FirebaseAuth.instance.currentUser?.uid;
      if (parentId != null && parentId.isNotEmpty) {
        ref.read(enfantNotifierProvider.notifier).chargerEnfants(parentId);
      }
    });
  }

  final List<Map<String, dynamic>> activitesDemo = const [
    {
      'titre': 'Les animaux',
      'duree': '10 min',
      'image': '🦁',
      'progression': 0.80,
    },
    {
      'titre': 'Les fruits',
      'duree': '8 min',
      'image': '🍎',
      'progression': 0.60,
    },
    {
      'titre': 'Les véhicules',
      'duree': '12 min',
      'image': '🚙',
      'progression': 0.45,
    },
    {
      'titre': 'Les formes',
      'duree': '10 min',
      'image': '🔷',
      'progression': 0.35,
    },
    {
      'titre': 'Les couleurs',
      'duree': '7 min',
      'image': '🎨',
      'progression': 0.90,
    },
    {
      'titre': 'Les chiffres',
      'duree': '10 min',
      'image': '🔢',
      'progression': 0.50,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Écoute de l'enfant sélectionné depuis le provider Riverpod
    final enfant = ref.watch(
      enfantNotifierProvider.select((state) => state.enfantSelectionne),
    );

    if (enfant == null) {
      return const Scaffold(
        body: Center(
          child: Text('Aucun enfant sélectionné'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // APP BAR
            // ==========================================
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 19,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Activités',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ==========================================
            // FILTRES
            // ==========================================
            SizedBox(
              height: 44,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                children: [
                  _Filtre(
                    titre: 'Toutes',
                    actif: filtreSelectionne == 0,
                    onTap: () {
                      setState(() {
                        filtreSelectionne = 0;
                      });
                    },
                  ),
                  _Filtre(
                    titre: 'En cours',
                    actif: filtreSelectionne == 1,
                    onTap: () {
                      setState(() {
                        filtreSelectionne = 1;
                      });
                    },
                  ),
                  _Filtre(
                    titre: 'Terminées',
                    actif: filtreSelectionne == 2,
                    onTap: () {
                      setState(() {
                        filtreSelectionne = 2;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ==========================================
            // LISTE
            // ==========================================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 25),
                itemCount: activitesDemo.length,
                itemBuilder: (context, index) {
                  final activite = activitesDemo[index];

                  return CarteActiviteEnfant(
                    titre: activite['titre'],
                    duree: activite['duree'],
                    imageUrl: activite['image'],
                    progression: activite['progression'],
                    onTap: () {
                      // Action à effectuer sur l'activité
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// FILTRE (Widget stateless classique)
// =====================================================
class _Filtre extends StatelessWidget {
  final String titre;
  final bool actif;
  final VoidCallback onTap;

  const _Filtre({
    required this.titre,
    required this.actif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: actif ? const Color(0xFF22A653) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: actif ? const Color(0xFF22A653) : const Color(0xFFE5E5E5),
          ),
        ),
        child: Text(
          titre,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: actif ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}