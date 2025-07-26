import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hms/fireStore_service/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesReturnCollectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  CollectionReference get salesReturnCollection =>
      _firestore.collection('sales_return');
  CollectionReference get salesReturnDetailsCollection =>
      _firestore.collection('sales_return_details');

  Future<String> addSalesReturnSummary(Map<String, dynamic> returnData) async {
    final logsCollection = _firestoreService.logsCollection;
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyId');
    if (companyId == null) throw Exception("Company ID not found");

    returnData['companyId'] = companyId;
    final docRef = await salesReturnCollection.add(returnData);
    await logsCollection.add({
      'itemId': docRef.id,
      'oldData': null,
      'newData': {...returnData, 'id': docRef.id},
      'action': 'CREATE',
      'actionType': 'Sales Return Summary',
      'createdBy': user.uid,
      'updatedBy': user.uid,
      'updatedByEmail': user.email,
      'companyId': companyId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Future<void> addSalesReturnDetail(Map<String, dynamic> detailData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyId');
    if (companyId == null) throw Exception("Company ID not found");

    detailData['companyId'] = companyId;
    await salesReturnDetailsCollection.add(detailData);
  }

  Future<List<Map<String, dynamic>>> getSalesReturnDetailsByReturnId(
    String returnId,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyId');
    if (companyId == null) throw Exception("Company ID not found");

    final querySnapshot = await salesReturnDetailsCollection
        .where('returnId', isEqualTo: returnId)
        .where('companyId', isEqualTo: companyId)
        .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }
}
