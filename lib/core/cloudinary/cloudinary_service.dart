import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:eveilkid/core/cloudinary/cloudinary_config.dart';

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

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

  /// Mécanisme d'upload REST Unsigned vers Cloudinary
  /// Ne nécessite aucune api_key ni api_secret car il utilise l'upload_preset unsigned
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

      // Paramètres unsigned indispensables
      request.fields['upload_preset'] = uploadPreset;

      if (folder != null && folder.trim().isNotEmpty) {
        request.fields['folder'] = folder.trim();
      }

      if (publicId != null && publicId.trim().isNotEmpty) {
        request.fields['public_id'] = publicId.trim();
      }

      // Lecture sécurisée des octets du fichier pour éviter tout problème de chemin/mime
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
          debugPrint('✅ [Cloudinary] Upload réussi avec succès: $secureUrl');
          return secureUrl;
        }
      }

      // Extraction robuste et sécurisée du message d'erreur
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
