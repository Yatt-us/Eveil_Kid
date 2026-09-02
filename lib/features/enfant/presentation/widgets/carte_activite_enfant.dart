import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_card.dart';

/// Carte d'activité 3D tactile style Duolingo pour l'espace enfant
class CarteActiviteEnfant extends StatefulWidget {
  final String titre;
  final String duree;
  final String imageUrl;
  final double progression;
  final int points;
  final VoidCallback? onTap;

  const CarteActiviteEnfant({
    super.key,
    required this.titre,
    required this.duree,
    required this.imageUrl,
    required this.progression,
    this.points = 15,
    this.onTap,
  });

  @override
  State<CarteActiviteEnfant> createState() => _CarteActiviteEnfantState();
}

class _CarteActiviteEnfantState extends State<CarteActiviteEnfant> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompleted = widget.progression >= 0.99;

    return DuolingoCard(
      onTap: widget.onTap,
      borderRadius: 22,
      bottomThickness: 4.0,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // 1. Vignette Illustration 3D
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: isDark
                    ? KidTheme.primaryGreen.withValues(alpha: 0.2)
                    : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: widget.imageUrl.startsWith('http')
                  ? Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.sports_esports_rounded,
                        color: KidTheme.primaryGreenDark,
                        size: 32,
                      ),
                    )
                  : Center(
                      child: Text(
                        widget.imageUrl.isNotEmpty ? widget.imageUrl : '🎮',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 14),

          // 2. Informations & Badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.duree,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF78350F).withValues(alpha: 0.4)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '+${widget.points} pts',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: widget.progression.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: isDark
                        ? Colors.black26
                        : KidTheme.primaryGreen.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      KidTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 3. Bouton rond 3D style Duolingo
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCompleted
                  ? KidTheme.primaryGreen
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFDCFCE7)),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted
                    ? KidTheme.primaryGreenDark
                    : (isDark ? const Color(0xFF475569) : const Color(0xFFBBF7D0)),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isCompleted
                      ? KidTheme.primaryGreenDark.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: 0,
                  offset: const Offset(0, 2.5),
                ),
              ],
            ),
            child: Icon(
              isCompleted ? Icons.replay_rounded : Icons.play_arrow_rounded,
              color: isCompleted ? Colors.white : KidTheme.primaryGreenDark,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}