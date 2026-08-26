import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final IconData defaultIcon;
  final bool isOnline;
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24,
    this.defaultIcon = Icons.face_rounded,
    this.isOnline = false,
    this.onTap,
  });

  String get _initials {
    if (name == null || name!.trim().isEmpty) return '';
    final parts = name!.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      return '$first$second'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget avatarWidget;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarWidget = CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      );
    } else if (_initials.isNotEmpty) {
      avatarWidget = CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.primary,
        child: Text(
          _initials,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.7,
          ),
        ),
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(defaultIcon, size: radius * 1.1, color: theme.colorScheme.primary),
      );
    }

    if (onTap != null) {
      avatarWidget = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: avatarWidget,
      );
    }

    if (isOnline) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.5,
              height: radius * 0.5,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return avatarWidget;
  }
}
