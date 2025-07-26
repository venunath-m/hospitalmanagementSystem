import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart'; // Import your FirestoreService

class SuppliercollectionService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  // Method to update supplier balance in Firestore
  Future<void> updateSupplierBalance(
    int supplierId,
    double balanceAmount,
  ) async {
    try {
      final logsCollection = _firestoreService.logsCollection;
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception('Company ID not found in SharedPreferences.');
      }

      final db = FirebaseFirestore.instance; // Firestore instance

      // Fetch the supplier document using the supplierId
      final supplierDoc =
          await db.collection('suppliers').doc(supplierId.toString()).get();

      if (supplierDoc.exists) {
        // Verify if the supplier's companyId matches the one in SharedPreferences
        if (supplierDoc.data()?['companyId'] == companyId) {
          // Get the current balance
          double currentBalance =
              supplierDoc.data()?['balance'] as double? ?? 0.0;

          // Calculate the new balance
          double newBalance = currentBalance + balanceAmount;

          // Update the supplier's balance
          await db.collection('suppliers').doc(supplierId.toString()).update({
            'balance': newBalance,
          });
          await logsCollection.add({
            'itemId': supplierId.toString(),
            'oldData': {'balance': currentBalance},
            'newData': {'balance': newBalance},
            'action': 'UPDATE',
            'actionType': 'Supplier Balance',
            'updatedBy': user.uid,
            'updatedByEmail': user.email,
            'companyId': companyId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print("Supplier balance updated successfully.");
        } else {
          print("Company ID mismatch. Supplier not found for this company.");
        }
      } else {
        print("Supplier not found.");
      }
    } catch (e) {
      debugPrint("Error updating supplier balance: $e");
    }
  }

  // Method to update a supplier's information
  Future<bool> updateSupplier(
    String supplierId,
    Map<String, dynamic> updatedSupplierData,
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

      final suppliersCollection = await _firestoreService.firestoreInstance
          .then((firestore) => firestore.collection('suppliers'));

      // Fetch supplier document
      final supplierDoc = await suppliersCollection.doc(supplierId).get();

      // Verify companyId matches
      if (supplierDoc.exists && supplierDoc.data()?['companyId'] == companyId) {
        await suppliersCollection
            .doc(supplierId)
            .update(updatedSupplierData); // Perform update
        return true;
      }
    } catch (e) {
      debugPrint('Error updating supplier: $e');
    }

    return false; // Return false on failure
  }

  // Method to fetch a supplier by their name
  Future<Map<String, dynamic>?> getSupplierByName(String name) async {
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
      final suppliersCollection = await _firestoreService.firestoreInstance
          .then((firestore) => firestore.collection('suppliers'));

      // Query by name and companyId
      final querySnapshot =
          await suppliersCollection
              .where('name', isEqualTo: name)
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
      debugPrint('Error fetching supplier: $e');
    }

    return null;
  }

  // Method to add a new supplier to Firestore
  Future<String> addSupplier(Map<String, dynamic> supplierData) async {
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
      supplierData['companyId'] = companyId;

      // Add the supplier data to Firestore
      final docRef = await db.collection('suppliers').add(supplierData);

      return docRef.id;
    } catch (e) {
      print("Error adding supplier: $e");
      throw Exception("Failed to add supplier: $e");
    }
  }

  // Method to get all suppliers from Firestore
  Future<List<Map<String, dynamic>>> getAllSuppliers() async {
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
              .collection('suppliers')
              .where('companyId', isEqualTo: companyId)
              .get();

      // Convert each document to a map
      final suppliers =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'] ?? 'N/A',
              'phone': data['phone'] ?? 'N/A',
              'address': data['address'] ?? 'N/A',
              'email': data['email'] ?? 0.0,
              'balance': data['balance'] ?? 0.0,
              'gstin': data['gstin'] ?? 'N/A',
            };
          }).toList();

      return suppliers;
    } catch (e) {
      print("Error fetching suppliers: $e");
      throw Exception("Failed to fetch suppliers: $e");
    }
  }

  // Method to get all suppliers from Firestore with their ID
  Future<List<Map<String, dynamic>>> getAllSuppliersWithId() async {
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
              .collection('suppliers')
              .where('companyId', isEqualTo: companyId)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'supplierId': doc.id,
          'name': data['name'] ?? 'N/A',
          'phone': data['phone'] ?? 'N/A',
          'address': data['address'] ?? 'N/A',
          'balance': data['balance'] ?? 0.0,
          'gstin': data['gstin'] ?? 'N/A',
          // Add other fields if needed
        };
      }).toList();
    } catch (e) {
      print("Error fetching suppliers: $e");
      throw Exception("Failed to fetch suppliers: $e");
    }
  }

  // Method to delete a supplier by ID
  Future<void> deleteSupplier(String supplierId) async {
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

      final docRef = db.collection('suppliers').doc(supplierId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw Exception("Supplier not found.");
      }

      final data = docSnapshot.data() as Map<String, dynamic>;

      if (data['companyId'] != companyId) {
        throw Exception("You are not authorized to delete this supplier.");
      }

      await docRef.delete();
      print("Supplier with ID $supplierId deleted successfully.");
    } catch (e) {
      print("Error deleting supplier: $e");
      throw Exception("Failed to delete supplier: $e");
    }
  }
}
