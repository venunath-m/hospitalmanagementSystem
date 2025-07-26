import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccounheadcollectionService {
  Future<bool> addAccountHead(Map<String, dynamic> data) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      if (user == null) throw Exception("User not authenticated");

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null)
        throw Exception("Company ID not found in preferences");

      data['userId'] = user.uid;
      data['companyId'] = companyId;

      await FirebaseFirestore.instance.collection('account_heads').add(data);
      return true;
    } catch (e) {
      debugPrint("Error adding account head: $e");
      return false;
    }
  }

  Future<Map<String, String>> getAccountHeadNamesMap() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null)
        throw Exception("Company ID not found in preferences");

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('account_heads')
              .where('companyId', isEqualTo: companyId)
              .get();

      final Map<String, String> idToNameMap = {};
      for (var doc in querySnapshot.docs) {
        final name = doc.data()['headName'] as String? ?? 'Unknown';
        idToNameMap[doc.id] = name;
      }

      return idToNameMap;
    } catch (e) {
      debugPrint('Error getting account head names: $e');
      return {};
    }
  }

  Future<bool> updateAccountHeads(
    String accountId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null)
        throw Exception("Company ID not found in preferences");

      final docRef = FirebaseFirestore.instance
          .collection('account_heads')
          .doc(accountId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) throw Exception("Account head not found");

      final data = docSnapshot.data();
      if (data?['companyId'] != companyId) {
        throw Exception(
          "User does not have permission to update this account head",
        );
      }

      await docRef.update(updatedData);
      return true;
    } catch (e) {
      debugPrint('Error updating account head: $e');
      return false;
    }
  }

  Future<List<Map<String, String>>> getAllAccountHeads() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null)
        throw Exception("Company ID not found in preferences");

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('account_heads')
              .where('companyId', isEqualTo: companyId)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'headName': data['headName'] as String? ?? '',
          'description': data['description'] as String? ?? '',
          'selectedGroup': data['selectedGroup'] as String? ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint("Error fetching account heads: $e");
      return [];
    }
  }
}
