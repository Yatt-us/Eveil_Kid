import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import 'duolingo_option_tile.dart';

/// Thème visuel complet pour chaque paire d'association (côté client)
class _PairColorTheme {
  final Color backgroundLight;
  final Color backgroundDark;
  final Color border;
  final Color bottomBorder;
  final Color textLight;
  final Color textDark;
  final Color badgeBg;
  final Color badgeText;
  final IconData icon;

  const _PairColorTheme({
    required this.backgroundLight,
    required this.backgroundDark,
    required this.border,
    required this.bottomBorder,
    required this.textLight,
    required this.textDark,
    required this.badgeBg,
    required this.badgeText,
    required this.icon,
  });
}

/// Palette de couleurs vives et distinctes pour chaque paire
const List<_PairColorTheme> _clientPairThemes = [
  // 1. Violet Magique
  _PairColorTheme(
    backgroundLight: Color(0xFFF3E8FF),
    backgroundDark: Color(0xFF3B0764),
    border: Color(0xFFA855F7),
    bottomBorder: Color(0xFF7E22CE),
    textLight: Color(0xFF6B21A8),
    textDark: Color(0xFFE9D5FF),
    badgeBg: Color(0xFFA855F7),
    badgeText: Colors.white,
    icon: Icons.auto_awesome_rounded,
  ),
  // 2. Corail / Orange Énergie
  _PairColorTheme(
    backgroundLight: Color(0xFFFFEDD5),
    backgroundDark: Color(0xFF431407),
    border: Color(0xFFF97316),
    bottomBorder: Color(0xFFC2410C),
    textLight: Color(0xFF9A3412),
    textDark: Color(0xFFFED7AA),
    badgeBg: Color(0xFFF97316),
    badgeText: Colors.white,
    icon: Icons.local_fire_department_rounded,
  ),
  // 3. Bleu Océan
  _PairColorTheme(
    backgroundLight: Color(0xFFE0F2FE),
    backgroundDark: Color(0xFF082F49),
    border: Color(0xFF0EA5E9),
    bottomBorder: Color(0xFF0369A1),
    textLight: Color(0xFF075985),
    textDark: Color(0xFFBAE6FD),
    badgeBg: Color(0xFF0EA5E9),
    badgeText: Colors.white,
    icon: Icons.water_drop_rounded,
  ),
  // 4. Émeraude / Vert Nature
  _PairColorTheme(
    backgroundLight: Color(0xFFDCFCE7),
    backgroundDark: Color(0xFF052E16),
    border: Color(0xFF22C55E),
    bottomBorder: Color(0xFF15803D),
    textLight: Color(0xFF14532D),
    textDark: Color(0xFF86EFAC),
    badgeBg: Color(0xFF22C55E),
    badgeText: Colors.white,
    icon: Icons.eco_rounded,
  ),
  // 5. Rose Bonbon
  _PairColorTheme(
    backgroundLight: Color(0xFFFCE7F3),
    backgroundDark: Color(0xFF500724),
    border: Color(0xFFEC4899),
    bottomBorder: Color(0xFFBE185D),
    textLight: Color(0xFF9D174D),
    textDark: Color(0xFFFBCFE8),
    badgeBg: Color(0xFFEC4899),
    badgeText: Colors.white,
    icon: Icons.favorite_rounded,
  ),
  // 6. Jaune / Or Ensoleillé
  _PairColorTheme(
    backgroundLight: Color(0xFFFEF3C7),
    backgroundDark: Color(0xFF451A03),
    border: Color(0xFFF59E0B),
    bottomBorder: Color(0xFFB45309),
    textLight: Color(0xFF78350F),
    textDark: Color(0xFFFDE68A),
    badgeBg: Color(0xFFF59E0B),
    badgeText: Colors.white,
    icon: Icons.star_rounded,
  ),
  // 7. Indigo Électrique
  _PairColorTheme(
    backgroundLight: Color(0xFFE0E7FF),
    backgroundDark: Color(0xFF1E1B4B),
    border: Color(0xFF6366F1),
    bottomBorder: Color(0xFF4338CA),
    textLight: Color(0xFF3730A3),
    textDark: Color(0xFFC7D2FE),
    badgeBg: Color(0xFF6366F1),
    badgeText: Colors.white,
    icon: Icons.bolt_rounded,
  ),
  // 8. Turquoise Cristal
  _PairColorTheme(
    backgroundLight: Color(0xFFCCFBF1),
    backgroundDark: Color(0xFF042F2E),
    border: Color(0xFF14B8A6),
    bottomBorder: Color(0xFF0F766E),
    textLight: Color(0xFF115E59),
    textDark: Color(0xFF99F6E4),
    badgeBg: Color(0xFF14B8A6),
    badgeText: Colors.white,
    icon: Icons.diamond_rounded,
  ),
];

