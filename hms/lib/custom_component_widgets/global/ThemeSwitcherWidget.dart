import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class ThemeSwitcherWidget extends StatelessWidget {
  const ThemeSwitcherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DropdownButton<AppThemeMode>(
      value: themeProvider.themeMode,
      onChanged: (mode) {
        if (mode != null) {
          themeProvider.setTheme(mode);
        }
      },
      underline: const SizedBox(), // remove the default underline
      icon: const Icon(Icons.color_lens), // dropdown arrow icon
      items: [
        DropdownMenuItem(
          value: AppThemeMode.system,
          child: Tooltip(
            message: 'System Default',
            child: Row(
              children: const [
                Icon(Icons.settings),
                SizedBox(width: 8),
                Text('System'),
              ],
            ),
          ),
        ),
        DropdownMenuItem(
          value: AppThemeMode.light,
          child: Tooltip(
            message: 'Light Theme',
            child: Row(
              children: const [
                Icon(Icons.light_mode),
                SizedBox(width: 8),
                Text('Light'),
              ],
            ),
          ),
        ),
        DropdownMenuItem(
          value: AppThemeMode.dark,
          child: Tooltip(
            message: 'Dark Theme',
            child: Row(
              children: const [
                Icon(Icons.dark_mode),
                SizedBox(width: 8),
                Text('Dark'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
