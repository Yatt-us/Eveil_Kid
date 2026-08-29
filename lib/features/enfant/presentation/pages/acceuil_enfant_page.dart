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

class _AccueilEnfantPageState extends ConsumerState<AccueilEnfantPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatAnimController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _floatAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _floatAnimController,
        curve: Curves.easeInOut,
      ),
    );

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
  void dispose() {
    _floatAnimController.dispose();
    super.dispose();
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

    // Les 6 modules ludiques de l'espace enfant
    final modules = [
      _ModuleItem(
        title: 'Activités',
        subtitle: 'Jeux & Défis',
        badge: '$completedCount faites',
        icon: Icons.sports_esports_rounded,
        lightBackground: const Color(0xFFF3E8FF),
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
        subtitle: 'Vidéos ludiques',
        badge: 'Regarder',
        icon: Icons.smart_display_rounded,
        lightBackground: const Color(0xFFFFEDD5),
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
        subtitle: 'Explorer & Rêver',
        badge: 'Catalogue',
        icon: Icons.smart_toy_rounded,
        lightBackground: const Color(0xFFFEF3C7),
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
        title: 'Progression',
        subtitle: 'Étoiles & Badges',
        badge: 'Niveau $level',
        icon: Icons.stars_rounded,
        lightBackground: const Color(0xFFDCFCE7),
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
        subtitle: 'Idées cadeaux',
        badge: '${enfant.souhait.length} jouets',
        icon: Icons.favorite_rounded,
        lightBackground: const Color(0xFFFCE7F3),
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
      _ModuleItem(
        title: 'Mon Profil',
        subtitle: 'Avatar & Infos',
        badge: '${enfant.age} ans',
        icon: Icons.face_rounded,
        lightBackground: const Color(0xFFE0F2FE),
        accent: const Color(0xFF0284C7),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const KidThemeScope(child: ProfilEnfantPages()),
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
                // ── BARRE SUPÉRIEURE : SÉLECTEUR D'ENFANT & BOUTON QUITTER PIN ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge Espace Enfant & Switcher d'enfant
                    InkWell(
                      onTap: enfants.length > 1
                          ? () => _showChildSwitcherSheet(context, enfants, enfant)
                          : null,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: KidTheme.primaryGreen.withValues(
                            alpha: isDark ? 0.25 : 0.15,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: KidTheme.primaryGreen.withValues(
                              alpha: isDark ? 0.4 : 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '🎈 Espace Enfant',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: KidTheme.primaryGreenDark,
                              ),
                            ),
                            if (enfants.length > 1) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.swap_horiz_rounded,
                                size: 16,
                                color: KidTheme.primaryGreenDark,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Pilule étoiles + Bouton de sortie sécurisé
                    Row(
                      children: [
                        // Compteur d'étoiles gagnées
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFDE68A),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$starsCount',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Bouton sécurisé Quitter avec code PIN
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
                                vertical: 6,
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
                  ],
                ),

                const SizedBox(height: 18),

                // ── BANNIÈRE HERO ENFANT AVEC AVATAR REBONDISSANT ──
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: child,
                    );
                  },
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
                        color: KidTheme.primaryGreen.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: KidTheme.primaryGreen.withValues(
                            alpha: isDark ? 0.25 : 0.12,
                          ),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar enfant avec couronne ou anneau coloré
                        Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: KidTheme.primaryGreen,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Salut ${enfant.nom} ! 🌟',
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

                const SizedBox(height: 24),

                // ── TITRE SECTION : MES UNIVERS ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tes Mondes de Découverte ✨',
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

                // ── GRILLE DES 6 MODULES ENFANTS ──
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.96,
                  children: modules
                      .map(
                        (module) => _CarteAccueilModule(
                          iconData: module.icon,
                          titre: module.title,
                          sousTitre: module.subtitle,
                          badge: module.badge,
                          lightBackground: module.lightBackground,
                          couleurIcone: module.accent,
                          onTap: module.onTap,
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 24),

                // ── SECTION DÉFI DU JOUR / CONTINUER ──
                Text(
                  'Défi du moment 🏆',
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
                        borderRadius: BorderRadius.circular(16),
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
                              '+20 étoiles à gagner ! ⭐',
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
                      ElevatedButton(
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
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Jouer ▶'),
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
                const SizedBox(height: 16),
                const Text(
                  'Changer de profil enfant 🎈',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
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
  final String badge;
  final IconData icon;
  final Color lightBackground;
  final Color accent;
  final VoidCallback onTap;

  const _ModuleItem({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.lightBackground,
    required this.accent,
    required this.onTap,
  });
}

class _CarteAccueilModule extends StatelessWidget {
  final IconData iconData;
  final String titre;
  final String sousTitre;
  final String badge;
  final Color lightBackground;
  final Color couleurIcone;
  final VoidCallback onTap;

  const _CarteAccueilModule({
    required this.iconData,
    required this.titre,
    required this.sousTitre,
    required this.badge,
    required this.lightBackground,
    required this.couleurIcone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
        : lightBackground;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? theme.dividerColor.withValues(alpha: 0.25)
                  : couleurIcone.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : couleurIcone).withValues(
                  alpha: isDark ? 0.2 : 0.06,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: couleurIcone.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.25 : 0.05,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(iconData, color: couleurIcone, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                titre,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sousTitre,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
