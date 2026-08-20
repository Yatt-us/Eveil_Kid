import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/en_tete_enfant.dart';
import '../widgets/carte_activite_enfant.dart';
import 'activites_enfant_page.dart';

class AccueilEnfantPage extends StatelessWidget {
  const AccueilEnfantPage({super.key});

  static const Color green = Color(0xFF22A653);
  static const Color purple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final enfantProvider = context.watch<EnfantProvider>();
    final enfant = enfantProvider.enfantSelectionne;

    if (enfant == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Aucun enfant sélectionné',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================
              // EN-TÊTE
              // ==========================

              EnTeteEnfant(
                enfant: enfant,
              ),

              const SizedBox(height: 22),

              // ==========================
              // 4 GRANDES CARTES
              // ==========================

              Row(
                children: [
                  Expanded(
                    child: _CarteAccueil(
                      icon: Icons.extension_rounded,
                      titre: 'Activités',
                      sousTitre: 'Apprendre en jouant',
                      couleur: const Color(0xFFF1E8FF),
                      iconColor: purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ActivitesEnfantPage(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _CarteAccueil(
                      icon: Icons.play_circle_fill_rounded,
                      titre: 'Tutoriels',
                      sousTitre: 'Apprendre autrement',
                      couleur: const Color(0xFFFFEFE4),
                      iconColor: const Color(0xFFF28C38),
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _CarteAccueil(
                      icon: Icons.auto_awesome_rounded,
                      titre: 'Favoris',
                      sousTitre: 'Mes préférés',
                      couleur: const Color(0xFFFFF7DF),
                      iconColor: const Color(0xFFF0A52B),
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _CarteAccueil(
                      icon: Icons.emoji_events_rounded,
                      titre: 'Progression',
                      sousTitre: 'Mes progrès',
                      couleur: const Color(0xFFEAF5FF),
                      iconColor: const Color(0xFF4C9FE8),
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // ==========================
              // TITRE
              // ==========================

              const Text(
                'Activités recommandées',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 12),

              // ==========================
              // ACTIVITÉ RECOMMANDÉE
              // ==========================

              CarteActiviteEnfant(
                titre: 'Les couleurs',
                duree: '10 minutes',
                imageUrl: '🎨',
                progression: 0.70,
                onTap: () {},
              ),

              CarteActiviteEnfant(
                titre: 'Les animaux',
                duree: '15 minutes',
                imageUrl: '🦁',
                progression: 0.40,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// CARTE DES 4 FONCTIONNALITÉS DE L'ACCUEIL
// =====================================================

class _CarteAccueil extends StatelessWidget {
  final IconData icon;
  final String titre;
  final String sousTitre;
  final Color couleur;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CarteAccueil({
    required this.icon,
    required this.titre,
    required this.sousTitre,
    required this.couleur,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 125,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: couleur,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 25,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              titre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              sousTitre,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}