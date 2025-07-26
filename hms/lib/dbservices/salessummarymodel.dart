import 'package:sembast/timestamp.dart';

class SalesSummary {
  final int salesId;
  final String productName;
  final double totalSales;
  final DateTime date;

  SalesSummary({
    required this.salesId,
    required this.productName,
    required this.totalSales,
    required this.date,
  });

  // Define the fromMap method
  factory SalesSummary.fromMap(Map<String, dynamic> map) {
    return SalesSummary(
      salesId: map['salesId'],
      productName: map['productName'],
      totalSales: map['totalSales'],
      date:
          (map['date'] as Timestamp)
              .toDateTime(), // If using Firestore Timestamp
    );
  }

  // If you need to convert back to a map, you can also define a toMap method
  Map<String, dynamic> toMap() {
    return {
      'salesId': salesId,
      'productName': productName,
      'totalSales': totalSales,
      'date': date,
    };
  }
}
