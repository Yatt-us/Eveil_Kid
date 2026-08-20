import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilEnfantPage extends StatelessWidget {
  const ProfilEnfantPage({super.key});

  static const Color green = Color(0xFF22A653);

  @override
  Widget build(BuildContext context) {
    final enfantProvider = context.watch<EnfantProvider>();
    final enfant = enfantProvider.enfantSelectionne;

    if (enfant == null) {
      return const Scaffold(
        body: Center(
          child: Text('Aucun enfant sélectionné'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // HEADER VERT
            // ==========================================

            Container(
              width: double.infinity,
              height: 265,
              decoration: const BoxDecoration(
                color: green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Stack(
                children: [
                  // Bouton retour
                  Positioned(
                    left: 8,
                    top: 8,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  // Profil
                  Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // Avatar
                        Container(
                          width: 105,
                          height: 105,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEBDFFF),
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: ClipOval(
                            child: enfant.avatarUrl != null &&
                                    enfant.avatarUrl!.isNotEmpty
                                ? Image.network(
                                    enfant.avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) {
                                      return _avatarParDefaut();
                                    },
                                  )
                                : _avatarParDefaut(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          enfant.nom,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          '${enfant.age} ans',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // INFORMATIONS
            // ==========================================

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 15),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _LigneProfil(
                            icon: Icons.person_outline,
                            titre: 'Informations',
                            onTap: () {
                              // Ouvrir les informations
                              // détaillées de l'enfant.
                            },
                          ),

                          const Divider(
                            height: 1,
                            indent: 18,
                            endIndent: 18,
                          ),

                          _LigneProfil(
                            icon: Icons.bar_chart_rounded,
                            titre: 'Ma progression',
                            onTap: () {
                              // Naviguer vers la progression.
                            },
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ======================================
                    // BOUTON MODIFIER
                    // ======================================

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO :
                          // ouvrir la page de modification
                          // de l'enfant.
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Modifier',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarParDefaut() {
    return Container(
      color: const Color(0xFFEBDFFF),
      child: const Icon(
        Icons.child_care,
        size: 55,
        color: Color(0xFF8B5CF6),
      ),
    );
  }
}

// =====================================================
// LIGNE DU PROFIL
// =====================================================

class _LigneProfil extends StatelessWidget {
  final IconData icon;
  final String titre;
  final VoidCallback onTap;

  const _LigneProfil({
    required this.icon,
    required this.titre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 21,
              color: Colors.grey.shade700,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                titre,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }
}