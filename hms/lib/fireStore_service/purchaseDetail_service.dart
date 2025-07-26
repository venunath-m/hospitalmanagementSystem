import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart'; // Import your FirestoreService

class PurchasedetailService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  // Check if there are any purchase details in the 'purchase_details' collection
  Future<bool> hasPurchaseDetails() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        debugPrint("Company ID not found in SharedPreferences.");
        return false;
      }

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('purchase_details')
              .where('companyId', isEqualTo: companyId)
              .limit(1) // Efficient: stop once at least 1 record is found
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint("Error checking purchase details: $e");
      return false;
    }
  }

  // Fetch all purchase details from Firestore
  Future<List<Map<String, dynamic>>> fetchAllPurchaseDetails() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        debugPrint("Company ID not found in SharedPreferences.");
        return [];
      }

      final db = FirebaseFirestore.instance;

      // Fetch documents where companyId matches
      final snapshot =
          await db
              .collection('purchase_details')
              .where('companyId', isEqualTo: companyId)
              .get();

      // Map the documents to a list of maps (including document ID)
      final details =
          snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();

      return details;
    } catch (e) {
      debugPrint("Error fetching purchase details: $e");
      return [];
    }
  }

  // Add a new purchase detail to Firestore
  Future<String> addPurchaseDetail(
    Map<String, dynamic> purchaseDetailData,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      final db = FirebaseFirestore.instance;
      final logsCollection = _firestoreService.logsCollection;
      // Add companyId to the purchase detail data
      purchaseDetailData['companyId'] = companyId;

      // Print the data being added (for debugging)
      debugPrint("Adding Purchase Detail: $purchaseDetailData");

      // Add the purchase detail data to the 'purchase_details' collection
      final docRef = await db
          .collection('purchase_details')
          .add(purchaseDetailData);
      await logsCollection.add({
        'itemId': docRef.id,
        'oldData': null,
        'newData': {...purchaseDetailData, 'id': docRef.id},
        'action': 'CREATE',
        'actionType': 'Purchase Detail',
        'createdBy': user.uid,
        'updatedBy': user.uid,
        'updatedByEmail': user.email,
        'companyId': companyId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Return the document ID of the newly added purchase detail
      return docRef.id;
    } catch (e) {
      debugPrint("Error adding purchase detail: $e");
      throw Exception("Failed to add purchase detail: $e");
    }
  }

  // Get all purchase details from Firestore
  Future<List<Map<String, dynamic>>> getAllPurchaseDetails() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      final db = FirebaseFirestore.instance;

      // Fetch only documents that match the current companyId
      final snapshot =
          await db
              .collection('purchase_details')
              .where('companyId', isEqualTo: companyId)
              .get();

      // Convert each document snapshot to a map and return as a list
      final purchaseDetails =
          snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();

      return purchaseDetails;
    } catch (e) {
      debugPrint("Error fetching purchase details: $e");
      throw Exception("Failed to fetch purchase details: $e");
    }
  }

  // Get purchase details by purchase summary ID from Firestore
  Future<List<Map<String, dynamic>>> getPurchaseDetailsBySummaryId(
    String purchaseId,
  ) async {
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
              .collection('purchase_details')
              .where('purchaseID', isEqualTo: purchaseId)
              .where('companyId', isEqualTo: companyId)
              .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint("Error fetching purchase details: $e");
      throw Exception("Failed to fetch purchase details: $e");
    }
  }

  // Method to update a specific purchase detail by its document ID
  Future<bool> updatePurchaseDetail(
    String purchaseDetailId,
    Map<String, dynamic> updatedData,
  ) async {
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

      final docRef = db.collection('purchase_details').doc(purchaseDetailId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        debugPrint("Purchase detail not found: $purchaseDetailId");
        return false;
      }

      final data = docSnapshot.data();
      if (data == null || data['companyId'] != companyId) {
        debugPrint("Company ID mismatch or missing in purchase detail.");
        return false;
      }

      // Update the document
      await docRef.update(updatedData);
      return true;
    } catch (e) {
      debugPrint("Error updating purchase detail: $e");
      return false;
    }
  }

  // Method to delete a specific purchase detail by its document ID
  Future<bool> deletePurchaseDetail(String purchaseDetailId) async {
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

      // Get the document reference and fetch its data
      final docRef = db.collection('purchase_details').doc(purchaseDetailId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        debugPrint("Purchase detail with ID $purchaseDetailId does not exist.");
        return false;
      }

      final data = docSnapshot.data();
      if (data == null || data['companyId'] != companyId) {
        debugPrint("Company ID mismatch or missing in purchase detail.");
        return false;
      }

      // Perform the deletion
      await docRef.delete();
      return true;
    } catch (e) {
      debugPrint("Error deleting purchase detail: $e");
      return false;
    }
  }
}
