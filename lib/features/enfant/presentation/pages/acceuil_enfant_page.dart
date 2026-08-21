import 'package:firebase_auth/firebase_auth.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/presentation/pages/activites_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/pages/liste_jouets.dart';
import 'package:eveilkid/features/enfant/presentation/pages/profil_enfant_page.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:eveilkid/features/tutoriels/presentation/pages/tutoriel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccueilEnfantPage extends ConsumerStatefulWidget {
  const AccueilEnfantPage({super.key});

  @override
  ConsumerState<AccueilEnfantPage> createState() => _AccueilEnfantPageState();
}

class _AccueilEnfantPageState extends ConsumerState<AccueilEnfantPage> {
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

  @override
  Widget build(BuildContext context) {
    final enfant = ref.watch(
      enfantNotifierProvider.select((state) => state.enfantSelectionne),
    );

    if (enfant == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Aucun enfant sélectionné',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final progressValue = _progressValueFrom(enfant);
    final subtitle = enfant.age >= 6 ? 'Prêt pour de nouvelles aventures ?' : 'Tu es en pleine découverte !';

    final modules = [
      _ModuleItem(
        title: 'Activités',
        subtitle: 'Apprendre en jouant',
        icon: Icons.sports_esports_rounded,
        background: const Color(0xFFF4EFFD),
        accent: AppColors.primary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ActivitesEnfantPage()),
          );
        },
      ),
      _ModuleItem(
        title: 'Tutoriels',
        subtitle: 'Découvrir et observer',
        icon: Icons.play_arrow_rounded,
        background: const Color(0xFFFFF2EC),
        accent: const Color(0xFFF97316),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TutorielPage()),
          );
        },
      ),
      _ModuleItem(
        title: 'Jouets',
        subtitle: 'Explorer et jouer',
        icon: Icons.smart_toy_rounded,
        background: const Color(0xFFFFFBEB),
        accent: const Color(0xFFF59E0B),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ListeJouetsPage()),
          );
        },
      ),
      _ModuleItem(
        title: 'Profil',
        subtitle: 'Ton espace perso',
        icon: Icons.face_rounded,
        background: const Color(0xFFEFF6FF),
        accent: const Color(0xFF3B82F6),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilEnfantPages()),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.childPrimary,
                        width: 2.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: enfant.avatarUrl != null && enfant.avatarUrl!.isNotEmpty
                            ? Image.network(
                                enfant.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _defaultAvatar(),
                              )
                            : _defaultAvatar(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Salut ${enfant.nom} !',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.childBackground,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${enfant.age} ans • ${enfant.estActif ? 'Actif' : 'Inactif'}',
                            style: const TextStyle(
                              color: AppColors.childPrimaryDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.92,
                children: modules
                    .map(
                      (module) => _CarteAccueilModule(
                        iconData: module.icon,
                        titre: module.title,
                        sousTitre: module.subtitle,
                        couleurFond: module.background,
                        couleurIcone: module.accent,
                        onTap: module.onTap,
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 28),

              const Text(
                'Continuer ton apprentissage',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 72,
                        height: 72,
                        color: const Color(0xFFFEF3C7),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          size: 38,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${enfant.nom} • niveau ${enfant.age + 1}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${(progressValue * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Activités réalisées • ${enfant.resultatsActivite.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFF3E8FF),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.childPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.childPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _progressValueFrom(EnfantModel enfant) {
    final completed = enfant.resultatsActivite.length;
    return (completed / 10).clamp(0.0, 1.0);
  }

  Widget _defaultAvatar() {
    return Container(
      color: const Color(0xFFF3E8FF),
      child: const Icon(
        Icons.person,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }
}

class _ModuleItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color accent;
  final VoidCallback onTap;

  const _ModuleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.accent,
    required this.onTap,
  });
}

class _CarteAccueilModule extends StatelessWidget {
  final IconData iconData;
  final String titre;
  final String sousTitre;
  final Color couleurFond;
  final Color couleurIcone;
  final VoidCallback onTap;

  const _CarteAccueilModule({
    required this.iconData,
    required this.titre,
    required this.sousTitre,
    required this.couleurFond,
    required this.couleurIcone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: couleurFond,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(iconData, color: couleurIcone, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                titre,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sousTitre,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
