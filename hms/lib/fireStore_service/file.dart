import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  // Singleton pattern
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Public getter to access Firestore instance
  FirebaseFirestore get firestore => _firestore;

  // Collection references using _firestore
  CollectionReference get usersCollection => _firestore.collection('users');

  CollectionReference get accountBookCollection =>
      _firestore.collection('account_book');
  CollectionReference get accountHeadCollection =>
      _firestore.collection('account_heads');
  CollectionReference get accountGroupCollection =>
      _firestore.collection('account_groups');
  CollectionReference get suppliersCollection =>
      _firestore.collection('suppliers');
  CollectionReference get supplierLedgerCollection =>
      _firestore.collection('supplier_ledger');

  /// Ensure Firebase is initialized (call early in main)
  Future<void> initializeFirestore() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }

  /// Optionally initialize default documents (e.g., for development or setup)
  Future<void> _initializeDefaults() async {
    try {
      final usersSnapshot = await usersCollection
          .limit(1)
          .get(); // Limit improves performance

      if (usersSnapshot.docs.isEmpty) {
        final defaultUsers = [
          {
            'username': 'sparrow',
            'password': 'password@123456@',
            'userlevel': 'SuperAdmin',
          },
          {
            'username': 'sparrowStaff',
            'password': 'password@123456@',
            'userlevel': 'SaleStaff',
          },
        ];

        for (final user in defaultUsers) {
          await usersCollection.add(user);
        }

        debugPrint('Default users added.');
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing default Firestore data: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// This can be used anywhere to safely get the instance and ensure data setup
  Future<FirebaseFirestore> get firestoreInstance async {
    await initializeFirestore();
    await _initializeDefaults();
    return _firestore;
  }

  Future<Map<int, String>> getAccountHeadNamesMap() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('account_heads') // Firestore collection name
          .get();

      final Map<int, String> idToNameMap = {};

      for (var doc in querySnapshot.docs) {
        final id =
            int.tryParse(doc.id) ??
            -1; // Convert Firestore document ID to int (if possible)
        final name =
            doc.data()['headName'] as String? ??
            'Unknown'; // Get the 'headName' field, default to 'Unknown'
        idToNameMap[id] = name;
      }

      return idToNameMap;
    } catch (e) {
      debugPrint('Error getting account head names: $e');
      return {};
    }
  }
}
