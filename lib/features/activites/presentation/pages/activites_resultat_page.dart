import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../providers/activite_game_provider.dart';

/// Page de célébration et d'affichage des scores de fin de quiz.
class ActivitesResultatPage extends ConsumerWidget {
  const ActivitesResultatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(activiteGameProvider);
    final gameNotifier = ref.read(activiteGameProvider.notifier);

    final total = gameState.totalQuestions;
    final bonnesReponses = gameState.nombreBonnesReponses;
    final mauvaisesReponses = gameState.nombreMauvaisesReponses;
    final points = gameState.pointsGagnes;
    final double ratio = gameState.scoreRatio;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // ── Décorations d'arrière-plan (Confettis) ────────────────────────
          Positioned(top: 60, left: 30, child: _buildConfetti(12, Colors.white24)),
          Positioned(top: 100, right: 40, child: _buildConfetti(8, const Color(0xFFFFD700).withValues(alpha: 0.4))),
          Positioned(top: 180, left: 60, child: _buildConfetti(10, Colors.white24)),
          Positioned(bottom: 180, right: 30, child: _buildConfetti(14, Colors.white24)),
          Positioned(bottom: 120, left: 40, child: _buildConfetti(9, const Color(0xFFFFD700).withValues(alpha: 0.4))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // ── Badge & Trophée dynamique ──────────────────────────────
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcone(ratio),
                      color: const Color(0xFFFFD700),
                      size: 60,
                    ),
                  ),

                  AppSpacing.verticalMd,

                  // ── Titre et Encouragement ────────────────────────────────
                  Text(
                    _getTitre(ratio),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getSousTitre(ratio),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),

                  AppSpacing.verticalLg,

                  // ── Carte Blanche des 4 Quadrants de Score ─────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.card,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuadrantItem(
                                titre: 'Score',
                                valeur: '$bonnesReponses / $total',
                                couleurValeur: AppColors.textPrimary,
                                icone: Icons.emoji_events_rounded,
                                couleurIcone: AppColors.accent,
                              ),
                            ),
                            Container(width: 1, height: 48, color: AppColors.border),
                            Expanded(
                              child: _buildQuadrantItem(
                                titre: 'Points gagnés',
                                valeur: '+$points pts',
                                couleurValeur: AppColors.primary,
                                icone: Icons.stars_rounded,
                                couleurIcone: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 1, color: AppColors.border),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuadrantItem(
                                titre: 'Bonnes réponses',
                                valeur: '$bonnesReponses',
                                couleurValeur: const Color(0xFF00A859),
                                icone: Icons.check_circle_rounded,
                                couleurIcone: const Color(0xFF00A859),
                              ),
                            ),
                            Container(width: 1, height: 48, color: AppColors.border),
                            Expanded(
                              child: _buildQuadrantItem(
                                titre: 'Erreurs',
                                valeur: '$mauvaisesReponses',
                                couleurValeur: AppColors.danger,
                                icone: Icons.cancel_rounded,
                                couleurIcone: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Bouton Voir le corrigé ─────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                      onPressed: () {
                        context.push(AppRoutes.activitesCorrige);
                      },
                      child: const Text(
                        'Voir le corrigé détaillé',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  AppSpacing.verticalSm,

                  // ── Boutons d'action secondaires ───────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.replay_rounded, color: Colors.white, size: 18),
                        label: const Text(
                          'Recommencer',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          gameNotifier.recommencerActivite();
                          context.pushReplacement(AppRoutes.activitesPlay);
                        },
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 18),
                        label: const Text(
                          'Toutes les activités',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          gameNotifier.reinitialiserSession();
                          context.go(AppRoutes.activites);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcone(double ratio) {
    if (ratio >= 0.8) return Icons.star_rounded;
    if (ratio >= 0.5) return Icons.thumb_up_alt_rounded;
    return Icons.refresh_rounded;
  }

  String _getTitre(double ratio) {
    if (ratio == 1.0) return 'Parfait ! 🏆';
    if (ratio >= 0.7) return 'Félicitations ! 🌟';
    if (ratio >= 0.5) return 'Bien joué ! 👍';
    return 'Poursuis tes efforts ! 💪';
  }

  String _getSousTitre(double ratio) {
    if (ratio == 1.0) return 'Un sans-faute remarquable !';
    if (ratio >= 0.7) return 'Tu as terminé l\'activité avec un très bon score.';
    if (ratio >= 0.5) return 'Tu as obtenu la moyenne, continue comme ça !';
    return 'Révise le corrigé ci-dessous et retente ta chance.';
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
            const SizedBox(width: 6),
            Text(
              titre,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          valeur,
          style: TextStyle(
            color: couleurValeur,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ],
    );
  }
}
