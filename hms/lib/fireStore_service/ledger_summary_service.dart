import 'package:cloud_firestore/cloud_firestore.dart';

class LedgerSummaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generic method to fetch daily totals for credit and debit
  Future<Map<String, List<DailyLedger>>> getWeeklySummary({
    required String collection,
    required String companyId,
  }) async {
    DateTime today = DateTime.now();
    DateTime weekAgo = today.subtract(Duration(days: 6));
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection(collection)
              .where('companyId', isEqualTo: companyId)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo),
              )
              .orderBy('date')
              .get();

      Map<DateTime, double> dailyCredits = {};
      Map<DateTime, double> dailyDebits = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        DateTime date = (data['date'] as Timestamp).toDate();
        DateTime day = DateTime(date.year, date.month, date.day);

        double credit = (data['credit'] ?? 0).toDouble();
        double debit = (data['debit'] ?? 0).toDouble();

        dailyCredits[day] = (dailyCredits[day] ?? 0) + credit;
        dailyDebits[day] = (dailyDebits[day] ?? 0) + debit;
      }

      // Fill missing days with 0
      for (int i = 0; i < 7; i++) {
        DateTime day = DateTime(
          today.year,
          today.month,
          today.day,
        ).subtract(Duration(days: i));
        dailyCredits.putIfAbsent(day, () => 0);
        dailyDebits.putIfAbsent(day, () => 0);
      }

      // Convert to sorted lists
      List<DailyLedger> credits =
          dailyCredits.entries.map((e) => DailyLedger(e.key, e.value)).toList()
            ..sort((a, b) => a.date.compareTo(b.date));

      List<DailyLedger> debits =
          dailyDebits.entries.map((e) => DailyLedger(e.key, e.value)).toList()
            ..sort((a, b) => a.date.compareTo(b.date));

      return {'credit': credits, 'debit': debits};
    } catch (e, stack) {
      print('Error fetching $collection: $e');
      throw e;
    }
  }
}

class DailyLedger {
  final DateTime date;
  final double amount;
  DailyLedger(this.date, this.amount);
}
