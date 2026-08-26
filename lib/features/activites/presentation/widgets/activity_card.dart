import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/ActivityCategorie/providers/activity_category_provider.dart';
import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../enums/publication_status.enum.dart';

class ActivityCard extends ConsumerWidget {
  final Activite activity;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPublish;
  final VoidCallback onUnpublish;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onPublish,
    required this.onUnpublish,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesMapAsync = ref.watch(categoriesMapProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          
          border: Border.all(color: const Color.fromARGB(255, 211, 210, 210)),
        ),
        child: Row(
          children: [
           
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: Container(
                width: 80,
                height: 80,
                color: AppColors.primary.withValues(alpha: 0.1),
                child: activity.imageUrl != null && activity.imageUrl!.isNotEmpty
                    ? Image.network(
                        activity.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      )
                    : _buildPlaceholder(),
              ),
            ),

            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                  
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                       
                          Text(
                            activity.titre,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                         
                          categoriesMapAsync.when(
                            loading: () => const SizedBox(
                              height: 16,
                              width: 60,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 8,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1,
                                  ),
                                ),
                              ),
                            ),
                            error: (_, __) => Text(
                              '⚠️ Erreur',
                              style: TextStyle(
                                color: AppColors.danger,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            data: (categoriesMap) {
                              final categoryName = _getCategoryName(
                                activity.categorieId,
                                categoriesMap,
                              );
                              return Row(
                                children: [
                                 
                                  Text(
                                    categoryName,
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 104, 102, 102),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(width: 6),
                                
                                  Container(
                                    width: 3,
                                    height: 3,
                                    decoration:  BoxDecoration(
                                      color: Color.fromARGB(255, 209, 204, 204),
                                      shape: BoxShape.circle,
                                     
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  
                                  Text(
                                    'De ${activity.ageMinimum} à ${activity.ageMaximum} ans',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 104, 102, 102),
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            activity.statut.label,
                            style: TextStyle(
                              color: _getStatusColor(activity.statut),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  onEdit();
                                  break;
                                case 'publish':
                                  onPublish();
                                  break;
                                case 'unpublish':
                                  onUnpublish();
                                  break;
                                case 'delete':
                                  onDelete();
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18, color: AppColors.primary),
                                    SizedBox(width: 8),
                                    Text('Modifier'),
                                  ],
                                ),
                              ),
                              if (activity.statut == PublicationStatus.brouillon)
                                const PopupMenuItem(
                                  value: 'publish',
                                  child: Row(
                                    children: [
                                      Icon(Icons.publish, size: 18, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text('Publier'),
                                    ],
                                  ),
                                ),
                              if (activity.statut == PublicationStatus.publie)
                                const PopupMenuItem(
                                  value: 'unpublish',
                                  child: Row(
                                    children: [
                                      Icon(Icons.unpublished, size: 18, color: Colors.orange),
                                      SizedBox(width: 8),
                                      Text('Dépublier'),
                                    ],
                                  ),
                                ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 18, color: AppColors.danger),
                                    SizedBox(width: 8),
                                    Text(
                                      'Supprimer',
                                      style: TextStyle(color: AppColors.danger),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          color: AppColors.primary.withOpacity(0.4),
          size: 30,
        ),
      ),
    );
  }

  Color _getStatusColor(PublicationStatus status) {
    switch (status) {
      case PublicationStatus.publie:
        return Colors.green;
      case PublicationStatus.brouillon:
        return Colors.orange;
      case PublicationStatus.archive:
        return AppColors.danger;
    }
  }

  String _getCategoryName(String categoryId, Map<String, String> categoriesMap) {
    return categoriesMap[categoryId] ?? 'Non catégorisé';
  }
}