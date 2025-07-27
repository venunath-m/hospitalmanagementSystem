import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/fireStore_service/session_manager.dart';
import 'package:hms/service_utilities/app_routes.dart';
import 'package:hms/views/pages/dashboardView/dashboard_page.dart';
import 'package:hms/views/pages/userView/login_page.dart';
import 'package:hms/views/pages/userView/user_registration_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SessionManager sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    // Start tracking session inactivity
    sessionManager.startTracking(_handleSessionTimeout);
  }

  void _handleSessionTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUsername');
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  void dispose() {
    sessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => sessionManager.userActivityDetected(),
      child: MaterialApp(
        title: 'Hospital Management System',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeProvider.materialThemeMode,
        // Initial route based on login status
        initialRoute: widget.isLoggedIn ? '/dashboard' : '/login',
        routes: AppRoutes.routes,
      ),
    );
  }
}
