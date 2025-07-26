import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add Firebase Authentication
import 'package:flutter/foundation.dart';
import 'database_service.dart'; // Import your FirestoreService

class CompanycollectionService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

  // Check if the user is authenticated
  Future<User?> getCurrentUser() async {
    return _auth.currentUser; // Get the current authenticated user
  }

  Future<QuerySnapshot> getCompanies({
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    var query = FirebaseFirestore.instance
        .collection('companies')
        .orderBy('companyname')
        .limit(limit);

    if (startAfter != null) query = query.startAfterDocument(startAfter);
    return query.get();
  }

  Future<QuerySnapshot> getCompaniesReverse({
    required int limit,
    DocumentSnapshot? endBefore,
  }) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    var query = FirebaseFirestore.instance
        .collection('companies')
        .orderBy('companyname')
        .limitToLast(limit);

    if (endBefore != null) query = query.endBeforeDocument(endBefore);
    return query.get();
  }

  Future<List<Map<String, dynamic>>> searchCompanies(String keyword) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    final snapshot =
        await FirebaseFirestore.instance
            .collection('companies')
            .where('companyname', isGreaterThanOrEqualTo: keyword)
            .where('companyname', isLessThanOrEqualTo: '$keyword\uf8ff')
            .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Future<void> deleteCompany(int companyId) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    try {
      final companiesCollection = await _firestoreService.firestoreInstance
          .then((firestore) => firestore.collection('companies'));

      await companiesCollection.doc(companyId.toString()).delete();
      print("Company with ID $companyId deleted successfully.");
    } catch (e) {
      print("Error deleting company: $e");
    }
  }

  Future<void> updateCompany(
    String companyId,
    Map<String, dynamic> updatedCompanyData,
  ) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    try {
      final companiesCollection = await _firestoreService.firestoreInstance
          .then((firestore) => firestore.collection('companies'));

      await companiesCollection.doc(companyId).update(updatedCompanyData);
      print("Company with ID $companyId updated successfully.");
    } catch (e) {
      print("Error updating company: $e");
    }
  }

  Future<String> addCompany(Map<String, dynamic> companyData) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    try {
      final companiesCollection = await _firestoreService.firestoreInstance
          .then((firestore) => firestore.collection('companies'));

      final companyRef = await companiesCollection.add(companyData);
      return companyRef.id;
    } catch (e) {
      print("Error adding company: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllCompanies() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    try {
      final companiesCollection = await _firestoreService.firestoreInstance
          .then((firestore) => firestore.collection('companies'));

      final snapshot = await companiesCollection.get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print("Error fetching companies: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCompanyById(String companyId) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    try {
      final companiesCollection = await _firestoreService.firestoreInstance
          .then((firestore) => firestore.collection('companies'));

      final docSnapshot = await companiesCollection.doc(companyId).get();

      if (docSnapshot.exists) {
        return {
          'id': docSnapshot.id,
          ...docSnapshot.data() as Map<String, dynamic>,
        };
      } else {
        print("Company with ID $companyId not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching company by ID: $e");
      rethrow;
    }
  }
}
