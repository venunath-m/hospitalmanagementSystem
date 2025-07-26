import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart'; // Import your FirestoreService

class SupplierledgercollectionService {
  final FirestoreService _firestoreService =
      FirestoreService(); // FirestoreService instance
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  // Method to get supplier ledger entries from Firestore
  Future<List<Map<String, dynamic>>> getSupplierLedgerEntries() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception('Company ID not found in SharedPreferences.');
      }

      final supplierLedgerCollection = await _firestoreService.firestoreInstance
          .then((firestore) => firestore.collection('supplier_ledger'));

      final querySnapshot =
          await supplierLedgerCollection
              .where('companyId', isEqualTo: companyId) // Filter by companyId
              .orderBy('date', descending: true)
              .get();

      List<Map<String, dynamic>> ledgerEntries = [];

      for (var doc in querySnapshot.docs) {
        ledgerEntries.add({'id': doc.id, ...doc.data()});
      }

      return ledgerEntries;
    } catch (e) {
      debugPrint("Error fetching Supplier ledger entries: $e");
      throw Exception("Failed to fetch Supplier ledger entries: $e");
    }
  }

  // Method to add a supplier ledger entry
  Future<String> addSupplierLedgerEntry(Map<String, dynamic> ledgerData) async {
    try {
      final logsCollection = _firestoreService.logsCollection;
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception('Company ID not found in SharedPreferences.');
      }

      // Add the companyId to the ledger data
      ledgerData['companyId'] = companyId;

      final supplierLedgerCollection = await _firestoreService.firestoreInstance
          .then((firestore) => firestore.collection('supplier_ledger'));

      // Add a new ledger entry to the supplier_ledger collection
      final docRef = await supplierLedgerCollection.add(ledgerData);
      await logsCollection.add({
        'itemId': docRef.id,
        'oldData': null,
        'newData': {...ledgerData, 'id': docRef.id},
        'action': 'CREATE',
        'actionType': 'Supplier Ledger Entry',
        'createdBy': user.uid,
        'updatedBy': user.uid,
        'updatedByEmail': user.email,
        'companyId': companyId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id; // Return Firestore document ID
    } catch (e) {
      debugPrint("Error adding supplier ledger entry: $e");
      throw Exception("Failed to add supplier ledger entry: $e");
    }
  }

  // Method to get the supplier ledger by supplierId
  Future<List<Map<String, dynamic>>> getSupplierLedger(int supplierId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception('Company ID not found in SharedPreferences.');
      }

      final supplierLedgerCollection = await _firestoreService.firestoreInstance
          .then((firestore) => firestore.collection('supplier_ledger'));

      final querySnapshot =
          await supplierLedgerCollection
              .where('supplierId', isEqualTo: supplierId)
              .get();

      List<Map<String, dynamic>> ledgerEntries = [];

      for (var doc in querySnapshot.docs) {
        // Check if the supplier's companyId matches the one in SharedPreferences
        if (doc.data()?['companyId'] == companyId) {
          ledgerEntries.add({
            'id': doc.id, // Firestore document ID
            ...doc.data() as Map<String, dynamic>,
          });
        }
      }

      return ledgerEntries;
    } catch (e) {
      debugPrint("Error fetching supplier ledger entries: $e");
      throw Exception("Failed to fetch supplier ledger entries: $e");
    }
  }
}
