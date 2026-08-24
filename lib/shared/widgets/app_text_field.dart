import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/AppRadius.dart';

/// Champ de saisie réutilisable flat, simple et professionnel :
/// Fond plat (surface), bordures fines (1.0px / bordure active minime 1.2px),
/// typographie soignée et transitions nettes.
class AppTextField extends StatefulWidget {
  final String? label;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.label,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late FocusNode _internalFocusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.removeListener(_handleFocusChange);
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? suffix = widget.suffixIcon;

    if (widget.isPassword && suffix == null) {
      suffix = IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: _isFocused ? AppColors.primary : AppColors.icon,
          size: 19,
        ),
        tooltip: _obscureText ? "Afficher" : "Masquer",
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _internalFocusNode,
          onTapOutside: (event) => _internalFocusNode.unfocus(),
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            letterSpacing: 0.1,
          ),
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
            ),
            floatingLabelStyle: const TextStyle(
              color: AppColors.primary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.65),
              fontSize: 13.5,
              fontWeight: FontWeight.normal,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused ? AppColors.primary : AppColors.icon,
                    size: 19,
                  )
                : null,
            suffixIcon: suffix,
            filled: true,
            fillColor: widget.enabled
                ? AppColors.surface
                : AppColors.surfaceVariant.withValues(alpha: 0.4),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: const OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(
                color: AppColors.border,
                width: 1.0,
              ),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(
                color: AppColors.border,
                width: 1.0,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(
                color: AppColors.danger,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(
                color: AppColors.danger,
                width: 1.2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.4),
                width: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
