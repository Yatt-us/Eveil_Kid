import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/ActivityCategorie/models/activity_category_model.dart';
import 'package:eveilkid/features/ActivityCategorie/providers/activity_category_provider.dart';
import 'package:eveilkid/features/activites/enums/publication_status.enum.dart';
import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_card.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

class ActivitiesListScreen extends ConsumerStatefulWidget {
  const ActivitiesListScreen({super.key});

  @override
  ConsumerState<ActivitiesListScreen> createState() => _ActivitiesListScreenState();
}

class _ActivitiesListScreenState extends ConsumerState<ActivitiesListScreen> {
  String _searchQuery = '';
  String? _selectedCategoryId = 'all'; 
  String? _selectedStatus;
  int? _selectedAgeMin;
  int? _selectedAgeMax;
  bool _isFiltered = false;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(adminActivitesProvider);
    final categoriesAsync = ref.watch(categoriesActivesProvider);

    return Scaffold(
      key: _scaffoldMessengerKey,
      drawer: const AdminDrawer(currentRoute: AdminNavRoute.activites),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text("Activité", style: AppTextStyles.headingMedium),
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
          context.push("/admin/activites/add");
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            // Barre de recherche et filtre
            _buildSearchAndFilter(),
            const SizedBox(height: 15),

            categoriesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (categories) => _buildCategoryFilters(categories),
            ),
            const SizedBox(height: 10),

