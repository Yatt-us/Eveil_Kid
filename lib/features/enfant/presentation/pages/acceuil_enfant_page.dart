import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/core/utils/parental_pin_helper.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/presentation/pages/activites_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/pages/liste_jouets.dart';
import 'package:eveilkid/features/enfant/presentation/pages/liste_souhaits_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/pages/profil_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/pages/progression_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/pages/tutoriels_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_button.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_card.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';

class AccueilEnfantPage extends ConsumerStatefulWidget {
  final String? initialEnfantId;

  const AccueilEnfantPage({super.key, this.initialEnfantId});

  @override
  ConsumerState<AccueilEnfantPage> createState() => _AccueilEnfantPageState();
}

class _AccueilEnfantPageState extends ConsumerState<AccueilEnfantPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parentId = FirebaseAuth.instance.currentUser?.uid;
      final state = ref.read(enfantNotifierProvider);
      final targetEnfantId =
          widget.initialEnfantId ?? ref.read(childModeProvider).activeChildId;

      if (targetEnfantId != null && targetEnfantId.isNotEmpty) {
        EnfantModel? matched;
        for (final enfant in state.enfants) {
          if (enfant.enfantId == targetEnfantId) {
            matched = enfant;
            break;
          }
        }

        if (matched != null) {
          ref.read(enfantNotifierProvider.notifier).selectionnerEnfant(matched);
          ref.read(childModeProvider.notifier).switchChild(matched);
          return;
        }
      }

      if (parentId != null && parentId.isNotEmpty) {
        ref.read(enfantNotifierProvider.notifier).chargerEnfants(parentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final enfants = ref.watch(
      enfantNotifierProvider.select((state) => state.enfants),
    );

    final enfant = ref.watch(
          enfantNotifierProvider.select((state) => state.enfantSelectionne),
        ) ??
        ref.watch(childModeProvider.select((state) => state.activeChild)) ??
        (enfants.isNotEmpty ? enfants.first : null);

    if (enfant == null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            ParentalPinHelper.exitChildSpace(context: context, ref: ref);
          }
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: KidTheme.primaryGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.child_care_rounded,
                      size: 64,
                      color: KidTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Aucun enfant sélectionné',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sélectionnez un profil enfant depuis l\'espace parent pour commencer l\'aventure.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => ParentalPinHelper.exitChildSpace(
                      context: context,
                      ref: ref,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    label: const Text(
                      'Retour Espace Parent',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final completedCount = enfant.totalActivitesTerminees;
    final starsCount = enfant.totalPoints;
    final level = enfant.niveau;
    final progressValue = enfant.progressionNiveau;
    final pointsForNext = enfant.pointsPourProchainNiveau;

    // Les 5 mondes de découverte avec titres et sous-titres lisibles
    final modules = [
      _ModuleItem(
        title: 'Activités',
        subtitle: 'Défis & Jeux',
        icon: Icons.sports_esports_rounded,
        lightBackground: const Color(0xFFF3E8FF),
        gradientColors: [const Color(0xFFF3E8FF), const Color(0xFFE9D5FF)],
        accent: const Color(0xFF9333EA),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const KidThemeScope(child: ActivitesEnfantPage()),
            ),
          );
        },
      ),
      _ModuleItem(
        title: 'Tutoriels',
        subtitle: 'Vidéos animées',
        icon: Icons.smart_display_rounded,
        lightBackground: const Color(0xFFFFEDD5),
        gradientColors: [const Color(0xFFFFEDD5), const Color(0xFFFED7AA)],
        accent: const Color(0xFFEA580C),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const KidThemeScope(child: TutorielsEnfantPage()),
            ),
          );
        },
      ),
      _ModuleItem(
        title: 'Jouets',
        subtitle: 'Catalogue',
        icon: Icons.smart_toy_rounded,
        lightBackground: const Color(0xFFFEF3C7),
        gradientColors: [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
        accent: const Color(0xFFD97706),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const KidThemeScope(child: ListeJouetsPage()),
            ),
          );
        },
      ),
      _ModuleItem(
        title: 'Trophées',
        subtitle: 'Ma Progression',
        icon: Icons.stars_rounded,
        lightBackground: const Color(0xFFDCFCE7),
        gradientColors: [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)],
        accent: const Color(0xFF16A34A),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const KidThemeScope(child: ProgressionEnfantPage()),
            ),
          );
        },
      ),
      _ModuleItem(
        title: 'Mes Souhaits',
        subtitle: 'Trésors favoris',
        icon: Icons.favorite_rounded,
        lightBackground: const Color(0xFFFCE7F3),
        gradientColors: [const Color(0xFFFCE7F3), const Color(0xFFFBCFE8)],
        accent: const Color(0xFFDB2777),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const KidThemeScope(child: ListeSouhaitsEnfantPage()),
            ),
          );
        },
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ParentalPinHelper.exitChildSpace(context: context, ref: ref);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── BARRE SUPÉRIEURE : PILULE D'ÉTOILES (À GAUCHE) & BOUTON QUITTER PIN (À DROITE) ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pilule d'étoiles interactive à gauche
                    _InteractiveStarPill(
                      starsCount: starsCount,
                      onTap: () => _showStarsInfoSheet(context, starsCount),
                    ),

                    // Bouton sécurisé Quitter avec code PIN à droite (Style Duolingo 3D)
                    _DuolingoPinQuitButton(
                      onTap: () => ParentalPinHelper.exitChildSpace(
                        context: context,
                        ref: ref,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ── BANNIÈRE HERO ENFANT (CLIQUABLE VERS LE PROFIL) STYLE 3D DUOLINGO ──
                DuolingoCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const KidThemeScope(child: ProfilEnfantPages()),
                      ),
                    );
                  },
                  gradientColors: isDark
                      ? [const Color(0xFF14532D), const Color(0xFF064E3B)]
                      : [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)],
                  borderColor: isDark
                      ? const Color(0xFF22C55E).withValues(alpha: 0.4)
                      : KidTheme.primaryGreen.withValues(alpha: 0.4),
                  bottomBorderColor: isDark
                      ? const Color(0xFF064E3B)
                      : KidTheme.primaryGreenDark,
                  borderRadius: 28,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      // Avatar avec contour festif
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: enfant.avatarUrl != null &&
                                  enfant.avatarUrl!.isNotEmpty
                              ? Image.network(
                                  enfant.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _defaultAvatar(theme),
                                )
                              : _defaultAvatar(theme),
                        ),
                      ),
                      const SizedBox(width: 16),
                          // Textes de bienvenue & Progression
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Salut ${enfant.nom.trim().isNotEmpty ? enfant.nom.trim() : 'Champion'} !',
                                        style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w900,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF14532D),
                                          letterSpacing: -0.4,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: isDark
                                          ? const Color(0xFF86EFAC)
                                          : const Color(0xFF166534),
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Niveau $level • $starsCount ⭐',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? const Color(0xFF86EFAC)
                                        : const Color(0xFF166534),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Barre d'étoiles vers niveau suivant
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: progressValue,
                                    minHeight: 7,
                                    backgroundColor: isDark
                                        ? Colors.black26
                                        : Colors.white.withValues(alpha: 0.6),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      KidTheme.primaryGreenDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Plus que $pointsForNext pts pour le niveau ${level + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFF86EFAC)
                                            .withValues(alpha: 0.8)
                                        : const Color(0xFF166534)
                                            .withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                const SizedBox(height: 24),

                // ── TITRE SECTION : MES MONDES ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tes Mondes',
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                          ) ??
                          TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── GRILLE DES 5 MONDES DE DÉCOUVERTE AVEC TITRES ET ICÔNES 3D STYLE DUOLINGO ──
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isTabletOrDesktop = constraints.maxWidth >= 600;
                    final crossAxisCount = isTabletOrDesktop ? 3 : 2;
                    const spacing = 14.0;
                    final totalSpacing = spacing * (crossAxisCount - 1);
                    final cardWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
                    final cardHeight = (cardWidth * 0.95).clamp(138.0, 165.0);

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: modules.map((module) {
                        return SizedBox(
                          key: ValueKey('module_${module.title}'),
                          width: cardWidth,
                          height: cardHeight,
                          child: _CarteAccueilModule(
                            title: module.title,
                            subtitle: module.subtitle,
                            iconData: module.icon,
                            gradientColors: module.gradientColors,
                            lightBackground: module.lightBackground,
                            couleurIcone: module.accent,
                            onTap: module.onTap,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── SECTION DÉFI DU JOUR / CONTINUER (STYLE DUOLINGO 3D) ──
                Text(
                  'Défi du jour',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                      ) ??
                      TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                      ),
                ),

                const SizedBox(height: 12),

                DuolingoCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const KidThemeScope(
                          child: ActivitesEnfantPage(),
                        ),
                      ),
                    );
                  },
                  borderRadius: 24,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 58,
                          height: 58,
                          color: const Color(0xFFF3E8FF),
                          child: const Icon(
                            Icons.extension_rounded,
                            size: 32,
                            color: Color(0xFF9333EA),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Découverte des Formes & Animaux',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '+20 points à gagner',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? KidTheme.primaryGreenLight
                                    : KidTheme.primaryGreenDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      DuolingoButton(
                        text: 'Jouer',
                        icon: Icons.play_arrow_rounded,
                        isCompact: true,
                        colorType: DuolingoButtonColor.green,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KidThemeScope(
                                child: ActivitesEnfantPage(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStarsInfoSheet(BuildContext context, int starsCount) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Poignée
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),

                // Étoile géante
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.surfaceContainerHighest
                        : const Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? theme.dividerColor.withValues(alpha: 0.25)
                          : const Color(0xFFFDE68A),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.star_rounded,
                      size: 52,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Ton Trésor d’Étoiles',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  '$starsCount étoiles gagnées !',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? KidTheme.primaryGreenLight
                        : KidTheme.primaryGreenDark,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Termine des jeux, réponds aux quiz et découvre des tutoriels pour récolter encore plus d’étoiles !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KidTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'C’est parti !',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _progressValueFrom(EnfantModel enfant) {
    final completed = enfant.resultatsActivite.length;
    return ((completed % 5) / 5.0).clamp(0.1, 1.0);
  }

  Widget _defaultAvatar(ThemeData theme) {
    return const Center(
      child: Icon(
        Icons.face_rounded,
        size: 44,
        color: KidTheme.primaryGreenDark,
      ),
    );
  }
}

class _ModuleItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color lightBackground;
  final List<Color> gradientColors;
  final Color accent;
  final VoidCallback onTap;

  const _ModuleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.lightBackground,
    required this.gradientColors,
    required this.accent,
    required this.onTap,
  });
}

