import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountGroupCollectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'account_groups';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Adds a new account group document to Firestore, including the userId.
  Future<String?> addAccountGroup({required Map<String, dynamic> data}) async {
    try {
      // Retrieve the current Firebase user
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Retrieve companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception('companyId not found');

      // Add userId and companyId to the data
      data['userId'] = user.uid; // Use Firebase userId
      data['companyId'] = companyId;

      // Ensure the companyId in the data matches the user's companyId
      if (data['companyId'] != companyId) {
        debugPrint('Mismatch in companyId: ${data['companyId']} != $companyId');
        throw Exception('User is not associated with the correct company.');
      }

      // Add the account group to Firestore
      final docRef = await _firestore.collection('account_groups').add(data);
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding account group: $e');
      return null;
    }
  }

  /// Updates an existing account group document by ID.
  Future<bool> updateAccountGroup(
    String accountGroupId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      // Retrieve the current Firebase user
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Retrieve companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception('companyId not found');

      // Add companyId to the updatedData
      updatedData['companyId'] = companyId;
      updatedData['userId'] = user.uid; // Use Firebase userId

      final docRef = _firestore.collection(_collectionPath).doc(accountGroupId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update(updatedData);
        return true;
      } else {
        debugPrint('Account group with ID $accountGroupId does not exist.');
      }
    } catch (e) {
      debugPrint('Error updating account group: $e');
    }
    return false;
  }

  /// Searches account groups by userId and returns list with headName only.
  Future<List<Map<String, String>>> searchAccountGroupsByUser() async {
    try {
      // Retrieve the current Firebase user
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Retrieve companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception('companyId not found');

      // Perform the Firestore query with both userId and companyId
      final snapshot =
          await _firestore
              .collection(_collectionPath)
              .where('companyId', isEqualTo: companyId)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, 'headName': data['headName']?.toString() ?? ''};
      }).toList();
    } catch (e) {
      debugPrint('Error searching account groups: $e');
      return [];
    }
  }

  /// Fetches all account group documents for a user with headName, description, and accountType.
  Future<List<Map<String, String>>> getAllAccountGroups() async {
    try {
      // Retrieve the current Firebase user
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Retrieve companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception('companyId not found');

      // Perform the Firestore query with both userId and companyId
      final snapshot =
          await _firestore
              .collection(_collectionPath)
              .where('companyId', isEqualTo: companyId)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'headName': data['headName']?.toString() ?? '',
          'description': data['description']?.toString() ?? '',
          'accountType': data['accountType']?.toString() ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching account groups: $e');
      return [];
    }
  }
}
