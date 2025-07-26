import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hms/fireStore_service/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemsCollectionService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  // Update an item
  // Update an item
  Future<bool> updateItem(
    String itemId,
    Map<String, dynamic> updatedItemData,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final itemsCollection = _firestoreService.itemsCollection;
      final logsCollection =
          _firestoreService.logsCollection; // Create reference

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      final itemDoc = await itemsCollection.doc(itemId).get();

      if (itemDoc.exists) {
        final existingData = itemDoc.data() as Map<String, dynamic>;
        debugPrint('Firestore companyId: ${existingData['companyId']}');
        debugPrint('Local (prefs) companyId: $companyId');

        if ((existingData['companyId']?.toString().trim()) ==
            (companyId?.toString().trim())) {
          await itemsCollection.doc(itemId).update(updatedItemData);

          // 🔁 Save audit log
          await logsCollection.add({
            'itemId': itemId,
            'oldData': existingData,
            'newData': updatedItemData,
            'updatedBy': user.uid,
            'updatedByEmail': user.email,
            'companyId': companyId,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          return true;
        } else {
          debugPrint('CompanyId mismatch.');
        }
      } else {
        debugPrint('Item not found.');
      }
    } catch (e) {
      debugPrint('Error updating item: $e');
    }

    return false;
  }

  // Delete an item
  Future<bool> deleteItems(String itemId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final itemsCollection = _firestoreService.itemsCollection;
      final logsCollection = _firestoreService.logsCollection;
      // Retrieve the companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      // Fetch the item document
      final itemDoc = await itemsCollection.doc(itemId).get();

      // Check if the item exists and the companyId matches
      if (itemDoc.exists) {
        // Cast the document data to Map<String, dynamic>
        final itemData = itemDoc.data() as Map<String, dynamic>;

        if (itemData['companyId'] == companyId) {
          // Delete the document if the checks pass
          await itemsCollection.doc(itemId).delete();
          await logsCollection.add({
            'itemId': itemId,
            'oldData': itemData,
            'newData': null,
            'action': 'DELETE',
            'actionType': 'Item',
            'createdBy': user.uid,
            'updatedBy': user.uid,
            'updatedByEmail': user.email,
            'companyId': companyId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return true; // Returns true if the document was successfully deleted
        } else {
          debugPrint('CompanyId mismatch.');
        }
      } else {
        debugPrint('Item not found.');
      }
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }

    return false; // Returns false if the document was not found or an error occurred
  }

  Future<Map<String, dynamic>?> getItemByItemId(String itemId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final itemsCollection = _firestoreService.itemsCollection;

      // Retrieve the companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        debugPrint('Company ID not found in SharedPreferences.');
        return null;
      }

      // Fetch the item document by ID
      final itemDoc = await itemsCollection.doc(itemId).get();

      if (itemDoc.exists) {
        final itemData = itemDoc.data() as Map<String, dynamic>;

        if (itemData['companyId'] == companyId) {
          return itemData; // Return the item data if companyId matches
        } else {
          debugPrint('CompanyId mismatch.');
        }
      } else {
        debugPrint('Item not found.');
      }
    } catch (e) {
      debugPrint('Error fetching item details: $e');
    }

    return null; // Return null if item not found or an error occurred
  }

  // Get item by name
  Future<Map<String, dynamic>?> getItemByName(String name) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final itemsCollection = _firestoreService.itemsCollection;

      // Retrieve the companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      final querySnapshot = await itemsCollection
          .where('name', isEqualTo: name)
          .where('companyId', isEqualTo: companyId) // Filter by companyId
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
      debugPrint('Error fetching item: $e');
    }

    return null;
  }

  // Get items with pagination
  Future<List<Map<String, dynamic>>> getItemsPage(int offset, int limit) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Retrieve the companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      // Fetch the items with pagination, sorted by 'name', and filtered by companyId
      final querySnapshot = await _firestoreService.firestoreInstance.then(
        (firestore) => firestore
            .collection('items') // Firestore collection name
            .where('companyId', isEqualTo: companyId) // Filter by companyId
            .orderBy('name') // Sorting by 'name' field alphabetically
            .startAfter([offset]) // Pagination: start after the offset
            .limit(limit) // Apply limit for pagination
            .get(),
      );

      final List<Map<String, dynamic>> items = [];

      // Loop through documents and build a list of items
      for (var doc in querySnapshot.docs) {
        items.add({
          'id': doc.id, // Firestore document ID
          ...doc.data(), // Add the rest of the document data
        });
      }

      return items;
    } catch (e) {
      debugPrint('Error getting items: $e');
      return [];
    }
  }

  // Add an item to Firestore
  Future<String> addItem(Map<String, dynamic> itemData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final db = FirebaseFirestore.instance; // Firestore instance

      // Retrieve the companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      // Add companyId to the itemData map
      itemData['companyId'] = companyId;

      // Add a new document to the 'items' collection
      final docRef = await db.collection('items').add(itemData);

      // Return the document ID of the newly added item
      return docRef.id;
    } catch (e) {
      debugPrint("Error adding item: $e");
      throw Exception("Error adding item: $e");
    }
  }

  // Update item stock purchase
  Future<void> updateItemStockPurchase(
    String itemId,
    double quantityToAdd,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final db = FirebaseFirestore.instance;

    try {
      final logsCollection = _firestoreService.logsCollection;
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      final docRef = db.collection('items').doc(itemId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final currentData = docSnapshot.data();

        if (currentData?['companyId'] == companyId) {
          final stockValue = currentData?['stock'];
          double currentStock;

          if (stockValue is num) {
            currentStock = stockValue.toDouble();
          } else if (stockValue is String) {
            currentStock = double.tryParse(stockValue) ?? 0.0;
          } else {
            currentStock = 0.0;
          }

          final updatedStock = currentStock + quantityToAdd;

          await docRef.update({'stock': updatedStock});
          await logsCollection.add({
            'itemId': itemId,
            'oldData': currentData,
            'newData': {...currentData!, 'stock': updatedStock},
            'action': 'UPDATE',
            'actionType': 'Stock Purchase Update',
            'createdBy': user.uid,
            'updatedBy': user.uid,
            'updatedByEmail': user.email,
            'companyId': companyId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          debugPrint("Company ID mismatch. Stock update not allowed.");
        }
      } else {
        debugPrint("Item with ID $itemId not found.");
      }
    } catch (e) {
      debugPrint("Error updating item stock: $e");
      throw Exception("Failed to update item stock: $e");
    }
  }

  Future<void> increaseItemStock(String itemId, double quantityToAdd) async {
    final db = FirebaseFirestore.instance;

    try {
      final logsCollection = _firestoreService.logsCollection;
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Retrieve the companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      // Reference to the item document
      final docRef = db.collection('items').doc(itemId);

      // Get current data
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final currentData = docSnapshot.data();

        // Check if the companyId matches
        if (currentData?['companyId'] == companyId) {
          final currentStock =
              (currentData?['stock'] as num?)?.toDouble() ?? 0.0;

          // Calculate updated stock
          final updatedStock = currentStock + quantityToAdd;

          // Update the stock field
          await docRef.update({'stock': updatedStock});
          await logsCollection.add({
            'itemId': itemId,
            'oldData': {'stock': currentStock},
            'newData': {'stock': updatedStock},
            'action': 'UPDATE',
            'actionType': 'Item Stock Increase',
            'updatedBy': user.uid,
            'updatedByEmail': user.email,
            'companyId': companyId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          debugPrint("Company ID mismatch. Stock update not allowed.");
        }
      } else {
        debugPrint("Item with ID $itemId not found.");
      }
    } catch (e) {
      debugPrint("Error updating item stock: $e");
      throw Exception("Failed to update item stock: $e");
    }
  }

  // Get all items
  Future<List<Map<String, dynamic>>> getAllItems() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final db = FirebaseFirestore.instance; // Firestore instance

      // Retrieve the companyId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        debugPrint("Company ID not found in SharedPreferences.");
        return [];
      }

      // Fetch documents only where companyId matches
      final querySnapshot = await db
          .collection('items')
          .where('companyId', isEqualTo: companyId)
          .get();

      // Convert the querySnapshot into a list of maps (item data)
      final List<Map<String, dynamic>> items = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id, // Include document ID
          ...doc.data() as Map<String, dynamic>, // Include the document data
        };
      }).toList();

      return items;
    } catch (e) {
      debugPrint("Error fetching items: $e");
      rethrow; // Rethrow the error for further handling
    }
  }

  // Method to reduce item stock after a sale in Firestore
  Future<void> reduceItemStock(int itemId, double quantitySold) async {
    final db = FirebaseFirestore.instance;
    final logsCollection = _firestoreService.logsCollection; // Create reference
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      final docRef = db.collection('items').doc(itemId.toString());
      final itemDoc = await docRef.get();

      if (itemDoc.exists) {
        final data = itemDoc.data();
        if (data != null && data['companyId'] == companyId) {
          final stockRaw = data['stock'];
          final currentStock = stockRaw is num
              ? stockRaw.toDouble()
              : double.tryParse(stockRaw.toString()) ?? 0.0;
          final newStock = currentStock - quantitySold;

          if (newStock >= 0) {
            await docRef.update({'stock': newStock});

            await logsCollection.add({
              'itemId': itemId.toString(),
              'oldData': {'stock': currentStock},
              'newData': {'stock': newStock},
              'action': 'UPDATE',
              'actionType': 'Item Stock Reduction',
              'updatedBy': user.uid,
              'updatedByEmail': user.email,
              'companyId': companyId,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } else {
            throw Exception("Insufficient stock for the sale.");
          }
        } else {
          throw Exception("Company ID mismatch or item data is null.");
        }
      } else {
        throw Exception("Item with ID $itemId not found.");
      }
    } catch (e) {
      debugPrint("Error reducing stock: $e");
      throw Exception("Failed to reduce stock: $e");
    }
  }
}
