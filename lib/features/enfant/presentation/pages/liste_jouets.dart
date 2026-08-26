import 'package:firebase_auth/firebase_auth.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListeJouetsPage extends ConsumerStatefulWidget {
  const ListeJouetsPage({super.key});

  @override
  ConsumerState<ListeJouetsPage> createState() => _ListeJouetsPageState();
}

class _ListeJouetsPageState extends ConsumerState<ListeJouetsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enfant = ref.watch(
      enfantNotifierProvider.select((state) => state.enfantSelectionne),
    );
    final jouetsAsync = ref.watch(jouetsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final filteredJouets = _filterJouets(
      jouets: jouetsAsync.value ?? const [],
      childAge: enfant?.age ?? 0,
      keyword: _searchQuery,
      categoryId: _selectedCategoryId,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.textPrimary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Découvrir les jouets',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
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
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un jouet...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 44,
                child: categoriesAsync.when(
                  data: (categories) {
                    final chips = <Widget>[
                      _FilterChip(
                        label: 'Tous',
                        isSelected: _selectedCategoryId == null,
                        onTap: () => setState(() => _selectedCategoryId = null),
                      ),
                      ...categories.map((categorie) => _FilterChip(
                            label: categorie.nom,
                            isSelected:
                                _selectedCategoryId == categorie.categorieId,
                            onTap: () {
                              setState(() {
                                _selectedCategoryId =
                                    _selectedCategoryId == categorie.categorieId
                                        ? null
                                        : categorie.categorieId;
                              });
                            },
                          )),
                    ];

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: chips.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) => chips[index],
                    );
                  },
                  loading: () => const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: jouetsAsync.when(
                  data: (jouets) {
                    if (filteredJouets.isEmpty) {
                      return _EmptyState(
                        label: _searchQuery.isNotEmpty || _selectedCategoryId != null
                            ? 'Aucun jouet ne correspond à ce filtre.'
                            : 'Aucun jouet disponible pour le moment.',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: filteredJouets.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final jouet = filteredJouets[index];
                        return _ToyCard(jouet: jouet);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => _EmptyState(
                    label: 'Impossible de charger les jouets.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Jouet> _filterJouets({
    required List<Jouet> jouets,
    required int childAge,
    required String keyword,
    required String? categoryId,
  }) {
    final normalizedQuery = keyword.trim().toLowerCase();
    final categoryMap = <String, String>{};

    final categories = ref.read(categoriesProvider).asData?.value ?? const [];

    for (final category in categories) {
      categoryMap[category.categorieId] = category.nom.toLowerCase();
    }

    return jouets.where((jouet) {
      final matchesCategory =
          categoryId == null ||
          jouet.categorieId == categoryId ||
          jouet.nomCategorieDenormalise.toLowerCase() ==
              (categoryMap[categoryId] ?? '');

      final matchesKeyword = normalizedQuery.isEmpty ||
          jouet.nom.toLowerCase().contains(normalizedQuery) ||
          jouet.description.toLowerCase().contains(normalizedQuery) ||
          jouet.nomCategorieDenormalise.toLowerCase().contains(normalizedQuery);

      final minAge = jouet.ageMinimum;
      final maxAge = jouet.ageMaximum > 0 ? jouet.ageMaximum : null;
      final matchesAge = childAge >= minAge &&
          (maxAge == null || childAge <= maxAge);

      return jouet.estActif && matchesCategory && matchesKeyword && matchesAge;
    }).toList();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ToyCard extends StatelessWidget {
  final Jouet jouet;

  const _ToyCard({required this.jouet});

  @override
  Widget build(BuildContext context) {
    final imageUrl = jouet.imagePrincipaleUrl.trim();
    final ageLabel = jouet.ageMaximum > 0
        ? '${jouet.ageMinimum} - ${jouet.ageMaximum} ans'
        : 'À partir de ${jouet.ageMinimum} ans';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 110,
                height: 110,
                color: const Color(0xFFF3EEFF),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _fallbackImage(),
                      )
                    : _fallbackImage(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          jouet.nom,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.favorite_border_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    jouet.nomCategorieDenormalise.isNotEmpty
                        ? jouet.nomCategorieDenormalise
                        : 'Jouet',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    jouet.description.isNotEmpty
                        ? jouet.description
                        : 'Un jouet pensé pour le plaisir et l’apprentissage.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoPill(
                        icon: Icons.star_rounded,
                        label: jouet.noteMoyenneDenormalise > 0
                            ? jouet.noteMoyenneDenormalise.toStringAsFixed(1)
                            : 'Nouveau',
                      ),
                      const SizedBox(width: 8),
                      _InfoPill(
                        icon: Icons.access_time_rounded,
                        label: ageLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${jouet.prix.toStringAsFixed(0)} ${jouet.devise}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Voir',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: const Color(0xFFF3EEFF),
      child: const Icon(Icons.toys_rounded, size: 40, color: AppColors.primary),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;

  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEAFBF0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
