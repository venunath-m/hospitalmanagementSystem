import 'package:flutter/material.dart';
import 'package:hms/constants/features_toggle.dart';
import 'package:provider/provider.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _canAccessReports = false;
  List<String> _userFeatures = [];
  @override
  void initState() {
    super.initState();
    _checkUserPermissions();
  }

  Future<void> _checkUserPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userlevel') ?? 'Guest';
    final featureMap = await FeatureToggles.getFeaturesForUser(role);

    setState(() {
      _userFeatures = featureMap.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = context.watch<ThemeProvider>().isDarkBackground;
    final bgImage = themeProvider.selectedBackground;
    final theme = Theme.of(context);
    // Text and icon colors adapt to theme
    final contentColor = theme.textTheme.titleLarge?.color ?? Colors.black87;

    return Drawer(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      child: Container(
        // If you want background image behind drawer content:
        decoration: bgImage != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(bgImage),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(isDark ? 0.6 : 0.2),
                    BlendMode.darken,
                  ),
                ),
              )
            : null,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                // Use a solid color with opacity or a translucent overlay
                color: isDark
                    ? Colors.black.withOpacity(0.8)
                    : theme.colorScheme.surface.withOpacity(0.8),
              ),
              child: Row(
                children: [
                  // Add a background circle or container behind avatar if you want
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.grey[800] : Colors.white70,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage('assets/burjLogo.png'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Menu",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: contentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<Widget>>(
              future: buildDrawerOptions(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return ListTile(title: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const ListTile(title: Text('No features available'));
                } else {
                  return Column(children: snapshot.data!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
