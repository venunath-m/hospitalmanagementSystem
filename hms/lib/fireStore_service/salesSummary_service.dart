import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hms/dbservices/salessummarymodel.dart'; // Assuming SalesSummary model is imported
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart'; // Import your FirestoreService

class SalessummaryService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  // Method to fetch pending dues from sales summary
  Future<void> deleteSalesSummaryAndDetails(String summaryId) async {
    try {
      // Delete all sales_details with matching summaryId
      final detailSnapshot = await FirebaseFirestore.instance
          .collection('sales_details')
          .where('salesId', isEqualTo: summaryId)
          .get();

      for (var doc in detailSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the sales_summary document
      await FirebaseFirestore.instance
          .collection('sales_summary')
          .doc(summaryId)
          .delete();

      debugPrint('Deleted summary and related details for ID: $summaryId');
    } catch (e) {
      debugPrint('Error deleting sales record: $e');
      rethrow;
    }
  }

  Future<void> markAsDelivered(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyId');
    final userId = prefs.getString('userId');

    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('sales_summary').doc(id);

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      throw Exception("Document not found");
    }

    final data = snapshot.data();
    if (data == null || data['companyId'] != companyId) {
      throw Exception("Unauthorized access: Company ID mismatch");
    }

    // Save old data for logging
    final oldData = Map<String, dynamic>.from(data);

    // Update main sales_summary document
    final updatedFields = {
      'deliveryStatus': 'Delivered',
      'deliveredBy': userId,
      'deliveredAt': DateTime.now().toIso8601String(),
    };
    await docRef.update(updatedFields);

    // Log this update
    final logsCollection = _firestoreService.logsCollection;
    await logsCollection.add({
      'itemId': docRef.id,
      'oldData': oldData,
      'newData': {...oldData, ...updatedFields},
      'action': 'UPDATE',
      'actionType': 'Sales Summary - Mark Delivered',
      'createdBy': userId,
      'updatedBy': userId,
      'updatedByEmail': user.email,
      'companyId': companyId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update customerOrdersSummary if needed
    final orderId = data['orderId']?.toString();
    if (orderId != null && orderId.trim().isNotEmpty) {
      final querySnapshot = await firestore
          .collection('customerOrdersSummary')
          .where('orderId', isEqualTo: orderId)
          .where('companyId', isEqualTo: companyId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final orderDoc = querySnapshot.docs.first.reference;

        final orderOldData = querySnapshot.docs.first.data();
        final orderUpdatedFields = {
          'deliveryStatus': 'Delivered',
          'deliveredAt': DateTime.now().toIso8601String(),
          'deliveredBy': userId,
        };

        await orderDoc.update(orderUpdatedFields);

        // Log update to customerOrdersSummary too
        await logsCollection.add({
          'itemId': orderDoc.id,
          'oldData': orderOldData,
          'newData': {...orderOldData, ...orderUpdatedFields},
          'action': 'UPDATE',
          'actionType': 'Customer Order Summary - Mark Delivered',
          'createdBy': userId,
          'updatedBy': userId,
          'updatedByEmail': user.email,
          'companyId': companyId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<List<SalesSummary>> fetchPendingDues() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Get companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('sales_summary') // Firestore collection name
          .where('status', isEqualTo: 'pending') // Filter by 'status' field
          .where('companyId', isEqualTo: companyId) // Add companyId filter
          .get(); // Fetch all documents matching the filter

      // Convert the fetched documents into a list of SalesSummary
      List<SalesSummary> pendingDues = querySnapshot.docs.map((doc) {
        return SalesSummary.fromMap({
          'id': doc.id, // Document ID
          ...doc.data()
              as Map<String, dynamic>, // Add all fields from the document
        });
      }).toList();

      return pendingDues; // Return the list of SalesSummary
    } catch (e) {
      debugPrint('Error fetching pending dues: $e');
      return []; // Return an empty list in case of error
    }
  }

  Future<void> markBillAsPaid(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyId');

    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('sales_summary').doc(id);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      throw Exception("Document not found");
    }

    final data = snapshot.data();
    if (data == null || data['companyId'] != companyId) {
      throw Exception("Unauthorized access: Company ID mismatch");
    }

    // Update main sales_summary document
    await docRef.update({'status': 'paid'});

    // Check and update customerOrdersSummary if orderId exists
    final orderId = data['orderId']?.toString();
    if (orderId != null && orderId.trim().isNotEmpty) {
      final querySnapshot = await firestore
          .collection('customerOrdersSummary')
          .where('orderId', isEqualTo: orderId)
          .where('companyId', isEqualTo: companyId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final orderDoc = querySnapshot.docs.first.reference;
        await orderDoc.update({'status': 'Paid'});
      }
    }
  }

  // Method to add sales summary to Firestore
  Future<String> addSalesSummary(Map<String, dynamic> salesData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Get companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      // Add companyId to the sales data
      salesData['companyId'] = companyId;

      final db = FirebaseFirestore.instance; // Firestore instance

      // Add the sales data to the 'sales_summary' collection
      final salesSummaryRef = await db
          .collection('sales_summary')
          .add(salesData);
      final logsCollection =
          _firestoreService.logsCollection; // Add your logs collection ref here
      await logsCollection.add({
        'itemId': salesSummaryRef.id,
        'oldData': null, // no previous data on creation
        'newData': {...salesData, 'id': salesSummaryRef.id},
        'action': 'CREATE',
        'actionType': 'Sales Summary',
        'createdBy': user.uid,
        'updatedBy': user.uid,
        'updatedByEmail': user.email,
        'companyId': companyId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return salesSummaryRef
          .id; // Return the document ID after successfully adding the data
    } catch (e) {
      print("Error adding sales summary: $e");
      throw Exception("Failed to add sales summary: $e");
    }
  }

  // Method to get sales summary page with pagination and date filtering
  Future<List<Map<String, dynamic>>> getSalesSummaryPage({
    required DateTime startDate,
    required DateTime endDate,
    required int offset,
    required int limit,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final db = FirebaseFirestore.instance;

    try {
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      // Perform query with companyId and date range
      final querySnapshot = await db
          .collection('sales_summary')
          .where('companyId', isEqualTo: companyId)
          .where(
            'billEntryDate',
            isGreaterThanOrEqualTo: startDate.toIso8601String(),
          )
          .where(
            'billEntryDate',
            isLessThanOrEqualTo: endDate.toIso8601String(),
          )
          .orderBy('billEntryDate', descending: true)
          .get();

      // Apply offset and limit locally (not efficient for large datasets)
      final allDocs = querySnapshot.docs;
      final pagedDocs = allDocs.skip(offset).take(limit);

      return pagedDocs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print("Error fetching sales summary page: $e");
      throw Exception("Failed to fetch sales summary: $e");
    }
  }

  // Method to count sales summary records in a date range
  Future<int> countSalesSummaryInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final db = FirebaseFirestore.instance;

    try {
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      final querySnapshot = await db
          .collection('sales_summary')
          .where('companyId', isEqualTo: companyId)
          .where(
            'billEntryDate',
            isGreaterThanOrEqualTo: startDate.toIso8601String(),
          )
          .where(
            'billEntryDate',
            isLessThanOrEqualTo: endDate.toIso8601String(),
          )
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print("Error counting sales summary: $e");
      throw Exception("Failed to count sales summary: $e");
    }
  }

  // Method to get all sales summaries from Firestore
  Future<List<Map<String, dynamic>>> getAllSalesSummary() async {
    final db = FirebaseFirestore.instance;

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      // Grab current companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      // Query only those summaries belonging to this company
      final querySnapshot = await db
          .collection('sales_summary')
          .where('companyId', isEqualTo: companyId)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print("Error getting all sales summaries: $e");
      throw Exception("Failed to get sales summaries: $e");
    }
  }

  // Method to get sales summary sorted by date (descending)
  Future<List<Map<String, dynamic>>> getSalesSummary() async {
    final db = FirebaseFirestore.instance;
    final List<Map<String, dynamic>> salesSummaryList = [];

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null)
        throw Exception("Company ID not found in preferences.");

      final querySnapshot = await db
          .collection('sales_summary')
          .where('companyId', isEqualTo: companyId)
          .orderBy('billEntryDate', descending: true)
          .get();

      for (var doc in querySnapshot.docs) {
        salesSummaryList.add({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
    } catch (e) {
      debugPrint("Error fetching sales summary: $e");
      rethrow;
    }

    return salesSummaryList;
  }

  // Method to get total sales from the Firestore 'sales_summary' collection
  Future<double> getTotalSales() async {
    final db = FirebaseFirestore.instance; // Firestore instance
    double totalSales = 0;

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      final querySnapshot = await db
          .collection('sales_summary')
          .where('companyId', isEqualTo: companyId)
          .get(); // Fetch all sales records

      for (var doc in querySnapshot.docs) {
        final grandTotal = doc.data()['grandTotal'] as double? ?? 0;
        totalSales +=
            grandTotal; // Sum the 'grandTotal' field for all documents
      }
    } catch (e) {
      print("Error fetching total sales: $e");
      throw Exception("Failed to fetch total sales: $e");
    }

    return totalSales; // Return the total sales value
  }

  Future<List<Map<String, dynamic>>> getFilteredSalesSummary({
    required DateTime startDate,
    required DateTime endDate,
    String? customerId,
  }) async {
    try {
      final db = FirebaseFirestore.instance;
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception("Company ID not found");

      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
        999,
      );

      Query query = db
          .collection('sales_summary')
          .where('companyId', isEqualTo: companyId)
          .where(
            'billEntryDate',
            isGreaterThanOrEqualTo: start.toIso8601String(),
          )
          .where('billEntryDate', isLessThanOrEqualTo: end.toIso8601String());

      if (customerId != null && customerId.isNotEmpty) {
        query = query.where('customerId', isEqualTo: customerId);
        debugPrint('Filtering by customer ID: $customerId');
      }

      final querySnapshot = await query.get();
      debugPrint("Found ${querySnapshot.docs.length} docs");

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e, stack) {
      debugPrint("Error fetching filtered sales summary: $e");
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }
}
