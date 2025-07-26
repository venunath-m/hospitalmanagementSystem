import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart'; // Import your FirestoreService

class HsncodesService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  // Method to update a supplier's information
  Future<bool> updateHsnCode(
    String hsnCodeId,
    Map<String, dynamic> updatedHsnCodeData,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Get companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception('Company ID not found in SharedPreferences.');
      }

      final hsnCodecollectionService = await _firestoreService.firestoreInstance
          .then((firestore) => firestore.collection('HsnCodes'));

      // Fetch supplier document
      final hsnCodeDoc = await hsnCodecollectionService.doc(hsnCodeId).get();

      // Verify companyId matches
      if (hsnCodeDoc.exists && hsnCodeDoc.data()?['companyId'] == companyId) {
        await hsnCodecollectionService
            .doc(hsnCodeId)
            .update(updatedHsnCodeData); // Perform update
        return true;
      }
    } catch (e) {
      debugPrint('Error updating hsnCode: $e');
    }

    return false; // Return false on failure
  }

  // Method to fetch a supplier by their name
  Future<Map<String, dynamic>?> gethsnCodeByName(String hsnCode) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Get companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception('Company ID not found in SharedPreferences.');
      }

      // Access Firestore collection
      final hsnCodeCollectionService = await _firestoreService.firestoreInstance
          .then((firestore) => firestore.collection('HsnCodes'));

      // Query by name and companyId
      final querySnapshot =
          await hsnCodeCollectionService
              .where('hsnCode', isEqualTo: hsnCode)
              .where('companyId', isEqualTo: companyId)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final docData = doc.data();
        if (docData != null && docData is Map<String, dynamic>) {
          return {'id': doc.id, ...docData};
        }
      }
    } catch (e) {
      debugPrint('Error fetching hsnCode: $e');
    }

    return null;
  }

  // Method to add a new supplier to Firestore
  Future<String> addHsnCode(Map<String, dynamic> hsnCodeData) async {
    final db = FirebaseFirestore.instance;

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Retrieve the current companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      // Add companyId to the supplier data
      hsnCodeData['companyId'] = companyId;

      // Add the supplier data to Firestore
      final docRef = await db.collection('HsnCodes').add(hsnCodeData);

      return docRef.id;
    } catch (e) {
      print("Error adding HsnCode: $e");
      throw Exception("Failed to add HsnCode: $e");
    }
  }

  Future<String> addHsnCodeIfNotExists(Map<String, dynamic> hsnCodeData) async {
    final db = FirebaseFirestore.instance;

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Retrieve the current companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      // Ensure hsnCode field is present
      final hsnCode = hsnCodeData['hsnCode'];
      if (hsnCode == null || hsnCode.toString().isEmpty) {
        throw Exception("HSN Code is required.");
      }

      // Check if HSN Code already exists in the collection for this company
      final existing =
          await db
              .collection('HsnCodes')
              .where('hsnCode', isEqualTo: hsnCode)
              .where('companyId', isEqualTo: companyId)
              .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id; // Already exists, return the ID
      }

      // Add companyId to the data
      hsnCodeData['companyId'] = companyId;

      // Add the new HSN Code
      final docRef = await db.collection('HsnCodes').add(hsnCodeData);
      return docRef.id;
    } catch (e) {
      print("Error adding HSN Code: $e");
      throw Exception("Failed to add HSN Code: $e");
    }
  }

  // Method to get all suppliers from Firestore
  Future<List<Map<String, dynamic>>> getAllHsnCode() async {
    final db = FirebaseFirestore.instance;

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Get current companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      // Fetch all suppliers belonging to this companyId
      final snapshot =
          await db
              .collection('HsnCodes')
              .where('companyId', isEqualTo: companyId)
              .get();

      // Convert each document to a map
      final hsnCodes =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'hsnCodeId': doc.id,
              'hsnCode': data['hsnCode'] ?? 'N/A',
              'cgst': data['cgst'] ?? 'N/A',
              'sgst': data['sgst'] ?? 'N/A',
              'igst': data['igst'] ?? 'N/A',
            };
          }).toList();

      return hsnCodes;
    } catch (e) {
      print("Error fetching hsnCodes: $e");
      throw Exception("Failed to fetch hsnCodes: $e");
    }
  }

  // Method to get all suppliers from Firestore with their ID
  Future<List<Map<String, dynamic>>> getAllHsncodesWithId() async {
    final db = FirebaseFirestore.instance;

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Get current companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      // Fetch all suppliers belonging to this companyId
      final snapshot =
          await db
              .collection('HsnCodes')
              .where('companyId', isEqualTo: companyId)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'hsnCodeId': doc.id,
          'hsnCode': data['hsnCode'] ?? 'N/A',
          'cgst': data['cgst'] ?? 'N/A',
          'sgst': data['sgst'] ?? 'N/A',
          'igst': data['igst'] ?? 'N/A',
          // Add other fields if needed
        };
      }).toList();
    } catch (e) {
      print("Error fetching hsnCodes: $e");
      throw Exception("Failed to fetch hsnCodes: $e");
    }
  }

  Future<List<Map<String, dynamic>>> searchHSNCodes(String query) async {
    final db = FirebaseFirestore.instance;
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    // ✅ Await the result of the get() call
    final snapshot =
        await db
            .collection('HsnCodes')
            .where('hsnCode', isGreaterThanOrEqualTo: query)
            .where('hsnCode', isLessThanOrEqualTo: query + '\uf8ff')
            .limit(10)
            .get();

    return snapshot.docs
        .map((doc) => {'hsnCodeId': doc.id, ...doc.data()})
        .toList();
  }

  // Method to delete a supplier by ID
  Future<void> deleteHsnCode(String hsnCodeId) async {
    final db = FirebaseFirestore.instance;

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Get current companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      final docRef = db.collection('HsnCodes').doc(hsnCodeId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw Exception("HsnCode not found.");
      }

      final data = docSnapshot.data() as Map<String, dynamic>;

      if (data['companyId'] != companyId) {
        throw Exception("You are not authorized to delete this HsnCode.");
      }

      await docRef.delete();
      print("hsnCode with ID $hsnCodeId deleted successfully.");
    } catch (e) {
      print("Error deleting HsnCode: $e");
      throw Exception("Failed to delete HsnCode: $e");
    }
  }
}
