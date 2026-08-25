import 'package:flutter/material.dart';

class AppDatePicker extends StatelessWidget {
  final String? label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String hintText;

  const AppDatePicker({
    super.key,
    this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.hintText = 'Sélectionner une date',
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = selectedDate != null
        ? '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.titleSmall?.color ?? theme.colorScheme.onSurface,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 6),
        ],
        InkWell(
          onTap: () => _pickDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: theme.iconTheme.color?.withValues(alpha: 0.6) ??
                      theme.colorScheme.onSurfaceVariant,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    formattedDate ?? hintText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: formattedDate != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: formattedDate != null
                          ? (theme.textTheme.bodyMedium?.color ??
                              theme.colorScheme.onSurface)
                          : theme.hintColor,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.iconTheme.color?.withValues(alpha: 0.6) ??
                      theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
