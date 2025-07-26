import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart'; // Replace with your actual FirestoreService path

class CustomerService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  // Add a new customer to Firestore
  Future<String> addCustomer(Map<String, dynamic> customerData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Retrieve companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) throw Exception('companyId not found');

      // Add companyId to the customer data
      customerData['userId'] = user.uid;
      customerData['companyId'] = companyId;

      final db = FirebaseFirestore.instance;
      final docRef = await db.collection('customers').add(customerData);
      return docRef.id;
    } catch (e) {
      debugPrint("Error adding customer: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCustomerById(String customerId) async {
    try {
      final db = FirebaseFirestore.instance;
      final doc = await db.collection('customers').doc(customerId).get();
      if (doc.exists) {
        return doc.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching customer by ID: $e');
      return null;
    }
  }

  // Update customer by document ID and userId
  Future<bool> updateCustomer(
    String customerId,
    Map<String, dynamic> updatedCustomerData,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final firestore = await _firestoreService.firestoreInstance;
      final customersCollection = firestore.collection('customers');

      final customerDoc = await customersCollection.doc(customerId).get();

      if (customerDoc.exists) {
        final customerData = customerDoc.data();
        final storedCompanyId = customerData?['companyId'];
        final prefs = await SharedPreferences.getInstance();
        final companyId = prefs.getString('companyId');
        // Check if the customer belongs to the current user and company
        if (storedCompanyId == companyId) {
          // Optionally, retrieve the companyId from shared preferences if not present in the data
          if (storedCompanyId == null) {
            final prefs = await SharedPreferences.getInstance();
            final companyId = prefs.getString('companyId');
            if (companyId == null) throw Exception('CompanyId not found');
            updatedCustomerData['companyId'] = companyId;
          } else {
            updatedCustomerData['companyId'] = storedCompanyId;
          }

          await customersCollection.doc(customerId).update(updatedCustomerData);
          return true; // Update successful
        } else {
          debugPrint("User does not have permission to update this customer.");
        }
      }
    } catch (e) {
      debugPrint('Error updating customer: $e');
    }
    return false; // Update failed
  }

  // Delete customer by document ID and userId
  Future<bool> deleteCustomer(String customerId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final firestore = await _firestoreService.firestoreInstance;
      final customersCollection = firestore.collection('customers');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        debugPrint('CompanyId not found in SharedPreferences.');
        return false;
      }

      final customerDoc = await customersCollection.doc(customerId).get();

      if (!customerDoc.exists) {
        debugPrint('Customer does not exist.');
        return false;
      }

      final customerData = customerDoc.data();
      final storedCompanyId = customerData?['companyId'];

      if (storedCompanyId != companyId) {
        debugPrint(
          'Company ID mismatch or user not authorized to delete this customer.',
        );
        return false;
      }

      await customersCollection.doc(customerId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting customer: $e');
      return false;
    }
  }

  // Get customer by name and billing address for a specific user
  Future<Map<String, dynamic>?> getCustomerByNameAndAddress(
    String name,
    String billingAddress,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final firestore = await _firestoreService.firestoreInstance;
      final customersCollection = firestore.collection('customers');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      // Query the customers collection with userId, name, and billingAddress
      final querySnapshot =
          await customersCollection
              .where('companyId', isEqualTo: companyId)
              .where('name', isEqualTo: name)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final customerData = doc.data();
        final storedCompanyId = customerData['companyId'];

        // Optional: Validate companyId if necessary
        final prefs = await SharedPreferences.getInstance();
        final companyId = prefs.getString('companyId');
        if (companyId != storedCompanyId) {
          debugPrint('Company ID mismatch');
          return null; // Return null if the companyId doesn't match
        }

        // Return the customer data if companyId matches
        return {'id': doc.id, ...customerData};
      }
    } catch (e) {
      debugPrint('Error fetching customer: $e');
    }

    return null;
  }

  // Update balance for a user-scoped customer
  Future<void> updateCustomerBalance(
    String customerId,
    double balanceAmount,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final db = FirebaseFirestore.instance;
      final docRef = db.collection('customers').doc(customerId);
      final customerDoc = await docRef.get();
      final logsCollection = _firestoreService.logsCollection;
      if (customerDoc.exists) {
        final storedCompanyId = customerDoc.data()?['companyId'];

        // Retrieve the companyId from shared preferences
        final prefs = await SharedPreferences.getInstance();
        final companyId = prefs.getString('companyId');

        // Validate if the companyId matches
        if (companyId != storedCompanyId) {
          debugPrint('Company ID mismatch');
          return; // Exit early if companyId doesn't match
        }

        // Update balance if companyId matches
        double currentBalance = customerDoc.data()?['balance'] ?? 0.0;
        double newBalance = currentBalance + balanceAmount;

        await docRef.update({'balance': newBalance});
        await logsCollection.add({
          'itemId': customerId,
          'oldData': {'balance': currentBalance},
          'newData': {'balance': newBalance},
          'action': 'UPDATE',
          'actionType': 'Customer Balance Update',
          'updatedBy': user.uid,
          'updatedByEmail': user.email,
          'companyId': companyId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint("Customer balance updated successfully.");
      } else {
        debugPrint("Customer not found or access denied.");
      }
    } catch (e) {
      debugPrint("Error updating customer balance: $e");
    }
  }

  // Get all customers for a user
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final db = FirebaseFirestore.instance;

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        debugPrint("❌ companyId is null in SharedPreferences");
        return [];
      }

      final querySnapshot =
          await db
              .collection('customers')
              .where('companyId', isEqualTo: companyId)
              .get();

      final customers =
          querySnapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();

      debugPrint("✅ Fetched ${customers.length} customers");
      return customers;
    } catch (e) {
      debugPrint("❌ Error fetching customers: $e");
      rethrow;
    }
  }

  // Get all customers with selected fields for a user
  Future<List<Map<String, dynamic>>> getAllCustomersWithId() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final db = FirebaseFirestore.instance;

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception('Company ID not found');

      final querySnapshot =
          await db
              .collection('customers')
              .where('companyId', isEqualTo: companyId)
              .get();

      return querySnapshot.docs
          .where((doc) {
            final storedCompanyId = doc.data()?['companyId'];
            return storedCompanyId == companyId;
          })
          .map((doc) {
            final data = doc.data();
            return {
              'customerId': doc.id,
              'name': data['name'] ?? '',
              'contact': data['contact'] ?? '',
              'billingAddress': data['billingAddress'] ?? '',
              'shippingAddress': data['shippingAddress'] ?? '',
              'balance': data['balance'] ?? 0.0,
              'gstin': data['gstin'] ?? '',
            };
          })
          .toList();
    } catch (e, stack) {
      debugPrint("Error fetching customers with ID: $e");
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }

  // Get GSTIN for a customer (scoped to user)
  Future<Map<String, dynamic>> getCustomerGstin(
    String userId,
    String customerId,
  ) async {
    Map<String, dynamic> result = {};
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final db = FirebaseFirestore.instance;

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception('Company ID not found');

      final docSnapshot =
          await db.collection('customers').doc(customerId).get();

      if (docSnapshot.exists && docSnapshot.data()?['companyId'] == companyId) {
        final data = docSnapshot.data()!;
        result['status'] = 1;
        result['message'] = 'Customer details retrieved successfully';
        result['gstin'] = data['gstin'] ?? 'N/A';
        result['address'] = data['address'] ?? 'N/A';
        result['shippingAddress'] = data['shippingAddress'] ?? 'N/A';
      } else {
        result['status'] = 0;
        result['message'] =
            'Customer not found, access denied, or company mismatch.';
        result['gstin'] = 'N/A';
        result['address'] = 'N/A';
        result['shippingAddress'] = 'N/A';
      }
    } catch (e, stack) {
      debugPrint('Error fetching customer data: $e');
      debugPrintStack(stackTrace: stack);
      result = {
        'status': -1,
        'message': 'Error fetching customer data: $e',
        'gstin': 'N/A',
        'address': 'N/A',
        'shippingAddress': 'N/A',
      };
    }
    return result;
  }
}
