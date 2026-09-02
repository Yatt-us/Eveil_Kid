import 'package:flutter/material.dart';
import 'package:eveilkid/features/activites/enums/publication_status.enum.dart';

class ActivityStatusSelector extends StatelessWidget {
  final PublicationStatus selectedStatus;
  final Function(PublicationStatus) onChanged;

  const ActivityStatusSelector({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.3 : 0.15);

    final statuses = [
      {
        'status': PublicationStatus.publie,
        'label': 'Publiée',
        'icon': Icons.public_rounded,
        'color': const Color(0xFF16A34A),
      },
      {
        'status': PublicationStatus.brouillon,
        'label': 'Brouillon',
        'icon': Icons.edit_note_rounded,
        'color': const Color(0xFFD97706),
      },
      {
        'status': PublicationStatus.archive,
        'label': 'Archivée',
        'icon': Icons.archive_outlined,
        'color': const Color(0xFFDC2626),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : theme.colorScheme.surface,
        border: Border.all(color: dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: statuses.map((item) {
          final status = item['status'] as PublicationStatus;
          final isSelected = selectedStatus == status;
          final color = item['color'] as Color;

          return Expanded(
            child: Material(
              color: isSelected
                  ? (isDark ? color.withValues(alpha: 0.25) : color.withValues(alpha: 0.12))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                onTap: () => onChanged(status),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    border: isSelected
                        ? Border.all(color: color.withValues(alpha: 0.5), width: 1.2)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 16,
                        color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? color : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
