import 'package:eveilkid/core/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppThemeModeSheet extends ConsumerWidget {
  const AppThemeModeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AppThemeModeSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              title: Text(
                'Apparence',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              subtitle: Text(
                'Choisissez le thème de l’application',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
            ),
            for (final option in [
              (ThemeMode.system, 'Système (automatique)', Icons.brightness_auto_outlined),
              (ThemeMode.light, 'Thème Clair', Icons.light_mode_outlined),
              (ThemeMode.dark, 'Thème Sombre', Icons.dark_mode_outlined),
            ])
              RadioListTile<ThemeMode>(
                value: option.$1,
                groupValue: selectedMode,
                activeColor: theme.colorScheme.primary,
                title: Text(
                  option.$2,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                secondary: Icon(option.$3, color: theme.colorScheme.primary),
                onChanged: (mode) {
                  if (mode == null) return;
                  ref.read(themeModeProvider.notifier).setThemeMode(mode);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
