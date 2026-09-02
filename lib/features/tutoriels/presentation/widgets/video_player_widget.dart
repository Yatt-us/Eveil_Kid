import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/features/tutoriels/models/suggestion.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/jouets_suggestion_card.dart';
import 'package:eveilkid/features/tutoriels/providers/cloudinary_duration_provider.dart';
import 'package:eveilkid/features/tutoriels/providers/progression_provider.dart';
import 'package:eveilkid/features/tutoriels/providers/suggestion_provider.dart';

/// Contrôleur permettant à un composant parent de piloter la lecture vidéo inline
class TutorielVideoPlayerController extends ChangeNotifier {
  _TutorielInlineVideoPlayerState? _state;

  void _attach(_TutorielInlineVideoPlayerState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  bool get isPlaying => _state?.isPlaying ?? false;
  bool get isInitialized => _state?.isInitialized ?? false;

  void play() => _state?.play();
  void pause() => _state?.pause();
  void togglePlayPause() => _state?.togglePlayPause();
  void seekTo(Duration position) => _state?.seekTo(position);
  void replay() => _state?.replay();
}

/// Lecteur vidéo intégré universel (Cloudinary / direct MP4/HLS)
/// avec contrôles modernes inline & plein écran, suggestions contextuelles et sauvegarde de progression.
class TutorielInlineVideoPlayer extends ConsumerStatefulWidget {
  final Tutoriel tutoriel;
  final bool autoPlay;
  final int? initialPositionSeconds;
  final TutorielVideoPlayerController? controller;
  final VoidCallback? onFinished;
  final ValueChanged<bool>? onPlayStateChanged;
  final bool isKidMode;

  const TutorielInlineVideoPlayer({
    super.key,
    required this.tutoriel,
    this.autoPlay = false,
    this.initialPositionSeconds,
    this.controller,
    this.onFinished,
    this.onPlayStateChanged,
    this.isKidMode = false,
  });

  @override
  ConsumerState<TutorielInlineVideoPlayer> createState() =>
      _TutorielInlineVideoPlayerState();
}

class _TutorielInlineVideoPlayerState
    extends ConsumerState<TutorielInlineVideoPlayer> {
  // Contrôleur vidéo natif
  VideoPlayerController? _videoController;

  // États du lecteur
  bool _isStarted = false;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isEnded = false;

  // Visibilité des contrôles
  bool _showControls = true;
  Timer? _controlsTimer;
  Timer? _progressSaveTimer;

  // Suggestions intelligentes
  List<Suggestion> _suggestions = [];
  final Set<int> _shownSuggestionTimes = {};
  Suggestion? _activeSuggestion;
  Jouet? _activeSuggestionJouet;
  bool _wasPlayingBeforeSuggestion = false;

  bool get isPlaying => _isPlaying;
  bool get isInitialized => _isInitialized;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    if (widget.autoPlay) {
      startPlaying();
    }
  }

  @override
  void didUpdateWidget(covariant TutorielInlineVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
    if (oldWidget.tutoriel.videoUrl != widget.tutoriel.videoUrl) {
      _disposeController();
      if (widget.autoPlay) {
        startPlaying();
      }
    }
  }