            if (_isFiltered) _buildActiveFilters(),
            const SizedBox(height: 10),

           
            Expanded(
              child: activitiesAsync.when(
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
                          ref.invalidate(adminActivitesProvider);
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
                data: (activities) => _buildActivityList(activities),
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
                setState(() {
                  _searchQuery = value;
                });
              },
              hintText: 'Rechercher une activité...',
            ),
          ),
          AppSpacing.horizontalXl,
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
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _isFiltered ? AppColors.primary : AppColors.primary,
              ),
              child: const Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 24,
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'advanced',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Text('Filtres avancés'),
                    const Spacer(),
                    Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                  ],
                ),
                onTap: () => _showAdvancedFilters(),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: AppColors.danger),
                    const SizedBox(width: 12),
                    const Text(
                      'Réinitialiser les filtres',
                      style: TextStyle(color: AppColors.danger),
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

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
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
                            // Filtre par statut de publication
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

                            // Filtre par tranche d'âge
                            const Text(
                              'Tranche d\'âge',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Âge minimum',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      DropdownButtonFormField<int>(
                                        initialValue: _selectedAgeMin,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                        ),
                                        items: [
                                          const DropdownMenuItem(
                                            value: null,
                                            child: Text('Aucun'),
                                          ),
                                          ...List.generate(12, (index) => index + 1)
                                              .map((age) => DropdownMenuItem(
                                                    value: age,
                                                    child: Text('$age ans'),
                                                  )),
                                        ],
                                        onChanged: (value) {
                                          setStateBottomSheet(() {
                                            _selectedAgeMin = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Âge maximum',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      DropdownButtonFormField<int>(
                                        initialValue: _selectedAgeMax,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                        ),
                                        items: [
                                          const DropdownMenuItem(
                                            value: null,
                                            child: Text('Aucun'),
                                          ),
                                          ...List.generate(12, (index) => index + 1)
                                              .map((age) => DropdownMenuItem(
                                                    value: age,
                                                    child: Text('$age ans'),
                                                  )),
                                        ],
                                        onChanged: (value) {
                                          setStateBottomSheet(() {
                                            _selectedAgeMax = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Boutons d'action
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setStateBottomSheet(() {
                                        _selectedStatus = null;
                                        _selectedAgeMin = null;
                                        _selectedAgeMax = null;
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
                                        _isFiltered = _selectedStatus != null ||
                                            _selectedAgeMin != null ||
                                            _selectedAgeMax != null;
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

  // Widget pour les chips de filtre
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
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        onSelected(isSelected ? null : value);
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: color ?? AppColors.primary,
      checkmarkColor: Colors.white,
    );
  }


  Widget _buildCategoryFilters(List<ActiviteCategorie> categories) {
  final allCategories = [
    ActiviteCategorie(
      id: 'all',
      nom: 'Tous',
      description: '',
      dateCreation: DateTime.now(),
      dateModification: DateTime.now(),
    ),
    ...categories,
  ];

  return Container(
    height: 50,
    padding: const EdgeInsets.only(left: 20),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: allCategories.length,
      itemBuilder: (context, index) {
        final category = allCategories[index];
        final isSelected = _selectedCategoryId == category.id;
        
        return Padding(
          padding: EdgeInsets.only(right: index == allCategories.length - 1 ? 20 : 8),
          child: ChoiceChip(
            label: Text(
              category.nom,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedCategoryId = isSelected ? null : category.id;
                if (!isSelected && category.id == 'all') {
                  _selectedCategoryId = 'all';
                } else if (isSelected) {
                  _selectedCategoryId = 'all';
                }
              });
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            visualDensity: VisualDensity.compact,
          ),
        );
      },
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

    if (_selectedAgeMin != null && _selectedAgeMax != null) {
      activeFilters.add('Âge: $_selectedAgeMin-$_selectedAgeMax ans');
    } else if (_selectedAgeMin != null) {
      activeFilters.add('Âge minimum: $_selectedAgeMin ans');
    } else if (_selectedAgeMax != null) {
      activeFilters.add('Âge maximum: $_selectedAgeMax ans');
    }

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              'Filtres actifs: ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            ...activeFilters.map((filter) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Chip(
                    label: Text(
                      filter,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.orange.shade50,
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      setState(() {
                        _selectedStatus = null;
                        _selectedAgeMin = null;
                        _selectedAgeMax = null;
                        _isFiltered = false;
                      });
                    },
                  ),
                )),
            TextButton(
              onPressed: _resetFilters,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Tout effacer',
                style: TextStyle(fontSize: 12, color: AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList(List<Activite> activities) {
    List<Activite> filtered = List.from(activities);

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((activity) {
        return activity.titre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               activity.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

   
    if (_selectedCategoryId != null && _selectedCategoryId != 'all') {
      filtered = filtered.where((activity) {
        return activity.categorieId == _selectedCategoryId;
      }).toList();
    }

    if (_selectedStatus != null) {
      filtered = filtered.where((activity) {
        return activity.statut.value == _selectedStatus;
      }).toList();
    }

   
    if (_selectedAgeMin != null) {
      filtered = filtered.where((activity) {
        return activity.ageMinimum >= _selectedAgeMin!;
      }).toList();
    }

    if (_selectedAgeMax != null) {
      filtered = filtered.where((activity) {
        return activity.ageMaximum <= _selectedAgeMax!;
      }).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune activité trouvée',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier votre recherche ou vos filtres',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _resetFilters,
              child: const Text('Réinitialiser les filtres'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final activity = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ActivityCard(
            activity: activity,
            onTap: () {
              context.push(
                '/admin/activites/${activity.id}/questions'
              );
            },
            onEdit: () {
              context.push(
                '/admin/activites/edit/${activity.id}'
              );
            },
            onDelete: () => _confirmDelete(activity),
            onPublish: () => _publishActivity(activity),
            onUnpublish: () => _unpublishActivity(activity),
          ),
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedCategoryId = 'all'; 
      _selectedStatus = null;
      _selectedAgeMin = null;
      _selectedAgeMax = null;
      _searchQuery = '';
      _isFiltered = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _isFiltered = _selectedStatus != null ||
          _selectedAgeMin != null ||
          _selectedAgeMax != null;
    });
  }

  void _confirmDelete(Activite activity) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Supprimer l\'activité',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer "${activity.titre}" ?\nCette action est irréversible.',
          ),
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
                  final notifier = ref.read(activityNotifierProvider.notifier);
                  await notifier.deleteActivity(activity.id!);
                  if (mounted) {
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(
                        content: Text('✅ Activité supprimée avec succès'),
                        backgroundColor: AppColors.childPrimary,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text('❌ Erreur: $e'),
                        backgroundColor: AppColors.danger,
                        duration: Duration(seconds: 3),
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

  Future<void> _publishActivity(Activite activity) async {
    try {
      final repository = ref.read(activityRepositoryProvider);
      await repository.publierActivite(activity.id!);
      ref.invalidate(adminActivitesProvider);
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('✅ Activité publiée avec succès'),
            backgroundColor: AppColors.childPrimary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _unpublishActivity(Activite activity) async {
    try {
      final repository = ref.read(activityRepositoryProvider);
      await repository.depublierActivite(activity.id!);
      ref.invalidate(adminActivitesProvider);
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('📄 Activité dépubliée'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}