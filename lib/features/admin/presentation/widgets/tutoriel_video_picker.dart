import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';

class TutorielVideoPicker extends StatelessWidget {
  final File? selectedVideo;
  final String? videoUrl;
  final Function(File) onVideoSelected;
  final VoidCallback onVideoRemoved;
  final String? errorText;

  const TutorielVideoPicker({
    super.key,
    this.selectedVideo,
    this.videoUrl,
    required this.onVideoSelected,
    required this.onVideoRemoved,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasFile = selectedVideo != null;
    final hasUrl = videoUrl != null && videoUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _pickVideo(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasFile || hasUrl
                  ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.06)
                  : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50),
              border: Border.all(
                color: errorText != null
                    ? AppColors.danger
                    : (hasFile || hasUrl
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : (isDark ? Colors.white24 : Colors.grey.shade300)),
                width: errorText != null ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: hasFile
                ? _buildSelectedFileView(context)
                : (hasUrl ? _buildExistingUrlView(context) : _buildPlaceholder(context)),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.danger,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedFileView(BuildContext context) {
    final file = selectedVideo!;
    final fileSizeMb = (file.lengthSync() / (1024 * 1024)).toStringAsFixed(2);
    final fileName = file.path.split('/').last;

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.video_file_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Prêt à téléverser',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$fileSizeMb Mo',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onVideoRemoved,
          icon: const Icon(Icons.close_rounded, color: AppColors.danger),
          tooltip: 'Retirer la vidéo',
        ),
      ],
    );
  }

  Widget _buildExistingUrlView(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vidéo hébergée',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                videoUrl!,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onVideoRemoved,
          icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
          tooltip: 'Changer la vidéo',
        ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.video_library_rounded,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Choisir un fichier vidéo depuis la galerie',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'MP4, MOV, MKV ou WebM (sera hébergé sur Cloudinary)',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickVideo(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 30),
      );
      if (pickedFile != null) {
        onVideoSelected(File(pickedFile.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection vidéo: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}
