// lib/firebase_config.dart

class FirebaseConfig {
  /// Set this to true to connect to local Firebase Emulators
  /// Set to false to connect to real Firebase services (production)
  static const bool useEmulators = bool.fromEnvironment(
    'USE_FIREBASE_EMULATORS',
    defaultValue: false,
  );

  // Emulator host and ports
  static const String emulatorHost = 'localhost';
  static const int firestorePort = 8080;
  static const int authPort = 9099;
  static const int storagePort = 9199;
}
