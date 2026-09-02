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

    // 1. Data URI ou Base64 avec préfixe (ex: data:image/jpeg;base64,....)
    if (trimmed.startsWith('data:image') || trimmed.contains(';base64,')) {
      try {
        final commaIndex = trimmed.indexOf(',');
        final base64Part =
            commaIndex != -1 ? trimmed.substring(commaIndex + 1) : trimmed;
        
        // Nettoyage : enlever TOUT ce qui n'est pas base64 (espaces, retours à la ligne, etc.)
        final cleanBase64 = base64Part.replaceAll(RegExp(r'[^a-zA-Z0-9+/=]'), '');
        
        // Vérification et ajout du padding si nécessaire
        var finalBase64 = cleanBase64;
        final remainder = finalBase64.length % 4;
        if (remainder > 0) {
          finalBase64 += '=' * (4 - remainder);
        }

        final Uint8List bytes = base64Decode(finalBase64);
        return MemoryImage(bytes);
      } catch (e) {
        debugPrint('AppAvatar: Erreur décodage Base64 (URI): $e');
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

    // 4. Base64 pur sans préfixe (longueur importante)
    if (trimmed.length > 50 && !trimmed.contains(' ')) {
      try {
        final cleanBase64 = trimmed.replaceAll(RegExp(r'[^a-zA-Z0-9+/=]'), '');
        var finalBase64 = cleanBase64;
        final remainder = finalBase64.length % 4;
        if (remainder > 0) {
          finalBase64 += '=' * (4 - remainder);
        }
        final Uint8List bytes = base64Decode(finalBase64);
        return MemoryImage(bytes);
      } catch (_) {
        // Pas du base64 valide
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageProvider = _resolveImageProvider(imageUrl);
    
    Widget content;
    
    if (imageProvider != null) {
      content = Image(
        image: imageProvider,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('AppAvatar: Erreur rendu image: $error');
          return _buildFallback(theme);
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
      );
    } else {
      content = _buildFallback(theme);
    }

    Widget avatarWidget = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: imageProvider != null 
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.primary,
      ),
      child: ClipOval(child: content),
    );

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

  Widget _buildFallback(ThemeData theme) {
    if (_initials.isNotEmpty) {
      return Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.7,
          ),
        ),
      );
    }
    return Center(
      child: Icon(
        defaultIcon,
        size: radius * 1.1,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
