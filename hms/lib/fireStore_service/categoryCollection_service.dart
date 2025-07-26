import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategorycollectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'categories';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Adds a new account group document to Firestore, including the userId.
  Future<String?> addCategory({
    required Map<String, dynamic> data,
    required String userId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Retrieve companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception('companyId not found');

      // Add userId and companyId to the data
      data['userId'] = user.uid;
      data['companyId'] = companyId;

      // Add the account group to Firestore
      final docRef = await _firestore.collection(_collectionPath).add(data);
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding Category: $e');
      return null;
    }
  }

  /// Updates an existing account group document by ID.
  Future<bool> updateCategory(
    String categoryId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Retrieve companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) throw Exception('companyId not found');

      // Add companyId to the updatedData
      updatedData['companyId'] = companyId;
      updatedData['userId'] = user.uid;

      final docRef = _firestore.collection(_collectionPath).doc(categoryId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update(updatedData);
        return true;
      } else {
        debugPrint('Category with ID $categoryId does not exist.');
      }
    } catch (e) {
      debugPrint('Error updating Category: $e');
    }
    return false;
  }

  /// Searches account groups by userId and returns list with headName only.
  Future<List<Map<String, String>>> searchCategoryByUser(String userId) async {
    try {
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
      debugPrint('Error searching Category: $e');
      return [];
    }
  }

  /// Fetches all account group documents for a user with headName, description, and accountType.
  Future<List<Map<String, String>>> getAllCategory(String userId) async {
    try {
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
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching Category: $e');
      return [];
    }
  }
}
