import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/features/tutoriels/models/suggestion.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/jouets_suggestion_card.dart';
import 'package:eveilkid/features/tutoriels/providers/progression_provider.dart';
import 'package:eveilkid/features/tutoriels/providers/suggestion_provider.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

/// Page de lecture vidéo moderne et immersive pour les tutoriels
class VideoPlayerPage extends ConsumerStatefulWidget {
  final Tutoriel tutoriel;

  const VideoPlayerPage({
    super.key,
    required this.tutoriel,
  });

  @override
  ConsumerState<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends ConsumerState<VideoPlayerPage> {
  late VideoPlayerController _videoController;
  Timer? _progressTimer;
  Timer? _controlsTimer;

  // Suggestions pendant la lecture
  List<Suggestion> _suggestions = [];
  final Set<int> _shownSuggestionTimes = {};
  Suggestion? _activeSuggestion;
  Jouet? _activeSuggestionJouet;
  bool _wasPlayingBeforeSuggestion = false;

  // Sauvegarde / reprise
  bool _hasSavedPosition = false;
  int _savedPositionSeconds = 0;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Visibilité des contrôles
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final videoUrl = widget.tutoriel.videoUrl.trim();

      if (videoUrl.isEmpty) {
        throw Exception('L\'URL de la vidéo est vide.');
      }

      final uri = Uri.tryParse(videoUrl);
      if (uri == null || !uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        throw Exception('URL vidéo invalide : $videoUrl');
      }

      _videoController = VideoPlayerController.networkUrl(uri);
      await _videoController.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });

      // Charger la progression sauvegardée
      await _loadSavedProgression();

      // Charger les suggestions
      _suggestions = await ref.read(
        suggestionsProvider(widget.tutoriel.tutorielId!).future,
      );

      _videoController.addListener(_videoListener);

      // Sauvegarde automatique toutes les 15 secondes
      _progressTimer = Timer.periodic(
        const Duration(seconds: 15),
        (_) => _saveProgression(),
      );

      // Masquer les contrôles après 3.5s au lancement
      _startControlsTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isInitialized = false;
      });
    }
  }

  void _videoListener() {
    if (!_videoController.value.isInitialized) return;

    // Sauvegarder la progression finale si la vidéo se termine
    if (_videoController.value.position >= _videoController.value.duration) {
      _saveProgression();
    }

    // Déclenchement des suggestions intelligentes
    final posSeconds = _videoController.value.position.inSeconds;
    for (final suggestion in _suggestions) {
      final sTime = suggestion.temps;
      if (sTime == posSeconds && !_shownSuggestionTimes.contains(sTime)) {
        _shownSuggestionTimes.add(sTime);
        _showSuggestion(suggestion);
        break;
      }
    }
  }

  Future<void> _saveProgression() async {
    if (!_isInitialized) return;

    final position = _videoController.value.position.inSeconds;
    final duree = _videoController.value.duration.inSeconds;

    await ref.read(progressionControllerProvider).saveProgression(
          tutorielId: widget.tutoriel.tutorielId!,
          position: position,
          duree: duree,
        );
  }

  Future<void> _loadSavedProgression() async {
    try {
      final progression = await ref.read(
        progressionProvider(widget.tutoriel.tutorielId!).future,
      );

      if (progression == null) return;

      final pos = progression.position.toInt();
      if (pos > 0 && !progression.termine) {
        _savedPositionSeconds = pos;
        _hasSavedPosition = true;
        await _videoController.seekTo(Duration(seconds: pos));
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('Erreur chargement progression: $e');
    }
  }

  Future<void> _showSuggestion(Suggestion suggestion) async {
    _wasPlayingBeforeSuggestion = _videoController.value.isPlaying;
    if (_wasPlayingBeforeSuggestion) {
      _videoController.pause();
    }

    setState(() {
      _activeSuggestion = suggestion;
      _activeSuggestionJouet = null;
    });

    if (suggestion.jouetId.isNotEmpty) {
      final jouet = await ref.read(jouetByIdProvider(suggestion.jouetId).future);
      if (mounted) setState(() => _activeSuggestionJouet = jouet);
    }

    Future.delayed(const Duration(seconds: 7), () {
      if (!mounted) return;
      if (_activeSuggestion != null) {
        setState(() => _activeSuggestion = null);
        if (_wasPlayingBeforeSuggestion) {
          _videoController.play();
        }
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startControlsTimer();
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _videoController.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _seekRelative(int seconds) {
    if (!_isInitialized) return;
    final current = _videoController.value.position;
    final target = current + Duration(seconds: seconds);
    final clamped = Duration(
      seconds: target.inSeconds.clamp(0, _videoController.value.duration.inSeconds),
    );
    _videoController.seekTo(clamped);
    _startControlsTimer();
    setState(() {});
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controlsTimer?.cancel();
    _saveProgression();
    if (_isInitialized) {
      _videoController.removeListener(_videoListener);
      _videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_hasError) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: AppErrorState(
          title: 'Impossible de lire la vidéo',
          message: _errorMessage,
          onRetry: () {
            setState(() {
              _hasError = false;
              _isInitialized = false;
            });
            _initializeVideo();
          },
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Chargement du tutoriel...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryName = categoriesAsync.maybeWhen(
      data: (categories) {
        for (final cat in categories) {
          if (cat.categorieId == widget.tutoriel.categorieId) return cat.nom;
        }
        return null;
      },
      orElse: () => null,
    );

    // Jouets suggérés
    final toyIds = <String>{
      if (widget.tutoriel.jouetLieId != null && widget.tutoriel.jouetLieId!.isNotEmpty)
        widget.tutoriel.jouetLieId!,
      ...widget.tutoriel.jouetsSuggeres.where((id) => id.isNotEmpty),
    }.toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── ZONE DU LECTEUR VIDÉO IMMERSIF ──
            Container(
              color: Colors.black,
              child: AspectRatio(
                aspectRatio: _videoController.value.aspectRatio.clamp(1.2, 1.9),
                child: GestureDetector(
                  onTap: _toggleControls,
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Lecteur vidéo natif
                      VideoPlayer(_videoController),

                      // Overlay de contrôle
                      AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: IgnorePointer(
                          ignoring: !_showControls,
                          child: _buildControlsOverlay(context),
                        ),
                      ),

                      // Pop-up de suggestion intelligente
                      if (_activeSuggestion != null)
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 70,
                          child: JouetSuggestionCard(
                            isCompact: true,
                            jouet: _activeSuggestionJouet,
                            jouetId: _activeSuggestion!.jouetId.isNotEmpty
                                ? _activeSuggestion!.jouetId
                                : null,
                            onClose: () {
                              setState(() => _activeSuggestion = null);
                              if (_wasPlayingBeforeSuggestion) {
                                _videoController.play();
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── BANNIÈRE REPRENDRE LA LECTURE (SI POSITION SAUVEGARDÉE) ──
            if (_hasSavedPosition && !_videoController.value.isPlaying)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Reprendre à ${_formatDuration(_savedPositionSeconds)}',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      AppButton(
                        text: 'Reprendre',
                        isFullWidth: false,
                        size: AppButtonSize.small,
                        onPressed: () {
                          _videoController.play();
                          setState(() => _hasSavedPosition = false);
                        },
                      ),
                    ],
                  ),
                ),
              ),

            // ── CONTENU SOUS LA VIDÉO (DÉTAILS & MATÉRIEL) ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre & Informations épurées
                    Text(
                      widget.tutoriel.titre,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 14,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65) ??
                              theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            [
                              if (categoryName != null && categoryName.isNotEmpty) categoryName,
                              widget.tutoriel.ageRangeLabel,
                              widget.tutoriel.dureeFormatee,
                            ].join(' • '),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65) ??
                                  theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    if (widget.tutoriel.description.isNotEmpty) ...[
                      AppCard(
                        title: 'Description',
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          widget.tutoriel.description,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8) ??
                                theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Matériel & Jouets utilisés
                    if (toyIds.isNotEmpty) ...[
                      Text(
                        'Matériel & Jouets recommandés',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...toyIds.map(
                        (toyId) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: JouetSuggestionCard(jouetId: toyId),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaying = _videoController.value.isPlaying;
    final position = _videoController.value.position.inSeconds;
    final duration = _videoController.value.duration.inSeconds;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.2),
            Colors.black.withValues(alpha: 0.75),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Barre supérieure overlay
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'Fermer',
                ),
                Expanded(
                  child: Text(
                    widget.tutoriel.titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined, color: Colors.white, size: 20),
                  tooltip: 'Mémoriser ma progression',
                  onPressed: () async {
                    await _saveProgression();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Progression sauvegardée !'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Contrôles centraux (-10s / Play-Pause / +10s)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 32),
                onPressed: () => _seekRelative(-10),
                tooltip: 'Reculer de 10s',
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isPlaying) {
                      _videoController.pause();
                    } else {
                      _videoController.play();
                    }
                  });
                  _startControlsTimer();
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 32),
                onPressed: () => _seekRelative(10),
                tooltip: 'Avancer de 10s',
              ),
            ],
          ),

          // Barre inférieure overlay (Scrubber + Timestamps)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                VideoProgressIndicator(
                  _videoController,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: theme.colorScheme.primary,
                    bufferedColor: Colors.white.withValues(alpha: 0.3),
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '00:00';
    final d = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final secs = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$secs';
  }
}