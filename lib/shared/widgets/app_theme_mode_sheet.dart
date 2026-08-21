import 'package:eveilkid/core/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppThemeModeSheet extends ConsumerWidget {
  const AppThemeModeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => const AppThemeModeSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(themeModeProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Apparence'),
            subtitle: Text('Choisissez le thème de l’application'),
          ),
          for (final option in [
            (ThemeMode.system, 'Système', Icons.brightness_auto_outlined),
            (ThemeMode.light, 'Clair', Icons.light_mode_outlined),
            (ThemeMode.dark, 'Sombre', Icons.dark_mode_outlined),
          ])
            RadioListTile<ThemeMode>(
              value: option.$1,
              groupValue: selectedMode,
              title: Text(option.$2),
              secondary: Icon(option.$3),
              onChanged: (mode) {
                if (mode == null) return;
                ref.read(themeModeProvider.notifier).setThemeMode(mode);
                Navigator.pop(context);
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
