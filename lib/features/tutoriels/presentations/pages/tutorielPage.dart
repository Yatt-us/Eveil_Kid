import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentations/widgets/etat/tuto_etat.dart';
import 'package:eveilkid/features/tutoriels/presentations/widgets/tutoriel_filtrage.dart';
import 'package:eveilkid/features/tutoriels/presentations/widgets/tutoriel_search.dart';
import 'package:eveilkid/features/tutoriels/presentations/widgets/tutoriel_widget.dart';
import 'package:eveilkid/features/tutoriels/providers/tutorielProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TutorielPage extends ConsumerStatefulWidget {
  const TutorielPage({super.key});

  @override
  ConsumerState<TutorielPage> createState() =>
      _TutorielPageState();
}

class _TutorielPageState
    extends ConsumerState<TutorielPage> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedAge = 'Tous';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ==========================================
  // RECHERCHE
  // ==========================================

  List<Tutoriel> _filterTutoriels(
    List<Tutoriel> tutoriels,
  ) {
    final search = searchController.text
        .trim()
        .toLowerCase();

    return tutoriels.where((tutoriel) {

      // -----------------------------
      // Recherche par titre
      // -----------------------------
      final matchesSearch =
          search.isEmpty ||
          tutoriel.titre
              .toLowerCase()
              .contains(search);

      // -----------------------------
      // Filtre par âge
      // -----------------------------
      bool matchesAge = true;

      if (selectedAge == 'Age 4-6') {
        matchesAge =
            tutoriel.ageMinimum.toInt() <= 6 &&
            tutoriel.ageMaximum.toInt() >= 4;
      }

      if (selectedAge == 'Age 7-9') {
        matchesAge =
            tutoriel.ageMinimum.toInt() <= 9 &&
            tutoriel.ageMaximum.toInt() >= 7;
      }

      if (selectedAge == 'Age 10-12') {
        matchesAge =
            tutoriel.ageMinimum.toInt() <= 12 &&
            tutoriel.ageMaximum.toInt() >= 10;
      }

      return matchesSearch && matchesAge;
    }).toList();
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final tutorielsAsync =
        ref.watch(tutorielsProvider);

    return Scaffold(
      backgroundColor: Colors.white,

      // ======================================
      // APP BAR
      // ======================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        centerTitle: true,

        title: const Text(
          'Tutoriels',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ======================================
      // BODY
      // ======================================

      body: tutorielsAsync.when(

        // ====================================
        // DATA
        // ====================================

        data: (tutoriels) {
          if (tutoriels.isEmpty) {
            return const TutorielEmptyState();
          }

          final filteredTutoriels =
              _filterTutoriels(tutoriels);

          return Column(
            children: [

              // ==============================
              // RECHERCHE
              // ==============================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),

                child: TutorielSearchBar(
                  controller: searchController,

                  onChanged: (_) {
                    setState(() {});
                  },

                  onFilterPressed: () {
                    _showFilterDialog();
                  },
                ),
              ),

              // ==============================
              // FILTRE AGE
              // ==============================

              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 25,
                ),

                child: TutorielAgeFilter(
                  selectedAge: selectedAge,

                  onSelected: (age) {
                    setState(() {
                      selectedAge = age;
                    });
                  },
                ),
              ),

              // ==============================
              // RESULTAT
              // ==============================

              Expanded(
                child: filteredTutoriels.isEmpty
                    ? const TutorielEmptyState()
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),

                        itemCount:
                            filteredTutoriels.length,

                        itemBuilder:
                            (context, index) {
                          final tutoriel =
                              filteredTutoriels[index];

                          return TutorielCard(
                            tutoriel: tutoriel,

                            onTap: () {
                              // Navigation vers
                              // détail tutoriel
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },

        // ====================================
        // LOADING
        // ====================================

        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },

        // ====================================
        // ERROR
        // ====================================

        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Une erreur est survenue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(
                        tutorielsProvider,
                      );
                    },

                    child: const Text(
                      'Réessayer',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // FILTRE AVANCÉ
  // ==========================================

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Text(
                'Filtrer les tutoriels',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Âge',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              TutorielAgeFilter(
                selectedAge: selectedAge,

                onSelected: (age) {
                  setState(() {
                    selectedAge = age;
                  });

                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}