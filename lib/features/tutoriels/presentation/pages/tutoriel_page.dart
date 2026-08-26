import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/pages/tutoriel_detail_page.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/category_filter.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/tutoriel_search.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';
import 'package:eveilkid/shared/widgets/app_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TutorielPage extends ConsumerStatefulWidget {
  const TutorielPage({super.key});

  @override
  ConsumerState<TutorielPage> createState() => _TutorielPageState();
}

class _TutorielPageState extends ConsumerState<TutorielPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryId = 'all';

  List<Tutoriel> _filteredTutoriels(List<Tutoriel> tutoriels) {
    final query = _searchController.text.trim().toLowerCase();

    return tutoriels.where((tutoriel) {
      final matchesQuery = query.isEmpty ||
          tutoriel.titre.toLowerCase().contains(query) ||
          tutoriel.description.toLowerCase().contains(query);

      final matchesCategory = _selectedCategoryId == 'all' ||
          tutoriel.categorieId == _selectedCategoryId;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tutorielsAsync = ref.watch(tutorielsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final categoryChips = <Widget>[];
    categoryChips.add(
      CategoryFilterChip(
        label: 'Tous',
        isSelected: _selectedCategoryId == 'all',
        onTap: () => setState(() => _selectedCategoryId = 'all'),
      ),
    );

    categoryChips.addAll(
      categoriesAsync.maybeWhen(
        data: (categories) {
          return categories
              .where((category) => category.estActive)
              .map(
                (category) => CategoryFilterChip(
                  label: category.nom,
                  isSelected: _selectedCategoryId == category.categorieId,
                  onTap: () => setState(() => _selectedCategoryId = category.categorieId),
                ),
              )
              .toList();
        },
        orElse: () => <Widget>[],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 34,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Tutoriels',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111111),
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),
              TutorielSearchField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryChips.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => categoryChips[index],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: tutorielsAsync.when(
                  data: (tutoriels) {
                    final filtered = _filteredTutoriels(tutoriels);

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aucun tutoriel disponible',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final imageUrl = item.miniatureUrl.isNotEmpty
                            ? item.miniatureUrl
                            : 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=900&q=80';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TutorielDetailPage(tutorielId: item.tutorielId),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(26),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(26),
                                      child: SizedBox(
                                        width: 160,
                                        height: 120,
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              width: 160,
                                              height: 120,
                                              color: const Color(0xFFEBE6E6),
                                              child: const Center(
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 160,
                                            height: 120,
                                            color: const Color(0xFFEBE6E6),
                                            child: const Icon(
                                              Icons.image_not_supported_rounded,
                                              size: 40,
                                              color: Color(0xFF8A8A8A),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 12,
                                      bottom: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.78),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Text(
                                          _formatDuration(item.duree),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.titre,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF141414),
                                          height: 1.15,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEDEDEE),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          item.ageRangeLabel,
                                          style: const TextStyle(
                                            color: Color(0xFF4A4A4A),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(),
    );
  }

  String _formatDuration(num value) {
    final totalSeconds = value.toInt();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

