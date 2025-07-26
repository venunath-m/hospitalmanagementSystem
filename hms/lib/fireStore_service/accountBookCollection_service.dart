import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class AccountBookCollectionService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> getAccountBalances() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception('companyId not found');

      final firestore = await _firestoreService.firestoreInstance;
      final accountBookSnapshot =
          await firestore
              .collection('account_book')
              .where('companyId', isEqualTo: companyId)
              .get();

      final accountHeadSnapshot =
          await firestore
              .collection('account_heads')
              .where('companyId', isEqualTo: companyId)
              .get();

      final Map<int, String> accountHeadMap = {};
      for (var doc in accountHeadSnapshot.docs) {
        final data = doc.data();
        final accountId =
            int.tryParse(data['accountId']?.toString() ?? '-1') ?? -1;
        final headName = data['headName']?.toString() ?? 'Unknown';
        accountHeadMap[accountId] = headName;
      }

      final Map<String, Map<String, dynamic>> balances = {};
      final now = DateTime.now();

      for (var doc in accountBookSnapshot.docs) {
        final data = doc.data();
        final accountId =
            int.tryParse(data['accountId']?.toString() ?? '-1') ?? -1;
        final headName = accountHeadMap[accountId] ?? 'Unknown';
        final credit = (data['credit'] as num?) ?? 0;
        final debit = (data['debit'] as num?) ?? 0;
        final transactionType = data['transactionType']?.toString() ?? '';
        final transactionDate = DateTime.tryParse(
          data['accountingDate']?.toString() ?? '',
        );

        balances[headName] ??= {
          'headName': headName,
          'totalCredit': 0.0,
          'totalDebit': 0.0,
          'openingBalance': 0.0,
          'closingBalance': 0.0,
        };

        final balance = balances[headName]!;

        if (transactionDate != null && transactionDate.isBefore(now)) {
          if (transactionType == 'Credit') {
            balance['openingBalance'] =
                (balance['openingBalance'] as num) + credit;
          } else if (transactionType == 'Debit') {
            balance['openingBalance'] =
                (balance['openingBalance'] as num) - debit;
          }
        }

        if (transactionType == 'Credit') {
          balance['totalCredit'] = (balance['totalCredit'] as num) + credit;
        } else if (transactionType == 'Debit') {
          balance['totalDebit'] = (balance['totalDebit'] as num) + debit;
        }
      }

      for (var entry in balances.values) {
        entry['closingBalance'] =
            (entry['openingBalance'] as num) +
            (entry['totalCredit'] as num) -
            (entry['totalDebit'] as num);
      }

      return balances.values.toList();
    } catch (e, stackTrace) {
      debugPrint('Error fetching account balances: $e');
      debugPrint('StackTrace: $stackTrace');
      return [];
    }
  }

  Future<String?> addAccountBookEntry(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception('companyId not found');
      final logsCollection = _firestoreService.logsCollection;
      final firestore = await _firestoreService.firestoreInstance;
      data['companyId'] = companyId;
      data['userId'] = user.uid;

      final docRef = await firestore.collection('account_book').add(data);
      await logsCollection.add({
        'itemId': docRef.id,
        'oldData': null,
        'newData': {...data, 'id': docRef.id},
        'action': 'CREATE',
        'actionType': 'Account Book Entry',
        'createdBy': user.uid,
        'updatedBy': user.uid,
        'updatedByEmail': user.email,
        'companyId': companyId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id; // return the auto-generated document ID
    } catch (e) {
      debugPrint("Error adding Account Book entry: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAccountBookEntries() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception('companyId not found');

      final firestore = await _firestoreService.firestoreInstance;

      final accountBookSnapshot =
          await firestore
              .collection('account_book')
              .where('companyId', isEqualTo: companyId)
              .get();

      final accountHeadSnapshot =
          await firestore
              .collection('account_heads')
              .where('companyId', isEqualTo: companyId)
              .get();

      final Map<int, String> accountHeadMap = {
        for (var doc in accountHeadSnapshot.docs)
          int.tryParse(doc.data()['accountId']?.toString() ?? '-1') ?? -1:
              doc.data()['headName']?.toString() ?? 'Unknown',
      };

      return accountBookSnapshot.docs.map((doc) {
        final data = doc.data();
        final accountId =
            int.tryParse(data['accountId']?.toString() ?? '-1') ?? -1;
        final headName = accountHeadMap[accountId] ?? 'Unknown';

        return {'id': doc.id, ...data, 'headName': headName};
      }).toList();
    } catch (e) {
      debugPrint("Error fetching Account Book entries: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAccountBookEntriesNew() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception('companyId not found');

      final firestore = await _firestoreService.firestoreInstance;
      final snapshot =
          await firestore
              .collection('account_book')
              .where('companyId', isEqualTo: companyId)
              .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      debugPrint("Error fetching Account Book entries (New): $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllAccountBookEntries() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId == null) throw Exception('companyId not found');

      final firestore = await _firestoreService.firestoreInstance;
      final snapshot =
          await firestore
              .collection('account_book')
              .where('companyId', isEqualTo: companyId)
              .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      debugPrint("Error fetching all Account Book entries: $e");
      return [];
    }
  }
}