/// Carte de module ludique avec icône 3D et texte à fort contraste style Duolingo
class _CarteAccueilModule extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final Color lightBackground;
  final List<Color> gradientColors;
  final Color couleurIcone;
  final VoidCallback onTap;

  const _CarteAccueilModule({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.lightBackground,
    required this.gradientColors,
    required this.couleurIcone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DuolingoCard(
      onTap: onTap,
      borderRadius: 24,
      bottomThickness: 4.5,
      gradientColors: isDark ? null : gradientColors,
      backgroundColor: isDark ? theme.colorScheme.surface : lightBackground,
      borderColor: isDark
          ? const Color(0xFF383842)
          : couleurIcone.withValues(alpha: 0.35),
      bottomBorderColor: isDark
          ? const Color(0xFF1E1E24)
          : couleurIcone.withValues(alpha: 0.65),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Cercle Icône 3D
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? const Color(0xFF475569)
                    : couleurIcone.withValues(alpha: 0.25),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                iconData,
                color: couleurIcone,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 2. Titre du monde
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),

          // 3. Sous-titre descriptif
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFCBD5E1) : couleurIcone,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton Quitter PIN sécurisé 3D tactile style Duolingo
class _DuolingoPinQuitButton extends StatefulWidget {
  final VoidCallback onTap;

  const _DuolingoPinQuitButton({required this.onTap});

  @override
  State<_DuolingoPinQuitButton> createState() => _DuolingoPinQuitButtonState();
}

class _DuolingoPinQuitButtonState extends State<_DuolingoPinQuitButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF222228) : Colors.white;
    final border = isDark ? const Color(0xFF383842) : const Color(0xFFE2E8F0);
    final bottomBorder = isDark ? const Color(0xFF18181C) : const Color(0xFFCBD5E1);

    const double bottomThickness = 3.0;
    final double verticalShift = _isPressed ? 2.0 : 0.0;
    final double activeBottomEdge = _isPressed ? 1.0 : bottomThickness;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutQuad,
        margin: EdgeInsets.only(
          top: verticalShift,
          bottom: bottomThickness - verticalShift,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 1.5),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: bottomBorder,
                blurRadius: 0,
                offset: const Offset(0, bottomThickness),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: KidTheme.primaryGreenDark,
            ),
            const SizedBox(width: 5),
            Text(
              'Quitter',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pilule d'étoiles interactive animée 3D style Duolingo
class _InteractiveStarPill extends StatefulWidget {
  final int starsCount;
  final VoidCallback onTap;

  const _InteractiveStarPill({
    required this.starsCount,
    required this.onTap,
  });

  @override
  State<_InteractiveStarPill> createState() => _InteractiveStarPillState();
}

class _InteractiveStarPillState extends State<_InteractiveStarPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _starAnimController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _starAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _starAnimController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _starAnimController.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const bg = Color(0xFFFEF3C7);
    const border = Color(0xFFFDE68A);
    const bottomBorder = Color(0xFFD97706);

    const double bottomThickness = 3.0;
    final double verticalShift = _isPressed ? 2.0 : 0.0;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _handleTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutQuad,
        margin: EdgeInsets.only(
          top: verticalShift,
          bottom: bottomThickness - verticalShift,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.5) : bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border, width: 1.5),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: bottomBorder,
                blurRadius: 0,
                offset: const Offset(0, bottomThickness),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 0.08)
                  .chain(CurveTween(curve: Curves.elasticOut))
                  .animate(_starAnimController),
              child: const Icon(
                Icons.star_rounded,
                size: 20,
                color: Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${widget.starsCount}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF92400E),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
