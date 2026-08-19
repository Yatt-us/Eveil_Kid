import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

import '../models/activitees_enums.dart';
import '../models/activitees_model.dart';
import '../providers/activitees_provider.dart';
import 'activitees_play_page.dart';

class ActiviteesListPage extends StatelessWidget {
  const ActiviteesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActiviteesProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 28),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Activités',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          AppSpacing.verticalMedium,

          // --- BARRE DE FILTRES COMPACTE ---
          _buildFiltresBarre(provider),

          AppSpacing.verticalLarge,

          // --- GESTION DU CONTENU (Loader / Erreur / Liste) ---
          Expanded(
            child: _buildContenuCentral(provider, context),
          ),
        ],
      ),

      // --- BARRE DE NAVIGATION INFÉRIEURE ---
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- GESTION DES ÉTATS DE CHARGEMENT ET D'ERREUR ---
  Widget _buildContenuCentral(ActiviteesProvider provider, BuildContext context) {
    if (provider.estEnChargement) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.erreur != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              AppSpacing.verticalMedium,
              Text(
                provider.erreur!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              AppSpacing.verticalMedium,
              ElevatedButton(
                onPressed: () => provider.chargerActivitees(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.activiteesFiltrees.isEmpty) {
      return Center(
        child: Text(
          'Aucune activité disponible',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.medium,
      ),
      itemCount: provider.activiteesFiltrees.length,
      separatorBuilder: (_, __) => AppSpacing.verticalMedium,
      itemBuilder: (context, index) {
        final activite = provider.activiteesFiltrees[index];
        return _buildCarteActivitee(context, activite, provider);
      },
    );
  }

  // --- FILTRES : Puces ajustées au texte ---
  Widget _buildFiltresBarre(ActiviteesProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.medium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildPuceFiltre(
            libelle: 'Toutes',
            estSelectionne: provider.filtreActif == StatutActivitee.toutes,
            onTap: () => provider.changerFiltre(StatutActivitee.toutes),
          ),
          AppSpacing.horizontalSmall,
          _buildPuceFiltre(
            libelle: 'En cours',
            estSelectionne: provider.filtreActif == StatutActivitee.enCours,
            onTap: () => provider.changerFiltre(StatutActivitee.enCours),
          ),
          AppSpacing.horizontalSmall,
          _buildPuceFiltre(
            libelle: 'Terminées',
            estSelectionne: provider.filtreActif == StatutActivitee.terminees,
            onTap: () => provider.changerFiltre(StatutActivitee.terminees),
          ),
        ],
      ),
    );
  }

  Widget _buildPuceFiltre({
    required String libelle,
    required bool estSelectionne,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.medium,
          vertical: AppPadding.small,
        ),
        decoration: BoxDecoration(
          color: estSelectionne ? AppColors.primary : const Color(0xFFF3F3F5),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Text(
          libelle,
          style: AppTextStyles.button.copyWith(
            color: estSelectionne ? Colors.white : AppColors.textSecondary,
            fontWeight: estSelectionne ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // --- CARTE DE THÈME (Fidèle à la maquette) ---
  Widget _buildCarteActivitee(
    BuildContext context,
    ActiviteesModel activite,
    ActiviteesProvider provider,
  ) {
    final estTerminee = activite.statut == StatutActivitee.terminees;

    return GestureDetector(
      onTap: () {
        provider.demarrerActivite(activite);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ActiviteesPlayPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppPadding.medium),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            // Vignette Image avec fond coloré doux selon la catégorie
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _getCouleurFondCategorie(activite.titre),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                child: Image.asset(
                  activite.cheminImage,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image,
                    size: 36,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            AppSpacing.horizontalMedium,

            // Titre & Sous-titre
            Expanded(
              child: Column(
                crossAlignment: CrossAlignment.start,
                children: [
                  Text(
                    activite.titre,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  AppSpacing.verticalXSmall,
                  Text(
                    '${activite.totalQuestions} questions',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Indicateur de droite : Cercle % OU Coche verte
            if (estTerminee) ...[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00A859),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  AppSpacing.verticalXSmall,
                  Text(
                    'Terminée',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF00A859),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            ] else ...[
              SizedBox(
                width: 58,
                height: 58,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: CircularProgressIndicator(
                        value: activite.progression,
                        backgroundColor: const Color(0xFFEBEBEB),
                        color: AppColors.primary,
                        strokeWidth: 4,
                      ),
                    ),
                    Text(
                      '${(activite.progression * 100).toInt()}%',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Couleur de fond de la vignette adaptée au thème de la carte
  Color _getCouleurFondCategorie(String titre) {
    switch (titre.toLowerCase()) {
      case 'les animaux':
        return const Color(0xFFFFF7EA);
      case 'les fruits':
        return const Color(0xFFFFECEC);
      case 'les transports':
        return const Color(0xFFEBF3FF);
      case 'les formes':
        return const Color(0xFFE8F8F5);
      case 'les couleurs':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  // --- BARRE DE NAVIGATION INFÉRIEURE ---
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: AppTextStyles.caption,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view),
          activeIcon: Icon(Icons.grid_view_rounded),
          label: 'Activités',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb_outline),
          activeIcon: Icon(Icons.lightbulb),
          label: 'Tutoriels',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}