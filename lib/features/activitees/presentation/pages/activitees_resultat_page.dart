import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

import '../providers/activitees_provider.dart';
import 'activitees_corrige_page.dart';
import 'activitees_play_page.dart';

class ActiviteesResultatPage extends StatelessWidget {
  const ActiviteesResultatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Optimization: Read state without triggering continuous rebuilds
    final provider = context.read<ActiviteesProvider>();
    final activite = provider.activiteesEnCours;

    final int total = activite?.questions.length ?? activite?.totalQuestions ?? 0;
    final int bonnesReponses = provider.nombreBonnesReponses;
    final int mauvaisesReponses = provider.nombreMauvaisesReponses;
    final int points = provider.pointsGagnes;

    final double ratio = total > 0 ? bonnesReponses / total : 0.0;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // --- DÉCORATIONS CONFETTIS ---
          Positioned(top: 60, left: 30, child: _buildConfetti(12, Colors.white24)),
          Positioned(top: 100, right: 40, child: _buildConfetti(8, const Color(0xFFFFD700).withValues(alpha: 0.4))),
          Positioned(top: 180, left: 60, child: _buildConfetti(10, Colors.white24)),
          Positioned(bottom: 180, right: 30, child: _buildConfetti(14, Colors.white24)),
          Positioned(bottom: 120, left: 40, child: _buildConfetti(9, const Color(0xFFFFD700).withValues(alpha: 0.4))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.medium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Badge / Icône dynamique
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcone(ratio),
                      color: const Color(0xFFFFD700),
                      size: 68,
                    ),
                  ),

                  AppSpacing.verticalMedium,

                  // Titre dynamique
                  Text(
                    _getTitre(ratio),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.verticalXSmall,
                  
                  // Sous-titre dynamique
                  Text(
                    _getSousTitre(ratio),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                    ),
                  ),

                  AppSpacing.verticalLarge,

                  // --- CARTE BLANCHE À 4 QUADRANTS ---
                  Container(
                    padding: const EdgeInsets.all(AppPadding.medium),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuadrantItem(
                                titre: 'Score',
                                valeur: '$bonnesReponses/$total',
                                couleurValeur: AppColors.textPrimary,
                                icone: Icons.emoji_events_outlined,
                                couleurIcone: AppColors.accent,
                              ),
                            ),
                            Container(width: 1, height: 50, color: const Color(0xFFEEEEEE)),
                            Expanded(
                              child: _buildQuadrantItem(
                                titre: 'Points gagnés',
                                valeur: '+$points',
                                couleurValeur: AppColors.primary,
                                icone: Icons.stars_rounded,
                                couleurIcone: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, thickness: 1, color: Color(0xFFEEEEEE)),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuadrantItem(
                                titre: 'Bonnes réponses',
                                valeur: '$bonnesReponses',
                                couleurValeur: AppColors.primary,
                                icone: Icons.check_circle_outline,
                                couleurIcone: AppColors.primary,
                              ),
                            ),
                            Container(width: 1, height: 50, color: const Color(0xFFEEEEEE)),
                            Expanded(
                              child: _buildQuadrantItem(
                                titre: 'Mauvaises réponses',
                                valeur: '$mauvaisesReponses',
                                couleurValeur: AppColors.error,
                                icone: Icons.cancel_outlined,
                                couleurIcone: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bouton principal : Voir le corrigé
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.circular),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ActiviteesCorrigePage(),
                          ),
                        );
                      },
                      child: Text(
                        'Voir le corrigé',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  AppSpacing.verticalXSmall,

                  // Bouton secondaire : Recommencer
                  TextButton(
                    onPressed: () {
                      context.read<ActiviteesProvider>().recommencerActivite();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ActiviteesPlayPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Recommencer',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  AppSpacing.verticalSmall,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER METHODS INSIDE CLASS BODY ---

  IconData _getIcone(double ratio) {
    if (ratio >= 0.8) return Icons.star_rounded;
    if (ratio >= 0.5) return Icons.thumb_up_alt_rounded;
    return Icons.refresh_rounded;
  }

  String _getTitre(double ratio) {
    if (ratio == 1.0) return 'Parfait !';
    if (ratio >= 0.7) return 'Félicitations !';
    if (ratio >= 0.5) return 'Bien joué !';
    return 'Poursuis tes efforts !';
  }

  String _getSousTitre(double ratio) {
    if (ratio >= 0.7) return 'Tu as terminé l\'activité avec succès';
    if (ratio >= 0.5) return 'Tu as obtenu la moyenne !';
    return 'Révise le corrigé et réessaye !';
  }

  Widget _buildConfetti(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildQuadrantItem({
    required String titre,
    required String valeur,
    required Color couleurValeur,
    required IconData icone,
    required Color couleurIcone,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 16, color: couleurIcone),
            AppSpacing.horizontalXSmall,
            Text(
              titre,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        AppSpacing.verticalXSmall,
        Text(
          valeur,
          style: AppTextStyles.h2.copyWith(
            color: couleurValeur,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}