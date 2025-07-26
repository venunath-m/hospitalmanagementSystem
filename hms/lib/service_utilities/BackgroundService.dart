import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../custom_component_widgets/shared_widgets.dart';

class BackgroundService {
  static String? selectedBackground;

  static Future<void> loadBackground() async {
    final prefs = await SharedPreferences.getInstance();
    selectedBackground =
        prefs.getString('selectedBackgroundImage') ??
        'assets/backgrounds/bg6.png';
  }

  static void updateThemeBasedOnBackground(BuildContext context) {
    final isDark = selectedBackground?.toLowerCase().contains('dark') ?? false;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.updateDarkBackground(isDark);
  }
}
