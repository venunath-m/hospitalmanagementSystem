import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hms/fireStore_service/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesReturnDetailCollectionService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  // Method to add sales return details to Firestore
  Future<String> addSalesReturnDetail(
    Map<String, dynamic> returnDetailData,
  ) async {
    try {
      final logsCollection = _firestoreService.logsCollection;
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      // Add the companyId to the sales return data
      returnDetailData['companyId'] = companyId;

      final docRef = await db
          .collection('sales_return_details')
          .add(returnDetailData);
      await logsCollection.add({
        'itemId': docRef.id,
        'oldData': null,
        'newData': {...returnDetailData, 'id': docRef.id},
        'action': 'CREATE',
        'actionType': 'Sales Return Detail',
        'createdBy': user.uid,
        'updatedBy': user.uid,
        'updatedByEmail': user.email,
        'companyId': companyId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print("Error adding sales return detail: $e");
      throw Exception("Failed to add sales return detail: $e");
    }
  }

  // Method to get return details by return summary ID
  Future<List<Map<String, dynamic>>> getSalesReturnDetailsBySummaryId(
    int returnId,
  ) async {
    List<Map<String, dynamic>> returnDetails = [];

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      final querySnapshot = await db
          .collection('sales_return_details')
          .where('returnId', isEqualTo: returnId)
          .where('companyId', isEqualTo: companyId)
          .get();

      for (var doc in querySnapshot.docs) {
        returnDetails.add({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
    } catch (e) {
      print("Error fetching sales return details: $e");
      throw Exception("Failed to fetch sales return details: $e");
    }

    return returnDetails;
  }

  // Method to get all return details
  Future<List<Map<String, dynamic>>> getAllSalesReturnDetails() async {
    List<Map<String, dynamic>> allReturnDetails = [];

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      final querySnapshot = await db
          .collection('sales_return_details')
          .where('companyId', isEqualTo: companyId)
          .get();

      for (var doc in querySnapshot.docs) {
        allReturnDetails.add({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
    } catch (e) {
      print("Error fetching all sales return details: $e");
      throw Exception("Failed to fetch all sales return details: $e");
    }

    return allReturnDetails;
  }
}
