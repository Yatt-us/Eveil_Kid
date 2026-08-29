import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/core/utils/parental_pin_helper.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/presentation/pages/activites_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/pages/liste_jouets.dart';
import 'package:eveilkid/features/enfant/presentation/pages/liste_souhaits_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/pages/profil_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/pages/progression_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/pages/tutoriels_enfant_page.dart';
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

    final progressValue = _progressValueFrom(enfant);
    final completedCount = enfant.resultatsActivite.length;
    final starsCount = (completedCount * 15) + 30;
    final level = (enfant.age + (completedCount ~/ 5)).clamp(1, 10);

    // Les 6 modules ludiques sans texte, basés sur de grandes icônes iconiques
    final modules = [
      _ModuleItem(
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

                    // Bouton sécurisé Quitter avec code PIN à droite
                    Material(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      elevation: isDark ? 0 : 1,
                      child: InkWell(
                        onTap: () => ParentalPinHelper.exitChildSpace(
                          context: context,
                          ref: ref,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.dividerColor.withValues(
                                alpha: isDark ? 0.3 : 0.2,
                              ),
                              width: 1.2,
                            ),
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ── BANNIÈRE HERO ENFANT (CLIQUABLE VERS LE PROFIL) ──
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const KidThemeScope(child: ProfilEnfantPages()),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                            ? [const Color(0xFF14532D), const Color(0xFF064E3B)]
                            : [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isDark
                              ? theme.dividerColor.withValues(alpha: 0.25)
                              : KidTheme.primaryGreen.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar avec contour festif (et switcher d'enfant si multiple)
                          GestureDetector(
                            onTap: enfants.length > 1
                                ? () => _showChildSwitcherSheet(context, enfants, enfant)
                                : null,
                            child: Container(
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
                                        'Salut ${enfant.nom} !',
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
                                  'Niveau $level • Prêt pour l’aventure ?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
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
                                    minHeight: 6,
                                    backgroundColor: isDark
                                        ? Colors.black26
                                        : Colors.white.withValues(alpha: 0.6),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      KidTheme.primaryGreenDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── TITRE SECTION : MES MONDES ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tes Mondes de Découverte',
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

                // ── GRILLE DES 6 MODULES ENFANTS (100% VISUELLE AVEC GRANDES ICÔNES ET SANS TEXTE) ──
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isTabletOrDesktop = constraints.maxWidth >= 600;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isTabletOrDesktop ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.05,
                      children: modules
                          .map(
                            (module) => _CarteAccueilModule(
                              iconData: module.icon,
                              gradientColors: module.gradientColors,
                              lightBackground: module.lightBackground,
                              couleurIcone: module.accent,
                              onTap: module.onTap,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── SECTION DÉFI DU JOUR / CONTINUER ──
                Text(
                  'Défi du moment',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ) ??
                      TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.dividerColor.withValues(
                        alpha: isDark ? 0.25 : 0.15,
                      ),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.3 : 0.04,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 60,
                          height: 60,
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
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '+20 points à gagner',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? KidTheme.primaryGreenLight
                                    : KidTheme.primaryGreenDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
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
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: const Text('Jouer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KidTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
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

  void _showChildSwitcherSheet(
    BuildContext context,
    List<EnfantModel> enfants,
    EnfantModel activeChild,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Changer de profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                ...enfants.map((item) {
                  final isSelected = item.enfantId == activeChild.enfantId;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: KidTheme.primaryGreen.withValues(alpha: 0.2),
                      child: Text(
                        item.nom.isNotEmpty ? item.nom[0].toUpperCase() : 'E',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: KidTheme.primaryGreenDark,
                        ),
                      ),
                    ),
                    title: Text(
                      item.nom,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                    subtitle: Text('${item.age} ans'),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: KidTheme.primaryGreen,
                          )
                        : null,
                    onTap: () {
                      ref.read(childModeProvider.notifier).switchChild(item);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
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
  final IconData icon;
  final Color lightBackground;
  final List<Color> gradientColors;
  final Color accent;
  final VoidCallback onTap;

  const _ModuleItem({
    required this.icon,
    required this.lightBackground,
    required this.gradientColors,
    required this.accent,
    required this.onTap,
  });
}

/// Carte de module ludique 100% visuelle, ultra-animée avec grande icône pour enfant.
class _CarteAccueilModule extends StatefulWidget {
  final IconData iconData;
  final Color lightBackground;
  final List<Color> gradientColors;
  final Color couleurIcone;
  final VoidCallback onTap;

  const _CarteAccueilModule({
    required this.iconData,
    required this.lightBackground,
    required this.gradientColors,
    required this.couleurIcone,
    required this.onTap,
  });

  @override
  State<_CarteAccueilModule> createState() => _CarteAccueilModuleState();
}

class _CarteAccueilModuleState extends State<_CarteAccueilModule> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark
        ? theme.colorScheme.surface
        : widget.lightBackground;

    final double scale = _isPressed ? 0.91 : 1.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? null
                : LinearGradient(
                    colors: widget.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: cardBgColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark
                  ? theme.dividerColor.withValues(alpha: 0.25)
                  : widget.couleurIcone.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.25 : 0.06,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? theme.dividerColor.withValues(alpha: 0.2)
                      : widget.couleurIcone.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.iconData,
                  color: widget.couleurIcone,
                  size: 46,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pilule d'étoiles interactive animée avec rotation et rebond au tap
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double scale = _isPressed ? 0.92 : 1.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _handleTap,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest
                : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? theme.dividerColor.withValues(alpha: 0.25)
                  : const Color(0xFFFDE68A),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? theme.colorScheme.onSurface
                      : const Color(0xFF92400E),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
