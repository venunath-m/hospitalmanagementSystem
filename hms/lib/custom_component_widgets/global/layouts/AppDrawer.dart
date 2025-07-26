import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _canAccessReports = false;

  @override
  void initState() {
    super.initState();
    _checkUserPermissions();
  }

  Future<void> _checkUserPermissions() async {
    // Your permission logic here
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _canAccessReports = true;
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
            ListTile(
              leading: Icon(Icons.dashboard, color: contentColor),
              title: Text("Dashboard", style: TextStyle(color: contentColor)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Dashboard
              },
            ),
            if (_canAccessReports)
              ListTile(
                leading: Icon(Icons.analytics, color: contentColor),
                title: Text("Reports", style: TextStyle(color: contentColor)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to Reports
                },
              ),
            ListTile(
              leading: Icon(Icons.receipt_long, color: contentColor),
              title: Text(
                "Transactions",
                style: TextStyle(color: contentColor),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Transactions
              },
            ),
          ],
        ),
      ),
    );
  }
}
