import 'package:firebase_auth/firebase_auth.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilEnfantPages extends ConsumerStatefulWidget {
  const ProfilEnfantPages({super.key});

  @override
  ConsumerState<ProfilEnfantPages> createState() => _ProfilEnfantPagesState();
}

class _ProfilEnfantPagesState extends ConsumerState<ProfilEnfantPages> {
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

    final wishesCount = enfant.souhait.length;
    final activitiesCount = enfant.resultatsActivite.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            children: [
              _HeaderProfil(enfant: enfant),
              const SizedBox(height: 18),
              _StatsGrid(
                wishesCount: wishesCount,
                activitiesCount: activitiesCount,
                isActive: enfant.estActif,
              ),
              const SizedBox(height: 20),
              _InfoCard(enfant: enfant),
              const SizedBox(height: 20),
              _ActionButton(
                label: 'Modifier le profil',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderProfil extends StatelessWidget {
  final EnfantModel enfant;

  const _HeaderProfil({required this.enfant});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: const BoxDecoration(
        color: AppColors.childPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  enfant.estActif ? 'Actif' : 'Inactif',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: ClipOval(
              child: enfant.avatarUrl != null && enfant.avatarUrl!.isNotEmpty
                  ? Image.network(
                      enfant.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _avatarParDefaut(),
                    )
                  : _avatarParDefaut(),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            enfant.nom,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${enfant.age} ans • ${enfant.genre.isNotEmpty ? enfant.genre : 'Enfant'}',
            style: const TextStyle(
              color: Color(0xFFEAFBF0),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarParDefaut() {
    return Container(
      color: const Color(0xFFEAFBF0),
      child: const Icon(
        Icons.child_care_rounded,
        size: 54,
        color: AppColors.childPrimaryDark,
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int wishesCount;
  final int activitiesCount;
  final bool isActive;

  const _StatsGrid({
    required this.wishesCount,
    required this.activitiesCount,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(label: 'Souhaits', value: wishesCount.toString()),
      _StatItem(label: 'Activités', value: activitiesCount.toString()),
      _StatItem(label: 'Statut', value: isActive ? 'OK' : 'Off'),
    ];

    return Row(
      children: List.generate(stats.length, (index) {
        final stat = stats[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    stat.value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StatItem {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});
}

class _InfoCard extends StatelessWidget {
  final EnfantModel enfant;

  const _InfoCard({required this.enfant});

  @override
  Widget build(BuildContext context) {
    final details = [
      _DetailRow(label: 'Nom', value: enfant.nom),
      _DetailRow(label: 'Âge', value: '${enfant.age} ans'),
      _DetailRow(
        label: 'Genre',
        value: enfant.genre.isNotEmpty ? enfant.genre : 'Non renseigné',
      ),
      _DetailRow(
        label: 'Date de naissance',
        value: _formatDate(enfant.dateNaissance),
      ),
      _DetailRow(
        label: 'Souhaits enregistrés',
        value: enfant.souhait.length.toString(),
      ),
      _DetailRow(
        label: 'Progression enregistrée',
        value: enfant.resultatsActivite.length.toString(),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...details.map(
            (detail) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      detail.label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      detail.value,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _DetailRow {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.childPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}