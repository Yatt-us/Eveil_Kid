import 'dart:math';
import 'package:flutter/material.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';

/// Overlay d'animation festive et magique lors du basculement vers l'Espace Enfant.
/// Donne l'impression d'une transformation complète de l'interface et d'entrée dans un univers ludique.
class KidSwitchTransitionOverlay extends StatefulWidget {
  final EnfantModel? enfant;
  final String? enfantNom;
  final VoidCallback onComplete;

  const KidSwitchTransitionOverlay({
    super.key,
    this.enfant,
    this.enfantNom,
    required this.onComplete,
  });

  /// Affiche l'animation festive de transition en plein écran.
  static Future<void> show(
    BuildContext context, {
    EnfantModel? enfant,
    String? enfantNom,
  }) async {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) {
        return KidSwitchTransitionOverlay(
          enfant: enfant,
          enfantNom: enfantNom ?? enfant?.nom,
          onComplete: () {
            if (ctx.mounted) {
              Navigator.of(ctx).pop();
            }
          },
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }

  @override
  State<KidSwitchTransitionOverlay> createState() =>
      _KidSwitchTransitionOverlayState();
}

class _KidSwitchTransitionOverlayState extends State<KidSwitchTransitionOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;
  late final AnimationController _particlesController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _portalRadiusAnimation;
  late final Animation<double> _avatarBounceAnimation;
  late final Animation<double> _fadeTextAnimation;

  final List<_FloatingParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );

    _portalRadiusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _avatarBounceAnimation = Tween<double>(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.1, 0.55, curve: Curves.bounceOut),
      ),
    );

    _fadeTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );

    // Initialise des particules colorées
    for (int i = 0; i < 28; i++) {
      _particles.add(
        _FloatingParticle(
          angle: _random.nextDouble() * 2 * pi,
          distance: 60 + _random.nextDouble() * 180,
          size: 8 + _random.nextDouble() * 16,
          color: _getRandomColor(),
          symbol: _getRandomSymbol(),
        ),
      );
    }

    _mainController.forward();

    // Auto-complétion après l'animation
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  Color _getRandomColor() {
    final colors = [
      KidTheme.primaryGreen,
      KidTheme.playfulAmber,
      KidTheme.playfulSky,
      KidTheme.playfulPurple,
      KidTheme.playfulCoral,
      Colors.pinkAccent,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  String _getRandomSymbol() {
    final symbols = ['⭐', '✨', '🎈', '🎨', '🚀', '🌟', '🎮', '🧩'];
    return symbols[_random.nextInt(symbols.length)];
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.enfantNom ?? widget.enfant?.nom ?? 'Explorateur';

    return GestureDetector(
      onTap: widget.onComplete,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _mainController,
              _pulseController,
              _particlesController,
            ]),
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // ── DISQUE DU PORTAIL MAGIQUE QUI GRANDIT ──
                  Transform.scale(
                    scale: _portalRadiusAnimation.value * 2.5,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            KidTheme.primaryGreen.withValues(alpha: 0.95),
                            const Color(0xFF10B981).withValues(alpha: 0.85),
                            KidTheme.playfulSky.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.45, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // ── PARTICULES & ÉTOILES VOLANTES ──
                  ..._particles.map((particle) {
                    final progress = (_particlesController.value +
                            particle.angle / (2 * pi)) %
                        1.0;
                    final currentDist = particle.distance *
                        (_portalRadiusAnimation.value * (0.8 + 0.3 * progress));
                    final dx = cos(particle.angle + progress * pi / 2) *
                        currentDist;
                    final dy = sin(particle.angle + progress * pi / 2) *
                        currentDist;

                    return Transform.translate(
                      offset: Offset(dx, dy),
                      child: Opacity(
                        opacity: (_fadeTextAnimation.value *
                                (1.0 - (progress - 0.5).abs() * 0.8))
                            .clamp(0.0, 1.0),
                        child: Text(
                          particle.symbol,
                          style: TextStyle(fontSize: particle.size),
                        ),
                      ),
                    );
                  }),

                  // ── CONTENU CENTRAL (AVATAR + MESSAGE) ──
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, _avatarBounceAnimation.value),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 28),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 32,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(
                            color: KidTheme.primaryGreenLight,
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: KidTheme.primaryGreen
                                  .withValues(alpha: 0.35),
                              blurRadius: 30,
                              spreadRadius: 4,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Avatar festif entouré d'une aura animée
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 104 + (_pulseController.value * 8),
                                  height: 104 + (_pulseController.value * 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: KidTheme.primaryGreen
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                Container(
                                  width: 92,
                                  height: 92,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFDCFCE7),
                                    border: Border.all(
                                      color: KidTheme.primaryGreen,
                                      width: 3,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: widget.enfant?.avatarUrl != null &&
                                            widget.enfant!.avatarUrl!.isNotEmpty
                                        ? Image.network(
                                            widget.enfant!.avatarUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                _buildFallbackAvatar(),
                                          )
                                        : _buildFallbackAvatar(),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Badge Monde Enfant
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: KidTheme.playfulAmber,
                                  width: 1.2,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '🎈 ESPACE ENFANT ACTIF',
                                    style: TextStyle(
                                      color: Color(0xFFB45309),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Message de bienvenue enfant
                            Opacity(
                              opacity: _fadeTextAnimation.value,
                              child: Column(
                                children: [
                                  Text(
                                    'Bienvenue $displayName !',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF14532D),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Tes jeux, défis et découvertes magiques t’attendent...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Barre de chargement ludique
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 140,
                                height: 8,
                                child: LinearProgressIndicator(
                                  value: _mainController.value,
                                  backgroundColor: const Color(0xFFDCFCE7),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    KidTheme.primaryGreen,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return const Center(
      child: Icon(
        Icons.face_rounded,
        size: 52,
        color: KidTheme.primaryGreenDark,
      ),
    );
  }
}

class _FloatingParticle {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final String symbol;

  _FloatingParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.symbol,
  });
}
