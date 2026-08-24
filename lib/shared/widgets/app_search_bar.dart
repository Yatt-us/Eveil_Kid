import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/AppRadius.dart';

/// Barre de recherche épurée, flat et professionnelle :
/// Fond plat (surface), bordure fine (1.0px / bordure active minime 1.2px),
/// taille optimisée et icônes discrètes.
class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    this.hintText = 'Rechercher...',
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.controller,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChange);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.removeListener(_onTextChange);
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChange() {
    final hasTextNow = _controller.text.isNotEmpty;
    if (_hasText != hasTextNow) {
      setState(() => _hasText = hasTextNow);
    }
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.input,
        border: Border.all(
          color: _isFocused ? AppColors.primary : AppColors.border,
          width: _isFocused ? 1.2 : 1.0,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onTapOutside: (event) => _focusNode.unfocus(),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            letterSpacing: 0.1,
          ),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.65),
              fontSize: 13.5,
              fontWeight: FontWeight.normal,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isFocused ? AppColors.primary : AppColors.icon,
              size: 19,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_hasText)
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.icon,
                      size: 17,
                    ),
                    tooltip: 'Effacer',
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                    },
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                if (widget.onFilterTap != null)
                  IconButton(
                    icon: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    tooltip: 'Filtres',
                    onPressed: widget.onFilterTap,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 8, left: 4),
                  ),
              ],
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ),
    );
  }
}