  /// Démarre l'initialisation et la lecture du média
  Future<void> startPlaying() async {
    if (_isInitialized) {
      play();
      return;
    }

    final rawUrl = widget.tutoriel.videoUrl.trim();
    if (rawUrl.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Aucune URL vidéo n\'est renseignée pour ce tutoriel.';
      });
      return;
    }

    setState(() {
      _isStarted = true;
      _hasError = false;
      _errorMessage = '';
    });

    await _initNativeVideo();
    _loadSuggestions();
  }

  Future<void> _initNativeVideo() async {
    try {
      final videoUrl = widget.tutoriel.videoUrl.trim();
      final uri = Uri.tryParse(videoUrl);
      if (uri == null || !uri.hasScheme) {
        throw Exception('URL vidéo invalide : $videoUrl');
      }

      _videoController = VideoPlayerController.networkUrl(uri);
      await _videoController!.initialize();

      if (!mounted) return;

      if (widget.initialPositionSeconds != null &&
          widget.initialPositionSeconds! > 0) {
        await _videoController!.seekTo(
          Duration(seconds: widget.initialPositionSeconds!),
        );
      }

      await _videoController!.play();
      _videoController!.addListener(_nativeVideoListener);

      setState(() {
        _isInitialized = true;
        _isPlaying = true;
      });
      widget.onPlayStateChanged?.call(true);

      _startAutoSaveTimer();
      _startControlsTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Impossible de charger la vidéo : $e';
        _isInitialized = false;
      });
    }
  }

  Future<void> _loadSuggestions() async {
    final tutorielId = widget.tutoriel.tutorielId;
    if (tutorielId == null || tutorielId.isEmpty) return;
    try {
      final list = await ref.read(suggestionsProvider(tutorielId).future);
      if (mounted) {
        setState(() => _suggestions = list);
      }
    } catch (_) {}
  }

  void _nativeVideoListener() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }

    final val = _videoController!.value;
    final isPlayingNow = val.isPlaying;

    if (_isPlaying != isPlayingNow) {
      setState(() => _isPlaying = isPlayingNow);
      widget.onPlayStateChanged?.call(isPlayingNow);
    }

    // Fin de vidéo
    if (val.position >= val.duration && val.duration > Duration.zero) {
      if (!_isEnded) {
        setState(() {
          _isEnded = true;
          _showControls = true;
        });
        _saveProgression();
        widget.onFinished?.call();
      }
    } else if (_isEnded && val.position < val.duration) {
      setState(() => _isEnded = false);
    }

    // Gestion des suggestions
    _checkSuggestions(val.position.inSeconds);
  }

  void _checkSuggestions(int currentSeconds) {
    if (_suggestions.isEmpty) return;

    for (final suggestion in _suggestions) {
      final sTime = suggestion.temps;
      if (sTime == currentSeconds && !_shownSuggestionTimes.contains(sTime)) {
        _shownSuggestionTimes.add(sTime);
        _triggerSuggestionPopup(suggestion);
        break;
      }
    }
  }

  Future<void> _triggerSuggestionPopup(Suggestion suggestion) async {
    _wasPlayingBeforeSuggestion = _isPlaying;
    if (_wasPlayingBeforeSuggestion) {
      pause();
    }

    setState(() {
      _activeSuggestion = suggestion;
      _activeSuggestionJouet = null;
    });

    if (suggestion.jouetId.isNotEmpty) {
      try {
        final jouet =
            await ref.read(jouetByIdProvider(suggestion.jouetId).future);
        if (mounted) setState(() => _activeSuggestionJouet = jouet);
      } catch (_) {}
    }

    Future.delayed(const Duration(seconds: 7), () {
      if (!mounted) return;
      if (_activeSuggestion != null) {
        setState(() => _activeSuggestion = null);
        if (_wasPlayingBeforeSuggestion) {
          play();
        }
      }
    });
  }

  void play() {
    _videoController?.play();
    setState(() {
      _isPlaying = true;
      _isEnded = false;
    });
    widget.onPlayStateChanged?.call(true);
    _startControlsTimer();
  }

  void pause() {
    _videoController?.pause();
    setState(() => _isPlaying = false);
    widget.onPlayStateChanged?.call(false);
    _saveProgression();
  }

  void togglePlayPause() {
    if (!_isStarted || !_isInitialized) {
      startPlaying();
      return;
    }
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void replay() {
    seekTo(Duration.zero);
    play();
  }

  void seekTo(Duration position) {
    _videoController?.seekTo(position);
    setState(() => _isEnded = false);
  }

  void _seekRelative(int seconds) {
    if (_videoController != null && _videoController!.value.isInitialized) {
      final current = _videoController!.value.position;
      final total = _videoController!.value.duration;
      final target = current + Duration(seconds: seconds);
      final clamped = Duration(
        seconds: target.inSeconds.clamp(0, total.inSeconds),
      );
      _videoController!.seekTo(clamped);
    }
    _startControlsTimer();
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _videoController?.setVolume(_isMuted ? 0.0 : 1.0);
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _startAutoSaveTimer() {
    _progressSaveTimer?.cancel();
    _progressSaveTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _saveProgression(),
    );
  }

  Future<void> _saveProgression() async {
    final tutorielId = widget.tutoriel.tutorielId;
    if (tutorielId == null || tutorielId.isEmpty) return;
    if (_videoController == null || !_videoController!.value.isInitialized) return;

    final position = _videoController!.value.position.inSeconds;
    if (position <= 0) return;

    final val = _videoController!.value;
    final termine = val.position >= val.duration && val.duration > Duration.zero;

    try {
      await ref.read(progressionControllerProvider).saveProgression(
            tutorielId: tutorielId,
            position: position,
            termine: termine,
          );
    } catch (_) {}
  }

  void _openFullscreen() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenVideoPlayerDialog(
          tutoriel: widget.tutoriel,
          controller: _videoController!,
          isMuted: _isMuted,
          isKidMode: widget.isKidMode,
          onToggleMute: _toggleMute,
          activeSuggestion: widget.isKidMode ? null : _activeSuggestion,
          activeSuggestionJouet: widget.isKidMode ? null : _activeSuggestionJouet,
          onDismissSuggestion: () {
            setState(() => _activeSuggestion = null);
          },
        ),
      ),
    ).then((_) {
      // Synchronisation au retour du plein écran
      if (mounted) {
        setState(() {
          _isPlaying = _videoController?.value.isPlaying ?? false;
        });
      }
    });
  }

  void _disposeController() {
    _controlsTimer?.cancel();
    _progressSaveTimer?.cancel();
    if (_videoController != null) {
      _videoController!.removeListener(_nativeVideoListener);
      _videoController!.dispose();
      _videoController = null;
    }
    _isInitialized = false;
    _isStarted = false;
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _saveProgression();
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. État Erreur
    if (_hasError) {
      return _buildErrorState(theme);
    }

    // 2. État Non encore démarré (Aperçu miniature Hero avec bouton Play)
    if (!_isStarted) {
      return _buildThumbnailHero(theme);
    }

    // 3. État Chargement / Initialisation
    if (!_isInitialized) {
      return _buildLoadingState(theme);
    }

    // 4. État Lecteur Vidéo Natif (Cloudinary / MP4)
    if (_videoController != null) {
      return _buildNativePlayer(theme);
    }

    return _buildThumbnailHero(theme);
  }

  /// État Non encore démarré (Aperçu miniature avec bouton Play moderne)
  Widget _buildThumbnailHero(ThemeData theme) {
    final primaryColor = widget.isKidMode
        ? const Color(0xFF22C55E)
        : (theme.colorScheme.primary);
    final secondaryColor = widget.isKidMode
        ? const Color(0xFF16A34A)
        : const Color(0xFF6366F1);

    final imageUrl = widget.tutoriel.miniatureUrl.isNotEmpty
        ? widget.tutoriel.miniatureUrl
        : 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=900&q=80';
    final durationSecs = widget.tutoriel.duree > 0
        ? widget.tutoriel.duree.toDouble()
        : (ref
                .watch(cloudinaryVideoDurationProvider(widget.tutoriel.videoUrl))
                .asData
                ?.value ??
            0.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.video_library_rounded, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: startPlaying,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.6),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (durationSecs > 0)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 13, color: Colors.white70),
                        const SizedBox(width: 5),
                        Text(
                          _formatDuration(durationSecs.round()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// État de chargement élégant (Miniature en arrière-plan + Loader animé)
  Widget _buildLoadingState(ThemeData theme) {
    final primaryColor = widget.isKidMode
        ? const Color(0xFF22C55E)
        : (theme.colorScheme.primary);

    final imageUrl = widget.tutoriel.miniatureUrl.isNotEmpty
        ? widget.tutoriel.miniatureUrl
        : 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=900&q=80';

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(Icons.video_library_rounded, size: 48, color: Colors.grey),
                  ),
                ),
              ),
              Container(
                color: Colors.black.withValues(alpha: 0.65),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Chargement de la vidéo...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// État d'erreur avec bouton réessai
  Widget _buildErrorState(ThemeData theme) {
    final primaryColor = widget.isKidMode
        ? const Color(0xFF22C55E)
        : (theme.colorScheme.primary);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_off_rounded,
                  color: theme.colorScheme.error,
                  size: 38,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage.isNotEmpty
                      ? _errorMessage
                      : 'Impossible de lire la vidéo',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _isInitialized = false;
                      _isStarted = false;
                    });
                    startPlaying();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Réessayer', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Lecteur Vidéo Natif (Cloudinary / Direct MP4)
  Widget _buildNativePlayer(ThemeData theme) {
    final isBuffering = _videoController?.value.isBuffering ?? false;
    final primaryColor = widget.isKidMode
        ? const Color(0xFF22C55E)
        : (theme.colorScheme.primary);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: GestureDetector(
            onTap: () {
              setState(() => _showControls = !_showControls);
              if (_showControls) _startControlsTimer();
            },
            behavior: HitTestBehavior.opaque,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Vidéo
                Center(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio.clamp(1.2, 1.9),
                    child: VideoPlayer(_videoController!),
                  ),
                ),

                // 2. Indicateur de mise en mémoire tampon
                if (isBuffering)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.35),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),

                // 3. Overlay de contrôles personnalisés
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_showControls,
                    child: _buildNativeControlsOverlay(theme),
                  ),
                ),

                // 4. Pop-up suggestion intelligente (masquée en mode enfant pour rester épuré)
                if (!widget.isKidMode && _activeSuggestion != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 50,
                    child: JouetSuggestionCard(
                      isCompact: true,
                      jouet: _activeSuggestionJouet,
                      jouetId: _activeSuggestion!.jouetId.isNotEmpty
                          ? _activeSuggestion!.jouetId
                          : null,
                      onClose: () {
                        setState(() => _activeSuggestion = null);
                        if (_wasPlayingBeforeSuggestion) {
                          play();
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Overlay de contrôle du lecteur natif inline
  Widget _buildNativeControlsOverlay(ThemeData theme) {
    final position = _videoController!.value.position.inSeconds;
    final totalDuration = _videoController!.value.duration.inSeconds;
    final primaryColor = widget.isKidMode
        ? const Color(0xFF22C55E)
        : (theme.colorScheme.primary);
    final secondaryColor = widget.isKidMode
        ? const Color(0xFF16A34A)
        : const Color(0xFF6366F1);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Barre supérieure
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildGlassIconButton(
                  icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  tooltip: _isMuted ? 'Activer le son' : 'Couper le son',
                  onPressed: _toggleMute,
                ),
                const SizedBox(width: 8),
                _buildGlassIconButton(
                  icon: Icons.fullscreen_rounded,
                  tooltip: 'Plein écran',
                  onPressed: _openFullscreen,
                ),
              ],
            ),
          ),

          // Contrôles centraux
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGlassIconButton(
                icon: Icons.replay_10_rounded,
                size: 24,
                padding: 10,
                tooltip: 'Reculer de 10s',
                onPressed: () => _seekRelative(-10),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: togglePlayPause,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.6),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isEnded
                        ? Icons.replay_rounded
                        : (_isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                    size: 34,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _buildGlassIconButton(
                icon: Icons.forward_10_rounded,
                size: 24,
                padding: 10,
                tooltip: 'Avancer de 10s',
                onPressed: () => _seekRelative(10),
              ),
            ],
          ),

          // Barre inférieure (Scrubber + Timestamps)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: VideoProgressIndicator(
                    _videoController!,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: primaryColor,
                      bufferedColor: Colors.white.withValues(alpha: 0.35),
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _formatDuration(totalDuration),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
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

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    double size = 18,
    double padding = 8,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }

  static String _formatDuration(int seconds) {
    if (seconds <= 0) return '00:00';
    final totalSeconds = seconds > 100000 ? (seconds ~/ 1000) : seconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final secs = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

/// Vue plein écran immersive avec contrôles complets (Landscape, scrubber, -10/+10, mute, suggestions)
class _FullscreenVideoPlayerDialog extends StatefulWidget {
  final Tutoriel tutoriel;
  final VideoPlayerController controller;
  final bool isMuted;
  final bool isKidMode;
  final VoidCallback onToggleMute;
  final Suggestion? activeSuggestion;
  final Jouet? activeSuggestionJouet;
  final VoidCallback onDismissSuggestion;

  const _FullscreenVideoPlayerDialog({
    required this.tutoriel,
    required this.controller,
    required this.isMuted,
    this.isKidMode = false,
    required this.onToggleMute,
    this.activeSuggestion,
    this.activeSuggestionJouet,
    required this.onDismissSuggestion,
  });

  @override
  State<_FullscreenVideoPlayerDialog> createState() =>
      _FullscreenVideoPlayerDialogState();
}

class _FullscreenVideoPlayerDialogState
    extends State<_FullscreenVideoPlayerDialog> {
  bool _showControls = true;
  Timer? _controlsTimer;
  late bool _isMuted;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.isMuted;

    // Verrouillage paysage & mode immersif complet
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    widget.controller.addListener(_controllerListener);
    _startControlsTimer();
  }

  void _controllerListener() {
    if (mounted) setState(() {});
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startControlsTimer();
    }
  }

  void _seekRelative(int seconds) {
    final current = widget.controller.value.position;
    final total = widget.controller.value.duration;
    final target = current + Duration(seconds: seconds);
    final clamped = Duration(
      seconds: target.inSeconds.clamp(0, total.inSeconds),
    );
    widget.controller.seekTo(clamped);
    _startControlsTimer();
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      if (widget.controller.value.position >= widget.controller.value.duration) {
        widget.controller.seekTo(Duration.zero);
      }
      widget.controller.play();
    }
    _startControlsTimer();
  }

  void _handleToggleMute() {
    setState(() => _isMuted = !_isMuted);
    widget.controller.setVolume(_isMuted ? 0.0 : 1.0);
    widget.onToggleMute();
    _startControlsTimer();
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    widget.controller.removeListener(_controllerListener);

    // Restauration du mode portrait et UI standard
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    final position = value.position.inSeconds;
    final duration = value.duration.inSeconds;
    final isEnded = value.position >= value.duration && value.duration > Duration.zero;

    final primaryColor = widget.isKidMode
        ? const Color(0xFF22C55E)
        : AppColors.primary;
    final secondaryColor = widget.isKidMode
        ? const Color(0xFF16A34A)
        : const Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Vidéo plein écran centrée
            Center(
              child: AspectRatio(
                aspectRatio: value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),

            // 2. Overlay de contrôles Plein Écran (sans titre)
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.75),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ── BARRE SUPÉRIEURE PLEIN ÉCRAN ──
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  tooltip: 'Quitter le plein écran',
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _isMuted
                                        ? Icons.volume_off_rounded
                                        : Icons.volume_up_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  onPressed: _handleToggleMute,
                                  tooltip: _isMuted
                                      ? 'Activer le son'
                                      : 'Couper le son',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── CONTRÔLES CENTRAUX PLEIN ÉCRAN (-10s / Play-Pause / +10s) ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.replay_10_rounded,
                                    color: Colors.white, size: 32),
                                onPressed: () => _seekRelative(-10),
                                tooltip: 'Reculer de 10s',
                              ),
                            ),
                            const SizedBox(width: 36),
                            GestureDetector(
                              onTap: _togglePlayPause,
                              child: Container(
                                width: 66,
                                height: 66,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, secondaryColor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.6),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isEnded
                                      ? Icons.replay_rounded
                                      : (value.isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded),
                                  size: 38,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 36),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.forward_10_rounded,
                                    color: Colors.white, size: 32),
                                onPressed: () => _seekRelative(10),
                                tooltip: 'Avancer de 10s',
                              ),
                            ),
                          ],
                        ),

                        // ── BARRE INFÉRIEURE PLEIN ÉCRAN (Scrubber + Timestamps + Exit) ──
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: VideoProgressIndicator(
                                  widget.controller,
                                  allowScrubbing: true,
                                  colors: VideoProgressColors(
                                    playedColor: primaryColor,
                                    bufferedColor:
                                        Colors.white.withValues(alpha: 0.35),
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.2),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_TutorielInlineVideoPlayerState._formatDuration(position)} / ${_TutorielInlineVideoPlayerState._formatDuration(duration)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.fullscreen_exit_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    tooltip: 'Quitter le plein écran',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Popup suggestion contextuelle en plein écran (uniquement hors mode enfant)
            if (!widget.isKidMode && widget.activeSuggestion != null)
              Positioned(
                left: 24,
                bottom: 60,
                width: 320,
                child: JouetSuggestionCard(
                  isCompact: true,
                  jouet: widget.activeSuggestionJouet,
                  jouetId: widget.activeSuggestion!.jouetId.isNotEmpty
                      ? widget.activeSuggestion!.jouetId
                      : null,
                  onClose: widget.onDismissSuggestion,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Alias pour compatibilité descendante
typedef VideoPlayerWidget = TutorielInlineVideoPlayer;
