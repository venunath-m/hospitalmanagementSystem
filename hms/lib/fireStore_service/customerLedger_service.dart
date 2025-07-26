import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart'; // Import your FirestoreService

class CustomerledgerService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  // Method to add customer ledger entry with userId
  Future<void> addCustomerLedgerEntry({
    required Map<String, dynamic> entry,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final db = FirebaseFirestore.instance; // Get Firestore instance
      final logsCollection = _firestoreService.logsCollection;
      // Retrieve the companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      // Add the userId and companyId to the entry
      entry['userId'] = user.uid;
      entry['companyId'] = companyId;

      // Add the entry to the 'customer_ledger' collection
      final docRef = await db.collection('customer_ledger').add(entry);
      await logsCollection.add({
        'itemId': docRef.id,
        'oldData': null,
        'newData': {...entry, 'id': docRef.id},
        'action': 'CREATE',
        'actionType': 'Customer Ledger Entry',
        'createdBy': user.uid,
        'updatedBy': user.uid,
        'updatedByEmail': user.email,
        'companyId': companyId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print("Customer ledger entry added successfully.");
    } catch (e) {
      print("Error adding customer ledger entry: $e");
    }
  }

  // Method to get customer ledger entries by customer ID and userId
  Future<List<Map<String, dynamic>>> getCustomerLedger({
    required String customerId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final db = FirebaseFirestore.instance; // Firestore instance
    List<Map<String, dynamic>> ledgerEntries = [];

    try {
      // Retrieve the companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      // Fetch the customer ledger entries filtered by customerId, userId, and companyId, and sorted by date descending
      final querySnapshot =
          await db
              .collection('customer_ledger')
              .where('customerId', isEqualTo: customerId)
              .where(
                'companyId',
                isEqualTo: companyId,
              ) // Filtering by companyId
              .orderBy(
                'date',
                descending: true,
              ) // Sorting by date in descending order
              .get();

      // Convert the query snapshot into a list of maps
      for (var doc in querySnapshot.docs) {
        ledgerEntries.add({
          'id': doc.id, // Document ID from Firestore
          ...doc.data() as Map<String, dynamic>,
        });
      }
    } catch (e) {
      print("Error fetching customer ledger entries: $e");
      throw Exception("Failed to fetch customer ledger entries: $e");
    }

    return ledgerEntries;
  }

  // Method to get all customer ledger entries filtered by userId
  Future<List<Map<String, dynamic>>> getCustomerLedgerEntries() async {
    final db = FirebaseFirestore.instance;
    List<Map<String, dynamic>> ledgerEntries = [];

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      final querySnapshot =
          await db
              .collection('customer_ledger')
              .where('companyId', isEqualTo: companyId)
              .orderBy('date', descending: true)
              .get();

      for (var doc in querySnapshot.docs) {
        ledgerEntries.add({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
    } catch (e, stack) {
      debugPrint("Error fetching customer ledger entries: $e");
      debugPrintStack(stackTrace: stack);
      throw Exception("Failed to fetch customer ledger entries: $e");
    }

    return ledgerEntries;
  }
}
