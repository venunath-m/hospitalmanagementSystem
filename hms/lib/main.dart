import 'package:hms/app.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/fireStore_service/database_service.dart';
import 'package:hms/fireStore_service/session_manager.dart';
import 'package:hms/firebase_config.dart';
import 'package:hms/views/pages/companyView/company_registrationPage.dart';
import 'package:hms/views/pages/dashboardView/dashboard_page.dart';
import 'package:hms/views/pages/userView/login_page.dart'; // Adjust import if needed
import 'package:hms/views/pages/userView/user_registration_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'en_US';

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize ThemeProvider
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  // Check if user is logged in
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('companyId')) {
    await prefs.setString('companyId', '1');
  }
  const useEmulators = true;

  if (FirebaseConfig.useEmulators) {
    FirebaseFirestore.instance.useFirestoreEmulator(
      FirebaseConfig.emulatorHost,
      FirebaseConfig.firestorePort,
    );
    FirebaseAuth.instance.useAuthEmulator(
      FirebaseConfig.emulatorHost,
      FirebaseConfig.authPort,
    );
    FirebaseStorage.instance.useStorageEmulator(
      FirebaseConfig.emulatorHost,
      FirebaseConfig.storagePort,
    );
  }
  final isLoggedIn = prefs.containsKey('loggedInUsername');
  await FirestoreService().initializeDefaults();
  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}
