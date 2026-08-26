import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/pages/video_player_page.dart';
import 'package:eveilkid/features/tutoriels/providers/progression_provider.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TutorielDetailPage extends ConsumerStatefulWidget {
  const TutorielDetailPage({
    super.key,
    required this.tutorielId,
  });

  final String tutorielId;

  @override
  ConsumerState<TutorielDetailPage> createState() => _TutorielDetailPageState();
}

class _TutorielDetailPageState extends ConsumerState<TutorielDetailPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final tutorielAsync = ref.watch(tutorielByIdProvider(widget.tutorielId));
    final progressionAsync = ref.watch(progressionProvider(widget.tutorielId));
    final tutorielsAsync = ref.watch(tutorielsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F6),
      body: SafeArea(
        child: tutorielAsync.when(
          data: (tutoriel) {
            if (tutoriel == null) {
              return const Center(
                child: Text('Tutoriel introuvable'),
              );
            }

            final progression = progressionAsync.maybeWhen(
              data: (value) => value,
              orElse: () => null,
            );

            final relatedTutoriels = tutorielsAsync.maybeWhen(
              data: (list) {
                final sameCategory = list
                    .where((item) =>
                        item.tutorielId != tutoriel.tutorielId &&
                        item.categorieId == tutoriel.categorieId)
                    .take(4)
                    .toList();

                if (sameCategory.isNotEmpty) {
                  return sameCategory;
                }

                return list
                    .where((item) => item.tutorielId != tutoriel.tutorielId)
                    .take(4)
                    .toList();
              },
              orElse: () => <Tutoriel>[],
            );

            final currentPosition = progression?.position ?? 0;
            final totalDuration = progression?.duree ?? tutoriel.duree;
            final progressValue = totalDuration == 0
                ? 0.0
                : (currentPosition / totalDuration).clamp(0.0, 1.0).toDouble();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Vidéos tutoriels',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B1B1B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E5E7),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedTab == 0
                                    ? const Color(0xFF7D4DDB)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Text(
                                'En cours',
                                style: TextStyle(
                                  color: _selectedTab == 0 ? Colors.white : const Color(0xFF261F2A),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 1),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedTab == 1
                                    ? const Color(0xFFEDE7F7)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Text(
                                'Tous les tutoriels',
                                style: TextStyle(
                                  color: _selectedTab == 1 ? const Color(0xFF1A1A1A) : const Color(0xFF261F2A),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () => _openVideo(context, tutoriel),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 240,
                            width: double.infinity,
                            child: Image.network(
                              tutoriel.miniatureUrl.isNotEmpty
                                  ? tutoriel.miniatureUrl
                                  : 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=900&q=80',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFFE9E4E6),
                                child: const Icon(Icons.image_not_supported_rounded, size: 48),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.center,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_circle_fill_rounded,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 14,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                _formatDuration(tutoriel.duree),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    tutoriel.titre,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tutoriel.description,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.4,
                      color: Color(0xFF49484A),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Reprendre la lecture',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _openVideo(context, tutoriel),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE8F5),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: SizedBox(
                              width: 42,
                              height: 42,
                              child: Image.network(
                                tutoriel.miniatureUrl.isNotEmpty
                                    ? tutoriel.miniatureUrl
                                    : 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=900&q=80',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tutoriel.titre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F1F1F),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      _formatDuration((currentPosition).toInt()),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF4A4A4A),
                                      ),
                                    ),
                                    const Text(' / ', style: TextStyle(color: Color(0xFF4A4A4A))),
                                    Text(
                                      _formatDuration(totalDuration.toInt()),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF4A4A4A),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: progressValue,
                                    minHeight: 8,
                                    backgroundColor: const Color(0xFFD8CFDD),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7D4DDB)),
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
                  const Text(
                    'Regarde aussi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: relatedTutoriels.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final item = relatedTutoriels[index];

                      return GestureDetector(
                        onTap: () => _openDetail(context, item.tutorielId!),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                height: 120,
                                width: double.infinity,
                                child: Image.network(
                                  item.miniatureUrl.isNotEmpty
                                      ? item.miniatureUrl
                                      : 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=900&q=80',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.titre,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F1F1F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDuration(item.duree.toInt()),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF4A4A4A),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Erreur: $error'),
          ),
        ),
      ),
    );
  }

  String _formatDuration(num seconds) {
    final total = seconds.toInt();
    final minutes = (total ~/ 60).toString().padLeft(2, '0');
    final rest = (total % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  void _openVideo(BuildContext context, Tutoriel tutoriel) {
    if (tutoriel.videoUrl.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerPage(tutoriel: tutoriel),
      ),
    );
  }

  void _openDetail(BuildContext context, String tutorielId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TutorielDetailPage(tutorielId: tutorielId),
      ),
    );
  }
}