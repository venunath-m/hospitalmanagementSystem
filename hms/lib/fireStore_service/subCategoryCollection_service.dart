import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubcategorycollectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'subCategories';
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  Future<String?> addSubCategory(Map<String, dynamic> data) async {
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

  Future<Map<int, String>> getSubCategoryNamesMap() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (user.uid != null && companyId != null) {
        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('subCategories')
                .where('companyId', isEqualTo: companyId)
                .get();

        final Map<int, String> idToNameMap = {};

        for (var doc in querySnapshot.docs) {
          final id = int.tryParse(doc.id) ?? -1;
          final name = doc.data()['headName'] as String? ?? 'Unknown';
          idToNameMap[id] = name;
        }

        return idToNameMap;
      } else {
        throw Exception("User not authenticated or companyId not found");
      }
    } catch (e) {
      debugPrint('Error getting subCategories names: $e');
      return {};
    }
  }

  Future<bool> updateSubCategories(
    String subCategoryId,
    Map<String, dynamic> updatedSubCategoriesData,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (user.uid != null && companyId != null) {
        final subCategoriesCollection = FirebaseFirestore.instance.collection(
          'subCategories',
        );
        final subCategoriesDoc =
            await subCategoriesCollection.doc(subCategoryId).get();

        if (subCategoriesDoc.exists) {
          final data = subCategoriesDoc.data();
          final docUserId = data?['userId'];
          final docCompanyId = data?['companyId'];

          if (docUserId == user.uid && docCompanyId == companyId) {
            await subCategoriesCollection
                .doc(subCategoryId)
                .update(updatedSubCategoriesData);
            return true;
          } else {
            throw Exception(
              "User does not have permission to update this subCategories",
            );
          }
        }
      } else {
        throw Exception("User not authenticated or companyId not found");
      }
    } catch (e) {
      debugPrint('Error updating subCategories: $e');
    }

    return false;
  }

  Future<List<Map<String, String>>> getAllsubCategories() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (user.uid != null && companyId != null) {
        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('subCategories')
                .where('companyId', isEqualTo: companyId)
                .get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'headName': data['headName'] as String? ?? '',
            'description': data['description'] as String? ?? '',
            'selectedCategory': data['selectedCategory'] as String? ?? '',
          };
        }).toList();
      } else {
        throw Exception("User not authenticated or companyId not found");
      }
    } catch (e) {
      print("Error fetching subCategories: $e");
      rethrow;
    }
  }
}
