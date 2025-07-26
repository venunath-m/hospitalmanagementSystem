import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart'; // Import your FirestoreService

class SaledetailcollectionService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  // Method to add sales details to Firestore
  Future<void> saveClosingStock(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final db = FirebaseFirestore.instance;

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      final enteredBy = prefs.getString('inputUsername');

      if (companyId == null) {
        throw Exception('Company ID not found in SharedPreferences');
      }

      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final timeStr = DateFormat.Hm().format(now);

      // Fetch current items stock for this company
      final itemsSnapshot = await db
          .collection('items')
          .where('companyId', isEqualTo: companyId)
          .get();

      if (itemsSnapshot.docs.isEmpty) {
        debugPrint('No items found for companyId: $companyId');
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('No Data'),
            content: const Text(
              'No stock data found to save for this company.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      for (final doc in itemsSnapshot.docs) {
        final data = doc.data();

        final stockData = {
          'itemId': doc.id,
          'name': data['name'] ?? '',
          'companyId': companyId,
          'stock': data['stock'] ?? 0,
          'rate': data['rate'] ?? 0,
          'unit': data['unit'] ?? '',
          'date': dateStr,
          'entryTime': timeStr,
          'enteredBy': enteredBy,
        };

        // Use unique doc ID combining item ID and date
        final docId = '${doc.id}_$dateStr';

        debugPrint('Saving stockData for docId: $docId, data: $stockData');

        await db.collection('dailyStock').doc(docId).set(stockData);
      }

      debugPrint('Closing stock saved successfully for date: $dateStr');

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Closing stock saved successfully!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e, stacktrace) {
      debugPrint('Error saving closing stock: $e');
      debugPrint(stacktrace.toString());

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to save closing stock.\nError: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getDetailedCategoryData(
    String category,
    DateTime? start,
    DateTime? end,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyId');

    if (companyId == null) {
      throw Exception("Company ID not found in SharedPreferences.");
    }

    CollectionReference collection;
    Query query;

    switch (category) {
      case 'creditSales':
      case 'cashSales':
      case 'bankSales':
        collection = firestore.collection('sales_summary');
        query = collection
            .where('companyId', isEqualTo: companyId)
            .where(
              'paymentMode',
              isEqualTo: category == 'creditSales'
                  ? 'Credit'
                  : category == 'cashSales'
                  ? 'Cash'
                  : 'Bank',
            );
        break;

      case 'purchases':
        collection = firestore.collection('purchase_summary');
        query = collection.where('companyId', isEqualTo: companyId);
        break;

      case 'whatsappPaid':
      case 'whatsappPending':
        collection = firestore.collection('customerOrdersSummary');
        query = collection
            .where('companyId', isEqualTo: companyId)
            .where(
              'status',
              isEqualTo: category == 'whatsappPaid' ? 'Paid' : 'Pending',
            );
        break;
      case 'customerReceipts':
      case 'customerPayments':
        collection = firestore.collection('customer_ledger');
        query = collection.where('companyId', isEqualTo: companyId);
        break;
      case 'delivered':
        collection = firestore.collection('sales_summary');
        query = collection
            .where('companyId', isEqualTo: companyId)
            .where('deliveryStatus', isEqualTo: 'Delivered');
        break;

      default:
        collection = firestore.collection('sales_summary');
        query = collection.where('companyId', isEqualTo: companyId);
    }

    try {
      final snapshot = await query.get();

      // Choose correct date field based on category
      String dateField;
      switch (category) {
        case 'purchases':
          dateField = 'invoiceDate';
          break;
        case 'whatsappPaid':
        case 'whatsappPending':
          dateField = 'createdAt';
          break;
        case 'customerReceipts':
        case 'customerPayments':
          dateField = 'date';
          break;

        default:
          dateField = 'billEntryDate';
      }

      // Filter manually using parseDate
      final filteredDocs = snapshot.docs
          .where((doc) {
            final docData = doc.data() as Map<String, dynamic>;
            final parsedDate = parseDate(docData[dateField]);
            if (start != null &&
                parsedDate != null &&
                parsedDate.isBefore(start)) {
              return false;
            }
            if (end != null && parsedDate != null && parsedDate.isAfter(end)) {
              return false;
            }
            return true;
          })
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return filteredDocs;
    } catch (e) {
      print("Error fetching $category data: $e");
      return [];
    }
  }

  DateTime? parseDate(dynamic rawDate) {
    if (rawDate == null) return null;
    if (rawDate is Timestamp) return rawDate.toDate();
    if (rawDate is String) {
      try {
        return DateTime.parse(rawDate);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> getConsolidatedReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception('Company ID not found');

      final firestore = FirebaseFirestore.instance;

      double creditSales = 0;
      double cashSales = 0;
      double bankSales = 0;
      double totalPurchases = 0;
      int whatsappOrdersPaid = 0;
      int whatsappOrdersPending = 0;
      int customerOrdersDelivered = 0;
      double customerReceipts = 0;
      double customerPayments = 0;

      final transactionsSnapshot = await firestore
          .collection('customer_ledger')
          .where('companyId', isEqualTo: companyId)
          .get();

      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final txnDate = parseDate(data['date']);

        if (txnDate == null ||
            txnDate.isBefore(startDate) ||
            txnDate.isAfter(endDate)) {
          continue;
        }

        customerReceipts += double.tryParse(data['credit'].toString()) ?? 0;
        customerPayments += double.tryParse(data['debit'].toString()) ?? 0;
      }

      final salesSnapshot = await firestore
          .collection('sales_summary')
          .where('companyId', isEqualTo: companyId)
          .get();

      for (var doc in salesSnapshot.docs) {
        final data = doc.data();
        final billDate = parseDate(data['billEntryDate']);

        if (billDate == null ||
            billDate.isBefore(startDate) ||
            billDate.isAfter(endDate)) {
          continue;
        }

        if (data['status'] == 'pending') {
          creditSales += double.tryParse(data['grandTotal'].toString()) ?? 0;
        } else {
          if (data['paymentMode'] == 'Cash') {
            cashSales += double.tryParse(data['grandTotal'].toString()) ?? 0;
          } else if (data['paymentMode'] == 'Bank') {
            bankSales += double.tryParse(data['grandTotal'].toString()) ?? 0;
          }
        }

        if (data['deliveryStatus'] == 'Delivered') {
          customerOrdersDelivered++;
        }
      }

      final whatsappSnapshot = await firestore
          .collection('customerOrdersSummary')
          .where('companyId', isEqualTo: companyId)
          .get();

      for (var doc in whatsappSnapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        if (createdAt.isBefore(startDate) || createdAt.isAfter(endDate))
          continue;

        if (data['status'] == 'Paid') {
          whatsappOrdersPaid++;
        } else {
          whatsappOrdersPending++;
        }
      }

      final purchaseSnapshot = await firestore
          .collection('purchase_summary')
          .where('companyId', isEqualTo: companyId)
          .get();

      for (var doc in purchaseSnapshot.docs) {
        final data = doc.data();
        final purchaseDate = parseDate(data['purchaseEnteredDate']);

        if (purchaseDate == null ||
            purchaseDate.isBefore(startDate) ||
            purchaseDate.isAfter(endDate)) {
          continue;
        }

        totalPurchases +=
            double.tryParse(data['invoiceAmount'].toString()) ?? 0;
      }

      return {
        'creditSales': creditSales,
        'cashSales': cashSales,
        'bankSales': bankSales,
        'totalPurchases': totalPurchases,
        'whatsappOrdersPaid': whatsappOrdersPaid,
        'whatsappOrdersPending': whatsappOrdersPending,
        'customerOrdersDelivered': customerOrdersDelivered,
        'customerReceipts': customerReceipts,
        'customerPayments': customerPayments,
      };
    } catch (e, stack) {
      debugPrint('Error in getConsolidatedReport: $e');
      debugPrintStack(stackTrace: stack);
      return {
        'creditSales': 0.0,
        'cashSales': 0.0,
        'bankSales': 0.0,
        'totalPurchases': 0.0,
        'whatsappOrdersPaid': 0,
        'whatsappOrdersPending': 0,
        'customerOrdersDelivered': 0,
        'customerReceipts': 0.0,
        'customerPayments': 0.0,
      };
    }
  }

  Future<String> addSalesDetail(Map<String, dynamic> salesDetailData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final db = FirebaseFirestore.instance; // Firestore instance

      // Get companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      // Add the companyId to the sales detail data
      salesDetailData['companyId'] = companyId;

      // Add the sales details data to the 'sales_details' collection
      final salesDetailRef = await db
          .collection('sales_details')
          .add(salesDetailData);
      final logsCollection = _firestoreService.logsCollection;
      await logsCollection.add({
        'itemId': salesDetailRef.id,
        'oldData': null, // no previous data on creation
        'newData': {...salesDetailData, 'id': salesDetailRef.id},
        'action': 'CREATE',
        'actionType': 'Sales Detail',
        'createdBy': user.uid,
        'updatedBy': user.uid,
        'updatedByEmail': user.email,
        'companyId': companyId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Return the document ID after successfully adding the data
      return salesDetailRef.id;
    } catch (e) {
      print("Error adding sales detail: $e");
      throw Exception("Failed to add sales detail: $e");
    }
  }

  // Method to get sales details by sales summary ID from Firestore
  Future<List<Map<String, dynamic>>> getSalesDetailsBySummaryId(
    String salesId,
  ) async {
    final db = FirebaseFirestore.instance;
    final List<Map<String, dynamic>> salesDetails = [];

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null)
        throw Exception("Company ID not found in preferences.");

      final querySnapshot = await db
          .collection('sales_details')
          .where('salesId', isEqualTo: salesId)
          .where('companyId', isEqualTo: companyId)
          .get();

      for (var doc in querySnapshot.docs) {
        salesDetails.add({'id': doc.id, ...doc.data() as Map<String, dynamic>});
      }
    } catch (e) {
      debugPrint("Error fetching sales details: $e");
      rethrow;
    }

    return salesDetails;
  }

  // Additional method to get all sales details (if needed)
  Future<List<Map<String, dynamic>>> getAllSalesDetails() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final db = FirebaseFirestore.instance; // Firestore instance

    List<Map<String, dynamic>> allSalesDetails = [];

    try {
      // Get companyId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) {
        throw Exception("Company ID not found in SharedPreferences.");
      }

      // Fetch all sales details where companyId matches the stored companyId
      final querySnapshot = await db
          .collection(
            'sales_details',
          ) // Replace with your actual collection name
          .where('companyId', isEqualTo: companyId) // Add companyId filter
          .get();

      // Convert query snapshot to a list of maps
      for (var doc in querySnapshot.docs) {
        allSalesDetails.add({
          'id': doc.id, // Document ID
          ...doc.data() as Map<String, dynamic>, // Document fields
        });
      }
    } catch (e) {
      print("Error fetching all sales details: $e");
      throw Exception("Failed to fetch all sales details: $e");
    }

    return allSalesDetails;
  }

  Future<List<Map<String, dynamic>>> getSalesDetailsWithHSN(
    String salesId,
  ) async {
    try {
      final db = FirebaseFirestore.instance;
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception("Company ID not found");

      final salesDetailsSnap = await db
          .collection('sales_details')
          .where('salesId', isEqualTo: salesId)
          .where('companyId', isEqualTo: companyId)
          .get();

      List<Map<String, dynamic>> detailedSales = [];

      for (var doc in salesDetailsSnap.docs) {
        final data = doc.data();
        final itemId = data['itemId'];

        final itemDoc = await db.collection('items').doc(itemId).get();
        final hsnCode = itemDoc.data()?['hsnCode'] ?? 'N/A';

        detailedSales.add({'id': doc.id, ...data, 'hsnCode': hsnCode});
      }

      return detailedSales;
    } catch (e, stack) {
      debugPrint('Error fetching sales details with HSN for $salesId: $e');
      debugPrintStack(stackTrace: stack);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFilteredSalesReport({
    String? itemName,
    String? hsnCode,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = FirebaseFirestore.instance;
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyId');
    if (companyId == null) throw Exception("Company ID not found");
    // Step 1: Filter items
    Query itemsQuery = db
        .collection('items')
        .where('companyId', isEqualTo: companyId);
    if (itemName != null && itemName.isNotEmpty) {
      itemsQuery = itemsQuery.where('itemName', isEqualTo: itemName);
    }
    if (hsnCode != null && hsnCode.isNotEmpty) {
      itemsQuery = itemsQuery.where('hsnCode', isEqualTo: hsnCode);
    }

    final itemsSnapshot = await itemsQuery.get();
    final itemIds = itemsSnapshot.docs.map((e) => e.id).toList();
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
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();
    // Step 2: Filter sales_summary by date
    Query summaryQuery = db
        .collection('sales_summary')
        .where('companyId', isEqualTo: companyId);
    if (startDate != null) {
      summaryQuery = summaryQuery.where(
        'billEntryDate',
        isGreaterThanOrEqualTo: startStr,
      );
    }
    if (endDate != null) {
      summaryQuery = summaryQuery.where(
        'billEntryDate',
        isLessThanOrEqualTo: endStr,
      );
    }

    final summarySnapshot = await summaryQuery.get();
    final salesIds = summarySnapshot.docs.map((e) => e.id).toList();

    // Step 3: Filter sales_details with itemId & salesId
    final detailsSnapshot = await db
        .collection('sales_details')
        .where('companyId', isEqualTo: companyId)
        .get();

    final filteredDetails = detailsSnapshot.docs
        .where((doc) {
          final data = doc.data();
          return itemIds.contains(data['itemId']) &&
              salesIds.contains(data['salesId']);
        })
        .map((doc) => doc.data())
        .toList();

    return filteredDetails;
  }
}
