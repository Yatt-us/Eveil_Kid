import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:eveilkid/core/cloudinary/cloudinary_config.dart';

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  /// Cache statique en mémoire des durées vidéo (URL -> secondes)
  static final Map<String, double> _durationCache = {};

  CloudinaryService({
    String? cloudName,
    String? uploadPreset,
  })  : cloudName = cloudName ?? CloudinaryConfig.cloudName,
        uploadPreset = uploadPreset ?? CloudinaryConfig.uploadPreset;

  /// Upload unsigned d'une image vers Cloudinary
  Future<String> uploadImage(
    File file, {
    String? folder,
    String? publicId,
  }) async {
    return _uploadDirect(
      file: file,
      resourceType: 'image',
      folder: folder,
      publicId: publicId,
    );
  }

  /// Upload unsigned d'une vidéo vers Cloudinary
  Future<String> uploadVideo(
    File file, {
    String? folder,
    String? publicId,
  }) async {
    return _uploadDirect(
      file: file,
      resourceType: 'video',
      folder: folder,
      publicId: publicId,
    );
  }

  /// Upload unsigned générique de fichier (image, vidéo, raw, auto)
  Future<String> uploadFile(
    File file, {
    String? folder,
    String? resourceType,
    String? publicId,
  }) async {
    return _uploadDirect(
      file: file,
      resourceType: resourceType ?? 'auto',
      folder: folder,
      publicId: publicId,
    );
  }

  /// Récupère la durée d'une vidéo en secondes :
  /// 1. Vérifie le cache mémoire
  /// 2. Tente l'API métadonnées Cloudinary JSON
  /// 3. Fallback ultra-rapide via header probe natif (VideoPlayerController)
  Future<double> getVideoDuration(String videoUrl) async {
    final cleanUrl = videoUrl.trim();
    if (cleanUrl.isEmpty) return 0.0;

    // 1. Vérifier le cache mémoire
    if (_durationCache.containsKey(cleanUrl)) {
      return _durationCache[cleanUrl]!;
    }

    // 2. Tenter l'API métadonnées Cloudinary JSON
    try {
      final publicId = _extractPublicId(cleanUrl);
      if (publicId != null && publicId.isNotEmpty) {
        final metaUrl = Uri.parse(
          'https://res.cloudinary.com/$cloudName/video/upload/$publicId.json',
        );

        debugPrint('☁️ [Cloudinary] Récupération métadonnées: $metaUrl');
        final response = await http.get(metaUrl).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final duration = data['duration'];
          if (duration is num && duration > 0) {
            final durationDouble = duration.toDouble();
            _durationCache[cleanUrl] = durationDouble;
            debugPrint('✅ [Cloudinary JSON] Durée récupérée: ${durationDouble}s');
            return durationDouble;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [Cloudinary JSON API] Non disponible: $e');
    }

    // 3. Fallback par header probe natif (initialise juste l'en-tête vidéo et dispose immédiatement)
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(cleanUrl));
      await controller.initialize().timeout(const Duration(seconds: 6));
      final durationSec = controller.value.duration.inMilliseconds / 1000.0;
      await controller.dispose();

      if (durationSec > 0) {
        _durationCache[cleanUrl] = durationSec;
        debugPrint('✅ [Video Probe] Durée détectée: ${durationSec}s');
        return durationSec;
      }
    } catch (e) {
      debugPrint('⚠️ [Video Probe] Échec détection durée: $e');
    }

    return 0.0;
  }

  /// Extrait le publicId depuis une URL Cloudinary complète.
  String? _extractPublicId(String videoUrl) {
    try {
      final uri = Uri.tryParse(videoUrl);
      if (uri == null) return null;

      final segments = uri.pathSegments;
      final uploadIdx = segments.indexOf('upload');
      if (uploadIdx == -1 || uploadIdx + 1 >= segments.length) return null;

      var parts = segments.sublist(uploadIdx + 1);

      // Ignorer le segment de version s'il commence par 'v' suivi de chiffres
      if (parts.isNotEmpty && RegExp(r'^v\d+$').hasMatch(parts.first)) {
        parts = parts.sublist(1);
      }

      if (parts.isEmpty) return null;

      final joined = parts.join('/');
      final lastDot = joined.lastIndexOf('.');
      return lastDot != -1 ? joined.substring(0, lastDot) : joined;
    } catch (_) {
      return null;
    }
  }

  /// Mécanisme d'upload REST Unsigned vers Cloudinary
  Future<String> _uploadDirect({
    required File file,
    required String resourceType,
    String? folder,
    String? publicId,
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload',
      );

      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = uploadPreset;

      if (folder != null && folder.trim().isNotEmpty) {
        request.fields['folder'] = folder.trim();
      }

      if (publicId != null && publicId.trim().isNotEmpty) {
        request.fields['public_id'] = publicId.trim();
      }

      final bytes = await file.readAsBytes();
      final filename = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'upload_${DateTime.now().millisecondsSinceEpoch}';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

      debugPrint('☁️ [Cloudinary] Début upload unsigned ($resourceType): $filename vers $cloudName (preset: $uploadPreset, folder: $folder)');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('☁️ [Cloudinary] Réponse HTTP ${response.statusCode}: ${response.body}');

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (_) {
        responseData = null;
      }

      if (response.statusCode >= 200 && response.statusCode < 300 && responseData is Map) {
        final secureUrl = responseData['secure_url']?.toString();
        if (secureUrl != null && secureUrl.isNotEmpty) {
          final duration = responseData['duration'];
          if (duration is num && duration > 0) {
            final durationDouble = duration.toDouble();
            _durationCache[secureUrl] = durationDouble;
            debugPrint('✅ [Cloudinary] Durée enregistrée dans le cache direct: ${durationDouble}s');
          }
          debugPrint('✅ [Cloudinary] Upload réussi avec succès: $secureUrl');
          return secureUrl;
        }
      }

      String errorMsg = 'Échec de l\'upload Cloudinary (HTTP ${response.statusCode})';
      if (responseData is Map) {
        final errorObj = responseData['error'];
        if (errorObj is Map && errorObj['message'] != null) {
          errorMsg = errorObj['message'].toString();
        } else if (errorObj is String) {
          errorMsg = errorObj;
        } else if (responseData['message'] != null) {
          errorMsg = responseData['message'].toString();
        }
      } else if (response.body.isNotEmpty) {
        errorMsg = response.body;
      }

      debugPrint('❌ [Cloudinary] Erreur API Cloudinary: $errorMsg');
      throw Exception(errorMsg);
    } catch (e) {
      debugPrint('❌ [Cloudinary] Exception lors de l\'upload: $e');
      throw Exception('Erreur Cloudinary upload ($resourceType): $e');
    }
  }
}

/// Provider Riverpod global pour CloudinaryService
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});
