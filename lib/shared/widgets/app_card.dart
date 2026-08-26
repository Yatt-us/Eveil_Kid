import 'package:flutter/material.dart';
import '../../core/constants/AppRadius.dart';

/// Carte générique et responsive pour l'application et l'espace admin.
///
/// Ne génère aucun espacement superflu lorsque des paramètres optionnels
/// (titre, sous-titre, trailing, leading, footer) ne sont pas fournis.
class AppCard extends StatelessWidget {
  final Widget child;
  final Widget? leading;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? footer;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? customShadow;

  const AppCard({
    super.key,
    required this.child,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.footer,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation = 0,
    this.borderRadius,
    this.border,
    this.customShadow,
  });

  bool get _hasTitle => title != null && title!.trim().isNotEmpty;
  bool get _hasSubtitle => subtitle != null && subtitle!.trim().isNotEmpty;
  bool get _hasHeader => _hasTitle || _hasSubtitle || trailing != null || leading != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveRadius = borderRadius ?? AppRadius.card;
    final effectiveBorder = border ??
        Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 1,
        );

    return Container(
      margin: margin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 340;
          final effectivePadding = padding ??
              EdgeInsets.all(isCompact ? 12 : 16);

          return Material(
            color: backgroundColor ??
                theme.cardTheme.color ??
                theme.colorScheme.surface,
            borderRadius: effectiveRadius,
            elevation: elevation,
            child: InkWell(
              onTap: onTap,
              borderRadius: effectiveRadius,
              child: Container(
                padding: effectivePadding,
                decoration: BoxDecoration(
                  borderRadius: effectiveRadius,
                  border: effectiveBorder,
                  boxShadow: customShadow ??
                      (elevation > 0
                          ? null
                          : [
                              BoxShadow(
                                color: (theme.textTheme.bodyMedium?.color ?? Colors.black)
                                    .withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hasHeader) ...[
                      _buildHeader(context, isCompact),
                      SizedBox(height: isCompact ? 8 : 12),
                    ],
                    child,
                    if (footer != null) ...[
                      SizedBox(height: isCompact ? 8 : 12),
                      Divider(
                        height: 1,
                        color: theme.dividerColor.withValues(alpha: 0.2),
                      ),
                      SizedBox(height: isCompact ? 6 : 8),
                      footer!,
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          SizedBox(width: isCompact ? 8 : 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hasTitle)
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: isCompact ? 15 : 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color ??
                        theme.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              if (_hasSubtitle) ...[
                if (_hasTitle) const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: isCompact ? 12 : 13,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
                        theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}
