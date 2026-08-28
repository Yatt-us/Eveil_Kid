import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      return '$first$second'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : '';
  }

  ImageProvider? _resolveImageProvider(String? source) {
    if (source == null) return null;
    final trimmed = source.trim();
    if (trimmed.isEmpty) return null;

    // 1. Data URI ou Base64 (ex: data:image/jpeg;base64,....)
    if (trimmed.startsWith('data:image') || trimmed.contains(';base64,')) {
      try {
        final commaIndex = trimmed.indexOf(',');
        final base64String =
            commaIndex != -1 ? trimmed.substring(commaIndex + 1) : trimmed;
        final cleanBase64 = base64String.replaceAll(RegExp(r'\s+'), '');
        final Uint8List bytes = base64Decode(cleanBase64);
        return MemoryImage(bytes);
      } catch (e) {
        debugPrint('Erreur décodage Base64 avatar: $e');
        return null;
      }
    }

    // 2. URL HTTP / HTTPS
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }

    // 3. Fichier local
    if (trimmed.startsWith('/') ||
        trimmed.startsWith('file://') ||
        trimmed.contains(r':\')) {
      try {
        final cleanPath = trimmed.replaceFirst('file://', '');
        return FileImage(File(cleanPath));
      } catch (_) {
        return null;
      }
    }

    // 4. Base64 pur sans préfixe
    if (trimmed.length > 50 && !trimmed.contains('/')) {
      try {
        final cleanBase64 = trimmed.replaceAll(RegExp(r'\s+'), '');
        final Uint8List bytes = base64Decode(cleanBase64);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageProvider = _resolveImageProvider(imageUrl);
    Widget avatarWidget;

    if (imageProvider != null) {
      avatarWidget = CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
        onBackgroundImageError: (_, _) {
          // Gestion douce des erreurs de chargement réseau/mémoire
        },
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
        child: Icon(
          defaultIcon,
          size: radius * 1.1,
          color: theme.colorScheme.primary,
        ),
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
