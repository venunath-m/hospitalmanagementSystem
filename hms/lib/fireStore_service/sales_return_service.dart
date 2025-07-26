import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hms/dbservices/salesReturnModel.dart';
import 'package:hms/dbservices/salesReturnReportModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesReturnService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  Future<List<SalesReturn>> fetchPendingReturns() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception("Company ID not found.");

      final snapshot = await _db
          .collection('sales_return')
          .where('companyId', isEqualTo: companyId)
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs.map((doc) {
        return SalesReturn.fromMap({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      debugPrint("Error fetching pending returns: $e");
      return [];
    }
  }

  Future<String> addSalesReturn(Map<String, dynamic> returnData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      if (companyId == null) throw Exception("Company ID not found.");

      returnData['companyId'] = companyId;
      returnData['userId'] = user.uid;

      final docRef = await _db.collection('sales_return').add(returnData);
      return docRef.id;
    } catch (e) {
      throw Exception("Failed to add sales return: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getSalesReturnPage({
    required DateTime startDate,
    required DateTime endDate,
    required int offset,
    required int limit,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception("Company ID not found.");

      final querySnapshot = await _db
          .collection('sales_return')
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

      final pagedDocs = querySnapshot.docs.skip(offset).take(limit);

      return pagedDocs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception("Failed to fetch sales return page: $e");
    }
  }

  Future<int> countSalesReturnInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception("Company ID not found.");

      final snapshot = await _db
          .collection('sales_return')
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

      return snapshot.docs.length;
    } catch (e) {
      throw Exception("Failed to count sales return: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAllSalesReturns() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception("Company ID not found.");

      final snapshot = await _db
          .collection('sales_return')
          .where('companyId', isEqualTo: companyId)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception("Failed to get all sales returns: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getSalesReturnSortedByDate() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception("Company ID not found.");

      final snapshot = await _db
          .collection('sales_return')
          .where('companyId', isEqualTo: companyId)
          .orderBy('billEntryDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception("Failed to fetch sorted sales returns: $e");
    }
  }

  Future<double> getTotalSalesReturnAmount() async {
    double totalReturn = 0;

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception("Company ID not found.");

      final snapshot = await _db
          .collection('sales_return')
          .where('companyId', isEqualTo: companyId)
          .get();

      for (var doc in snapshot.docs) {
        totalReturn += doc.data()['returnAmount']?.toDouble() ?? 0.0;
      }

      return totalReturn;
    } catch (e) {
      throw Exception("Failed to calculate total sales return: $e");
    }
  }

  Future<List<SalesReturnSummary>> fetchSalesReturnSummaries({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null)
        throw Exception('Company ID not found in preferences.');

      final querySnapshot = await _db
          .collection('sales_return')
          .where('companyId', isEqualTo: companyId)
          .where(
            'returnDate',
            isGreaterThanOrEqualTo: startDate.toIso8601String(),
          )
          .where('returnDate', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('returnDate', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                SalesReturnSummary.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e, stacktrace) {
      print('Error fetching sales return summaries: $e');
      print(stacktrace);
      rethrow;
    }
  }

  // Fetch sales return details by salesReturnId and companyId
  Future<List<SalesReturnDetail>> fetchSalesReturnDetails(
    String salesReturnId,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null)
        throw Exception('Company ID not found in preferences.');

      final querySnapshot = await _db
          .collection('sales_return_details')
          .where('salesReturnId', isEqualTo: salesReturnId)
          .where('companyId', isEqualTo: companyId) // filter by companyId
          .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                SalesReturnDetail.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e, stacktrace) {
      print('Error fetching sales return details: $e');
      print(stacktrace);
      rethrow;
    }
  }
}
