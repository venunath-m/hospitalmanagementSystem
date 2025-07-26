import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart'; // Import your FirestoreService

class PurchaseSummaryCollectionService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  // Method to add a purchase summary
  Future<String> addPurchaseSummary(Map<String, dynamic> purchaseData) async {
    try {
      final logsCollection = _firestoreService.logsCollection;
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final db = FirebaseFirestore.instance;

      // Get companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      // Add companyId to the purchaseData
      purchaseData['companyId'] = companyId;

      // Add purchase data to Firestore
      final docRef = await db.collection('purchase_summary').add(purchaseData);
      await logsCollection.add({
        'itemId': docRef.id,
        'oldData': null,
        'newData': {...purchaseData, 'id': docRef.id},
        'action': 'CREATE',
        'actionType': 'Purchase Summary',
        'createdBy': user.uid,
        'updatedBy': user.uid,
        'updatedByEmail': user.email,
        'companyId': companyId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print("Error adding purchase summary: $e");
      throw Exception("Error adding purchase summary");
    }
  }

  // Method to get all purchase summaries from Firestore
  Future<List<Map<String, dynamic>>> getAllPurchaseSummary() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final db = FirebaseFirestore.instance;

      // Get companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      // Fetch documents filtered by companyId
      final snapshot =
          await db
              .collection('purchase_summary')
              .where('companyId', isEqualTo: companyId)
              .get();
      // Map documents to a list of maps
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print("Error getting purchase summaries: $e");
      return [];
    }
  }

  // Method to get total payments from Firestore based on the 'purchasePayMode' being 'Cash'
  Future<double> getTotalPayments() async {
    final db = FirebaseFirestore.instance;
    double totalPaid = 0;

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Get companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      // Query purchase summaries filtered by companyId
      final querySnapshot =
          await db
              .collection('purchase_summary')
              .where('companyId', isEqualTo: companyId)
              .get();

      // Sum 'purchaseAmount' where 'purchasePayMode' is 'cash'
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final purchasePayMode =
            data['purchasePayMode']?.toString().toLowerCase();
        final purchaseAmount = data['purchaseAmount'] as double? ?? 0;

        if (purchasePayMode == 'cash') {
          totalPaid += purchaseAmount;
        }
      }
    } catch (e) {
      print("Error fetching total payments: $e");
      throw Exception("Failed to fetch total payments: $e");
    }

    return totalPaid;
  }

  // Method to fetch purchase summary ordered by 'date' (descending)
  Future<List<Map<String, dynamic>>> getPurchaseSummary() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null)
        throw Exception("Company ID not found in SharedPreferences.");

      final db = FirebaseFirestore.instance;

      final querySnapshot =
          await db
              .collection('purchase_summary')
              .where('companyId', isEqualTo: companyId)
              .orderBy('purchaseEnteredDate', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint("Error fetching purchase summary: $e");
      throw Exception("Failed to fetch purchase summary: $e");
    }
  }
}
