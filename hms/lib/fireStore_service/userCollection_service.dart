import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart'; // Import your FirestoreService

class UsercollectionService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  // Delete a user by userId
  Future<void> deleteUser(int userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception('Company ID not found in SharedPreferences.');
      }

      final usersCollection = await _firestoreService.firestoreInstance.then(
        (firestore) => firestore.collection('users'),
      );

      // Fetch the user document to ensure the deletion is for the correct company
      final userDoc = await usersCollection.doc(userId.toString()).get();

      if (userDoc.exists) {
        // Check if the user's companyId matches the one from SharedPreferences
        final userData = userDoc.data();
        if (userData != null && userData['companyId'] == companyId) {
          // Proceed with deleting the user
          await usersCollection.doc(userId.toString()).delete();
          print("User with ID $userId deleted successfully.");
        } else {
          throw Exception('User does not belong to the current company.');
        }
      } else {
        throw Exception('User not found.');
      }
    } catch (e) {
      debugPrint("Error deleting user: $e");
    }
  }

  // Update a user by userId with new data
  Future<void> updateUser(
    int userId,
    Map<String, dynamic> updatedUserData,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception('Company ID not found in SharedPreferences.');
      }

      // Add the companyId to the updatedUserData map to ensure the update is for the correct company
      updatedUserData['companyId'] = companyId;

      final usersCollection = await _firestoreService.firestoreInstance.then(
        (firestore) => firestore.collection('users'),
      );

      // Update the user document where the 'id' field matches the userId
      await usersCollection
          .doc(userId.toString()) // Use userId as the document ID
          .update(updatedUserData); // Update the document with the new data

      print("User with ID $userId updated successfully.");
    } catch (e) {
      debugPrint("Error updating user: $e");
    }
  }

  // Add a user to Firestore
  Future<String> addUser(Map<String, dynamic> userData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Add the companyId to the userData map to associate the user with the correct company

      final usersCollection = await _firestoreService.firestoreInstance.then(
        (firestore) => firestore.collection('users'),
      );

      // Add the user data to the 'users' collection
      final userRef = await usersCollection.add(userData);

      // Return the document ID of the added user
      return userRef.id;
    } catch (e) {
      debugPrint("Error adding user: $e");
      rethrow; // Rethrow the error for further handling
    }
  }

  // Get all users from Firestore
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception('Company ID not found in SharedPreferences.');
      }

      final usersCollection = await _firestoreService.firestoreInstance.then(
        (firestore) => firestore.collection('users'),
      );

      final snapshot =
          await usersCollection
              .where('companyId', isEqualTo: companyId) // Filter by companyId
              .get(); // Fetch all documents in 'users' collection

      // Convert the snapshot to a List of Maps (each document in the collection)
      final List<Map<String, dynamic>> users =
          snapshot.docs.map((doc) {
            return {
              'id': doc.id, // Document ID
              ...doc.data(), // Document fields
            };
          }).toList();

      return users;
    } catch (e) {
      debugPrint("Error fetching users: $e");
      rethrow; // Rethrow the error for further handling
    }
  }
}
