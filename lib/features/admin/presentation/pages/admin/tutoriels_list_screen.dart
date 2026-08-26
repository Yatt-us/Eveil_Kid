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

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final tutorielsAsync = ref.watch(adminTutorielsProvider);

    return Scaffold(
      key: _scaffoldMessengerKey,
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
            // Barre de recherche
            _buildSearchAndFilter(),
            const SizedBox(height: 10),

            _buildStatusFilters(),
            const SizedBox(height: 6),

            if (_isFiltered) _buildActiveFilters(),
            const SizedBox(height: 6),

            Expanded(
              child: tutorielsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                _resetFilters();
              }
            },
            offset: const Offset(0, 50),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _isFiltered ? AppColors.primary : AppColors.primary,
              ),
              child: const Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 20,
              ),
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'advanced',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: AppColors.primary, size: 18),
                    const SizedBox(width: 12),
                    const Text(
                      'Filtres avancés',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
                onTap: () => _showAdvancedFilters(),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: AppColors.danger, size: 18),
                    const SizedBox(width: 12),
                    const Text(
                      'Réinitialiser les filtres',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: statuses.map((status) {
          final isSelected = _selectedStatus == status['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(
                status['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedStatus = isSelected ? null : status['value'] as String?;
                  _isFiltered = _selectedStatus != null;
                });
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveFilters() {
    List<String> activeFilters = [];

    if (_selectedStatus != null) {
      final statusLabels = {
        'publie': 'Publié',
        'brouillon': 'Brouillon',
        'archive': 'Archivé',
      };
      activeFilters.add('Statut: ${statusLabels[_selectedStatus] ?? _selectedStatus}');
    }

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              'Filtres actifs: ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            ...activeFilters.map((filter) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Chip(
                    label: Text(
                      filter,
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.orange.shade50,
                    deleteIcon: const Icon(Icons.close, size: 12),
                    onDeleted: () {
                      setState(() {
                        _selectedStatus = null;
                        _isFiltered = false;
                      });
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  ),
                )),
            TextButton(
              onPressed: _resetFilters,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Tout effacer',
                style: TextStyle(fontSize: 11, color: AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setStateBottomSheet) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtres avancés',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),

                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Statut de publication',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildFilterChip(
                                  label: 'Tous',
                                  value: null,
                                  selectedValue: _selectedStatus,
                                  onSelected: (val) {
                                    setStateBottomSheet(() {
                                      _selectedStatus = val;
                                    });
                                  },
                                ),
                                _buildFilterChip(
                                  label: 'Publié',
                                  value: 'publie',
                                  selectedValue: _selectedStatus,
                                  onSelected: (val) {
                                    setStateBottomSheet(() {
                                      _selectedStatus = val;
                                    });
                                  },
                                  color: AppColors.childPrimary,
                                ),
                                _buildFilterChip(
                                  label: 'Brouillon',
                                  value: 'brouillon',
                                  selectedValue: _selectedStatus,
                                  onSelected: (val) {
                                    setStateBottomSheet(() {
                                      _selectedStatus = val;
                                    });
                                  },
                                  color: AppColors.warning,
                                ),
                                _buildFilterChip(
                                  label: 'Archivé',
                                  value: 'archive',
                                  selectedValue: _selectedStatus,
                                  onSelected: (val) {
                                    setStateBottomSheet(() {
                                      _selectedStatus = val;
                                    });
                                  },
                                  color: AppColors.danger,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setStateBottomSheet(() {
                                        _selectedStatus = null;
                                      });
                                    },
                                    child: const Text('Réinitialiser'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isFiltered = _selectedStatus != null;
                                      });
                                      Navigator.pop(context);
                                      _applyFilters();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Appliquer les filtres'),
                                  ),
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
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String? value,
    required String? selectedValue,
    required Function(String?) onSelected,
    Color? color,
  }) {
    final isSelected = value == selectedValue;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        onSelected(isSelected ? null : value);
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: color ?? AppColors.primary,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
            Icon(Icons.video_library_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Aucun tutoriel trouvé',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Créez votre premier tutoriel en appuyant sur le +',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final tutoriel = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
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

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _searchQuery = '';
      _isFiltered = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _isFiltered = _selectedStatus != null;
    });
  }

  void _confirmDelete(Tutoriel tutoriel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer le tutoriel'),
          content: Text('Supprimer "${tutoriel.titre}" ?'),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.canPop(dialogContext)) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (Navigator.canPop(dialogContext)) {
                  Navigator.pop(dialogContext);
                }
                await Future.delayed(const Duration(milliseconds: 100));
                try {
                  final repository = ref.read(tutorielRepositoryProvider);
                  await repository.deleteTutoriel(tutoriel.tutorielId!);
                  ref.refresh(adminTutorielsProvider);
                  if (mounted) {
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(
                        content: Text('Tutoriel supprimé'),
                        backgroundColor: AppColors.childPrimary,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _publishTutoriel(Tutoriel tutoriel) async {
    try {
      final repository = ref.read(tutorielRepositoryProvider);
      await repository.publierTutoriel(tutoriel.tutorielId!);
      ref.invalidate(adminTutorielsProvider);
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Tutoriel publié'),
            backgroundColor: AppColors.childPrimary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
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
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Tutoriel dépublié'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}