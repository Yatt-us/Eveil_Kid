import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';

class DuolingoFeedbackBottomBar extends StatelessWidget {
  final bool isAnswered;
  final bool isCorrect;
  final bool isReadyToVerify;
  final bool isLastStep;
  final String? correctAnswerText;
  final VoidCallback onVerify;
  final VoidCallback onNextStep;
  final VoidCallback? onSkip;

  const DuolingoFeedbackBottomBar({
    super.key,
    required this.isAnswered,
    required this.isCorrect,
    required this.isReadyToVerify,
    required this.isLastStep,
    this.correctAnswerText,
    required this.onVerify,
    required this.onNextStep,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!isAnswered) {
      // ── BARRE D'ACTION INITIALE (VÉRIFIER / PASSER) ──
      return Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (onSkip != null) ...[
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onSkip!();
                },
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Passer',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: _Duolingo3DButton(
                text: 'Vérifier',
                icon: Icons.check_rounded,
                color: isReadyToVerify
                    ? KidTheme.primaryGreen
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                bottomBorderColor: isReadyToVerify
                    ? KidTheme.primaryGreenDark
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
                textColor: isReadyToVerify
                    ? Colors.white
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                isEnabled: isReadyToVerify,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onVerify();
                },
              ),
            ),
          ],
        ),
      );
    }

    // ── BANNIÈRE DE FEEDBACK ANIMÉE (SUCCÈS / ERREUR) ──
    final feedbackBgColor = isCorrect
        ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7))
        : (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2));

    final feedbackTextColor = isCorrect
        ? (isDark ? const Color(0xFF86EFAC) : const Color(0xFF14532D))
        : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B));

    final buttonColor = isCorrect
        ? KidTheme.primaryGreen
        : const Color(0xFFEF4444);

    final buttonBottomColor = isCorrect
        ? KidTheme.primaryGreenDark
        : const Color(0xFFB91C1C);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: BoxDecoration(
        color: feedbackBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isCorrect
              ? const Color(0xFF22C55E).withValues(alpha: 0.4)
              : const Color(0xFFEF4444).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isCorrect
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect
                      ? Icons.check_rounded
                      : Icons.close_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCorrect ? 'C\'est super !' : 'Oups ! Pas tout à fait...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: feedbackTextColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (!isCorrect && correctAnswerText != null && correctAnswerText!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Bonne réponse : $correctAnswerText',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: feedbackTextColor.withValues(alpha: 0.95),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: _Duolingo3DButton(
              text: isLastStep ? 'Terminer le défi' : 'Étape suivante',
              icon: isLastStep ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
              color: buttonColor,
              bottomBorderColor: buttonBottomColor,
              textColor: Colors.white,
              isEnabled: true,
              onPressed: () {
                HapticFeedback.mediumImpact();
                onNextStep();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton 3D physique avec enfoncement tactile à la pression
class _Duolingo3DButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final Color bottomBorderColor;
  final Color textColor;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _Duolingo3DButton({
    required this.text,
    this.icon,
    required this.color,
    required this.bottomBorderColor,
    required this.textColor,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  State<_Duolingo3DButton> createState() => _Duolingo3DButtonState();
}

class _Duolingo3DButtonState extends State<_Duolingo3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bottomThickness = 4.0;
    final double verticalShift = _isPressed && widget.isEnabled ? 2.5 : 0.0;
    final double activeBottomEdge = _isPressed && widget.isEnabled ? 1.5 : bottomThickness;

    return GestureDetector(
      onTapDown: widget.isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutQuad,
        margin: EdgeInsets.only(
          top: verticalShift,
          bottom: bottomThickness - verticalShift,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.color,
            width: 1.5,
          ),
          boxShadow: [
            if (!_isPressed && widget.isEnabled)
              BoxShadow(
                color: widget.bottomBorderColor,
                blurRadius: 0,
                offset: Offset(0, activeBottomEdge),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.text,
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                color: widget.textColor,
                letterSpacing: 0.2,
              ),
            ),
            if (widget.icon != null) ...[
              const SizedBox(width: 8),
              Icon(widget.icon, size: 20, color: widget.textColor),
            ],
          ],
        ),
      ),
    );
  }
}