class DuolingoAssociationWidget extends StatefulWidget {
  final List<OptionQuestion> options;
  final bool isAnswered;
  final Function(bool isAllMatched) onCompletionChanged;

  const DuolingoAssociationWidget({
    super.key,
    required this.options,
    required this.isAnswered,
    required this.onCompletionChanged,
  });

  @override
  State<DuolingoAssociationWidget> createState() => _DuolingoAssociationWidgetState();
}

class _DuolingoAssociationWidgetState extends State<DuolingoAssociationWidget> {
  final List<_PairItem> _leftItems = [];
  final List<_PairItem> _rightItems = [];

  String? _selectedLeftId;
  String? _selectedRightId;
  String? _errorLeftId;
  String? _errorRightId;
  final Set<String> _matchedPairIds = {};

  @override
  void initState() {
    super.initState();
    _extractPairs();
  }

  @override
  void didUpdateWidget(covariant DuolingoAssociationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options != widget.options) {
      _extractPairs();
    }
  }

  void _extractPairs() {
    _leftItems.clear();
    _rightItems.clear();
    _matchedPairIds.clear();
    _selectedLeftId = null;
    _selectedRightId = null;
    _errorLeftId = null;
    _errorRightId = null;

    for (int i = 0; i < widget.options.length; i++) {
      final opt = widget.options[i];
      String leftText = opt.texte.trim();
      String rightText = 'Paire ${i + 1}';

      if (opt.texte.contains('->')) {
        final parts = opt.texte.split('->');
        leftText = parts.first.trim();
        rightText = parts.length > 1 ? parts.last.trim() : 'Paire ${i + 1}';
      } else if (opt.texte.contains(':')) {
        final parts = opt.texte.split(':');
        leftText = parts.first.trim();
        rightText = parts.length > 1 ? parts.last.trim() : 'Paire ${i + 1}';
      } else if (opt.texte.contains('=')) {
        final parts = opt.texte.split('=');
        leftText = parts.first.trim();
        rightText = parts.length > 1 ? parts.last.trim() : 'Paire ${i + 1}';
      }

      if (leftText.isEmpty) leftText = 'Élément ${i + 1}';
      if (rightText.isEmpty) rightText = 'Paire ${i + 1}';

      final pairId = opt.id.isNotEmpty ? opt.id : 'pair_$i';

      _leftItems.add(_PairItem(
        id: pairId,
        text: leftText,
        imageUrl: opt.imageUrl,
        pairIndex: i,
      ));
      _rightItems.add(_PairItem(
        id: pairId,
        text: rightText,
        pairIndex: i,
      ));
    }

    // Mélanger la colonne de droite pour le jeu
    _rightItems.shuffle();
  }

  void _onLeftTap(String id) {
    if (widget.isAnswered || _matchedPairIds.contains(id) || _errorLeftId != null) return;
    HapticFeedback.selectionClick();

    setState(() {
      _selectedLeftId = id;
    });
    _checkMatching();
  }

  void _onRightTap(String id) {
    if (widget.isAnswered || _matchedPairIds.contains(id) || _errorRightId != null) return;
    HapticFeedback.selectionClick();

    setState(() {
      _selectedRightId = id;
    });
    _checkMatching();
  }

  void _checkMatching() {
    if (_selectedLeftId != null && _selectedRightId != null) {
      if (_selectedLeftId == _selectedRightId) {
        // Paire correcte !
        HapticFeedback.mediumImpact();
        setState(() {
          _matchedPairIds.add(_selectedLeftId!);
          _selectedLeftId = null;
          _selectedRightId = null;
        });

        final isAllMatched = _matchedPairIds.length == _leftItems.length;
        widget.onCompletionChanged(isAllMatched);
      } else {
        // Paire incorrecte -> flash rouge et réinitialisation rapide
        HapticFeedback.heavyImpact();
        final errL = _selectedLeftId;
        final errR = _selectedRightId;

        setState(() {
          _errorLeftId = errL;
          _errorRightId = errR;
          _selectedLeftId = null;
          _selectedRightId = null;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          setState(() {
            _errorLeftId = null;
            _errorRightId = null;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAllComplete = _matchedPairIds.length == _leftItems.length && _leftItems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. EN-TÊTE DE CONSIGNE LUDIQUE ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: KidTheme.playfulPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    size: 18,
                    color: KidTheme.playfulPurple,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Relie chaque paire correspondante :',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: isAllComplete
                    ? const Color(0xFFDCFCE7)
                    : (isDark ? const Color(0xFF2E2E36) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAllComplete
                      ? const Color(0xFF22C55E)
                      : (isDark ? const Color(0xFF383842) : const Color(0xFFCBD5E1)),
                ),
              ),
              child: Text(
                '${_matchedPairIds.length}/${_leftItems.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isAllComplete
                      ? const Color(0xFF15803D)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── 2. COLONNES D'ASSOCIATION GAUCHE & DROITE AVEC COULEURS DISTINCTES ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colonne Gauche
            Expanded(
              child: Column(
                children: _leftItems.map((item) {
                  final isMatched = _matchedPairIds.contains(item.id);
                  final isSelected = _selectedLeftId == item.id;
                  final isError = _errorLeftId == item.id;

                  final colorTheme = _clientPairThemes[item.pairIndex % _clientPairThemes.length];

                  DuolingoTileState state = DuolingoTileState.neutral;
                  if (isError) {
                    state = DuolingoTileState.incorrect;
                  } else if (isMatched) {
                    state = DuolingoTileState.correct;
                  } else if (isSelected) {
                    state = DuolingoTileState.selected;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DuolingoOptionTile(
                      text: item.text,
                      imageUrl: item.imageUrl,
                      state: state,
                      isCompact: true,
                      badgeIcon: isMatched ? colorTheme.icon : null,
                      customBackgroundColor: isMatched
                          ? (isDark ? colorTheme.backgroundDark : colorTheme.backgroundLight)
                          : (isSelected
                              ? (isDark
                                  ? colorTheme.backgroundDark.withValues(alpha: 0.6)
                                  : colorTheme.backgroundLight)
                              : null),
                      customBorderColor: isMatched || isSelected ? colorTheme.border : null,
                      customBottomBorderColor:
                          isMatched || isSelected ? colorTheme.bottomBorder : null,
                      customTextColor: isMatched || isSelected
                          ? (isDark ? colorTheme.textDark : colorTheme.textLight)
                          : null,
                      customBadgeColor: isMatched ? colorTheme.badgeBg : null,
                      customBadgeTextColor: isMatched ? colorTheme.badgeText : null,
                      onTap: () => _onLeftTap(item.id),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 12),

            // Colonne Droite
            Expanded(
              child: Column(
                children: _rightItems.map((item) {
                  final isMatched = _matchedPairIds.contains(item.id);
                  final isSelected = _selectedRightId == item.id;
                  final isError = _errorRightId == item.id;

                  final colorTheme = _clientPairThemes[item.pairIndex % _clientPairThemes.length];

                  DuolingoTileState state = DuolingoTileState.neutral;
                  if (isError) {
                    state = DuolingoTileState.incorrect;
                  } else if (isMatched) {
                    state = DuolingoTileState.correct;
                  } else if (isSelected) {
                    state = DuolingoTileState.selected;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DuolingoOptionTile(
                      text: item.text,
                      state: state,
                      isCompact: true,
                      badgeIcon: isMatched ? colorTheme.icon : null,
                      customBackgroundColor: isMatched
                          ? (isDark ? colorTheme.backgroundDark : colorTheme.backgroundLight)
                          : (isSelected
                              ? (isDark
                                  ? colorTheme.backgroundDark.withValues(alpha: 0.6)
                                  : colorTheme.backgroundLight)
                              : null),
                      customBorderColor: isMatched || isSelected ? colorTheme.border : null,
                      customBottomBorderColor:
                          isMatched || isSelected ? colorTheme.bottomBorder : null,
                      customTextColor: isMatched || isSelected
                          ? (isDark ? colorTheme.textDark : colorTheme.textLight)
                          : null,
                      customBadgeColor: isMatched ? colorTheme.badgeBg : null,
                      customBadgeTextColor: isMatched ? colorTheme.badgeText : null,
                      onTap: () => _onRightTap(item.id),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        // ── 3. BANNIÈRE DE SUCCÈS QUAND TOUTES LES PAIRES SONT RELIÉES ──
        if (isAllComplete) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF052E16) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF22C55E),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Super ! Toutes les paires sont reliées !',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF14532D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PairItem {
  final String id;
  final String text;
  final String? imageUrl;
  final int pairIndex;

  _PairItem({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.pairIndex,
  });
}
