import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/features/tutoriels/enums/tutoriel_status.enum.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/admin/presentation/widgets/tutoriel_card.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';

import 'package:eveilkid/shared/widgets/app_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TutorielsListScreen extends ConsumerStatefulWidget {
  const TutorielsListScreen({super.key});

  @override
  ConsumerState<TutorielsListScreen> createState() => _TutorielsListScreenState();
}

class _TutorielsListScreenState extends ConsumerState<TutorielsListScreen> {
  String _searchQuery = '';
  String? _selectedStatus;
  bool _isFiltered = false;

  @override
  Widget build(BuildContext context) {
    final tutorielsAsync = ref.watch(adminTutorielsProvider);

    return Scaffold(
      drawer: const AdminDrawer(currentRoute: AdminNavRoute.tutoriels),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text("Tutoriels", style: AppTextStyles.headingMedium),
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
          if (_isFiltered)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Filtres',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push("/admin/tutoriels/add");
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            _buildSearchAndFilter(),
            const SizedBox(height: 15),
            _buildStatusFilters(),
            const SizedBox(height: 10),
            Expanded(
              child: tutorielsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erreur: $err'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(adminTutorielsProvider);
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
                data: (tutoriels) => _buildTutorielList(tutoriels),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: AppSearchBar(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              hintText: 'Rechercher un tutoriel...',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    final statuses = [
      {'value': null, 'label': 'Tous'},
      {'value': 'publie', 'label': 'Publiés'},
      {'value': 'brouillon', 'label': 'Brouillons'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) {
            final isSelected = _selectedStatus == status['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  status['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedStatus = isSelected ? null : status['value'];
                    _isFiltered = _selectedStatus != null;
                  });
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTutorielList(List<Tutoriel> tutoriels) {
    List<Tutoriel> filtered = List.from(tutoriels);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) =>
        t.titre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_selectedStatus != null) {
      filtered = filtered.where((t) => t.statut.value == _selectedStatus).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aucun tutoriel trouvé',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre premier tutoriel en appuyant sur le +',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final tutoriel = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TutorielCard(
            tutoriel: tutoriel,
            onTap: () {
              // Naviguer vers le détail
            },
            onEdit: () {
              context.push('/admin/tutoriels/edit/${tutoriel.tutorielId}');
            },
            onDelete: () => _confirmDelete(tutoriel),
            onPublish: () => _publishTutoriel(tutoriel),
            onUnpublish: () => _unpublishTutoriel(tutoriel),
          ),
        );
      },
    );
  }

  void _confirmDelete(Tutoriel tutoriel) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le tutoriel'),
        content: Text('Supprimer "${tutoriel.titre}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final repository = ref.read(tutorielRepositoryProvider);
                await repository.deleteTutoriel(tutoriel.tutorielId!);
                ref.invalidate(adminTutorielsProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tutoriel supprimé'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _publishTutoriel(Tutoriel tutoriel) async {
    try {
      final repository = ref.read(tutorielRepositoryProvider);
      await repository.publierTutoriel(tutoriel.tutorielId!);
      ref.invalidate(adminTutorielsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tutoriel publié'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _unpublishTutoriel(Tutoriel tutoriel) async {
    try {
      final repository = ref.read(tutorielRepositoryProvider);
      await repository.depublierTutoriel(tutoriel.tutorielId!);
      ref.invalidate(adminTutorielsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tutoriel dépublié'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}