import 'package:flutter/material.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/question.dart';

/// Tuile représentant une option de quiz (mode liste ou grille 2x2).
class QuizOptionTile extends StatelessWidget {
  final OptionQuestion option;
  final bool isSelected;
  final bool isGrid;
  final VoidCallback onTap;

  const QuizOptionTile({
    super.key,
    required this.option,
    required this.isSelected,
    this.isGrid = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return isGrid ? _buildGridTile() : _buildListTile();
  }

  Widget _buildListTile() {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F8F5) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00A859) : const Color(0xFFEEEEEE),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00A859).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            if (option.imagePath?.isNotEmpty == true) ...[
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  option.imagePath!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(Icons.image, size: 28, color: Colors.grey),
                ),
              ),
              AppSpacing.horizontalMd,
            ],
            Expanded(
              child: Text(
                option.texte,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF00A859),
                size: 26,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridTile() {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F8F5) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00A859) : const Color(0xFFEEEEEE),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00A859).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (option.imagePath?.isNotEmpty == true)
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        option.imagePath!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(Icons.image, size: 36, color: Colors.grey),
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  option.texte,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (isSelected)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF00A859),
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
