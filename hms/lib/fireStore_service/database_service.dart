import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class FirestoreService {
  // Singleton pattern
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Public getter to access Firestore instance
  FirebaseFirestore get firestore => _firestore;

  // Collection references using _firestore
  CollectionReference get hsnCodesCollection =>
      _firestore.collection('HsnCodes');
  CollectionReference get freightMasterCollection =>
      _firestore.collection('Freights');
  CollectionReference get freightReportCollection =>
      _firestore.collection('Freights_Report');
  CollectionReference get DeliveryBoyStockOnHandCollection =>
      _firestore.collection('deliveryBoy_StockOnHand');
  CollectionReference get DeliveryBoyReturnedStockOnHandCollection =>
      _firestore.collection('deliveryBoy_ReturnedStock');
  CollectionReference get DeliverysalesSummaryCollection =>
      _firestore.collection('delivery_sales_summary');
  CollectionReference get DeliverysalesDetailsCollection =>
      _firestore.collection('delivery_sales_details');
  CollectionReference get companiesCollection =>
      _firestore.collection('companies');
  CollectionReference get areasCollection => _firestore.collection('areas');
  CollectionReference get deliveryBoyCollection =>
      _firestore.collection('DeliveryBoy');
  CollectionReference get deliveryLoadingSummaryCollection =>
      _firestore.collection('delivery_loading_summary');
  CollectionReference get deliveryLoadingDetailsCollection =>
      _firestore.collection('delivery_loading_details');
  CollectionReference get salesReturnCollection =>
      _firestore.collection('sales_return');
  CollectionReference get salesReturnDetailsCollection =>
      _firestore.collection('sales_return_details');
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get customersCollection =>
      _firestore.collection('customers');
  CollectionReference get customerLedgerCollection =>
      _firestore.collection('customer_ledger');
  CollectionReference get itemsCollection => _firestore.collection('items');
  CollectionReference get logsCollection =>
      _firestore.collection('itemUpdateLogs');
  CollectionReference get purchaseSummaryCollection =>
      _firestore.collection('purchase_summary');
  CollectionReference get purchaseDetailsCollection =>
      _firestore.collection('purchase_details');
  CollectionReference get salesSummaryCollection =>
      _firestore.collection('sales_summary');
  CollectionReference get salesDetailsCollection =>
      _firestore.collection('sales_details');
  CollectionReference get accountBookCollection =>
      _firestore.collection('account_book');
  CollectionReference get subCategoriesCollection =>
      _firestore.collection('subCategories');
  CollectionReference get categoryCollection =>
      _firestore.collection('categories');
  CollectionReference get accountHeadCollection =>
      _firestore.collection('account_heads');
  CollectionReference get accountGroupCollection =>
      _firestore.collection('account_groups');
  CollectionReference get suppliersCollection =>
      _firestore.collection('suppliers');
  CollectionReference get supplierLedgerCollection =>
      _firestore.collection('supplier_ledger');
  CollectionReference get chatordersCollection =>
      _firestore.collection('chatOrders');
  CollectionReference get chatmessagesCollection =>
      _firestore.collection('messages');
  // Hash password
  String hashPassword(String password) {
    password = password.trim(); // Trim spaces to ensure consistency
    String salt = "SomeStaticSaltValue"; // Static salt (ensure consistency)
    String saltedPassword = password + salt; // Combine password with salt

    // Encode the salted password to bytes
    final bytes = utf8.encode(saltedPassword);

    // Hash the password using SHA-256
    final digest = sha256.convert(bytes);

    debugPrint('Hashed Password: ${digest.toString()}');
    return digest.toString();
  }

  // Ensure Firebase is initialized (call early in main)
  Future<void> initializeFirestore() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }

  // Optionally initialize default documents (e.g., for development or setup)
  Future<void> initializeDefaults() async {
    try {
      final usersSnapshot = await usersCollection.limit(1).get();
      if (usersSnapshot.docs.isEmpty) {
        final defaultPassword = 'password@123456@arianaGrande';
        final hashedPassword = hashPassword(
          defaultPassword,
        ); // Hash the password

        final defaultUsers = [
          {
            'companyId': 1,
            'username': 'sparrow',
            'email': 'venunathm30@gmail.com',
            'password': hashedPassword, // Use hash
            'userlevel': 'DevelopAdmin',
          },
          {
            'companyId': 1,
            'username': 'sparrowAdmin',
            'email': 'venunathm30@gmail.com',
            'password': hashedPassword,
            'userlevel': 'SuperAdmin',
          },
          {
            'companyId': 1,
            'username': 'sparrowStaff',
            'email': 'venunathm30@gmail.com',
            'password': hashedPassword,
            'userlevel': 'SaleStaff',
          },
        ];

        for (final user in defaultUsers) {
          await usersCollection.add(user);
        }

        debugPrint('Default users added with hashed passwords.');
      }

      final companiesSnapshot = await companiesCollection.limit(1).get();
      if (companiesSnapshot.docs.isEmpty) {
        final defaultCompany = {
          'companyname': 'Default Company',
          'phone': '123-456-7890',
          'email': 'contact@company.com',
          'createdAt': FieldValue.serverTimestamp(),
        };

        final companyDoc = await companiesCollection.add(defaultCompany);
        debugPrint('Default company created with ID: ${companyDoc.id}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing default Firestore data: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// This can be used anywhere to safely get the instance and ensure data setup
  Future<FirebaseFirestore> get firestoreInstance async {
    await initializeFirestore();
    await initializeDefaults();
    return _firestore;
  }
}
