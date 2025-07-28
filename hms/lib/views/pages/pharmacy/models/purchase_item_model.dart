// purchase_item_model.dart
class PurchaseItemModel {
  String medicineName;
  String hsnCode;
  double quantity;
  double rate;
  double saleRate;
  String batchNo;
  DateTime expiryDate;
  double taxPercent;
  bool taxInclusive;

  PurchaseItemModel({
    required this.medicineName,
    required this.hsnCode,
    required this.quantity,
    required this.rate,
    required this.saleRate,
    required this.batchNo,
    required this.expiryDate,
    required this.taxPercent,
    this.taxInclusive = false,
  });

  double get marginPercent {
    if (rate == 0) return 0;
    return ((saleRate - rate) / rate) * 100;
  }

  double get subTotal {
    // If tax is inclusive, rate includes tax
    if (taxInclusive) {
      return quantity * (rate / (1 + taxPercent / 100));
    } else {
      return quantity * rate;
    }
  }

  double get taxAmount {
    if (taxInclusive) {
      return quantity * rate - subTotal;
    } else {
      return subTotal * (taxPercent / 100);
    }
  }

  double get totalAmount => subTotal + taxAmount;

  // For JSON serialization if needed
  Map<String, dynamic> toJson() => {
    'medicineName': medicineName,
    'hsnCode': hsnCode,
    'quantity': quantity,
    'rate': rate,
    'saleRate': saleRate,
    'batchNo': batchNo,
    'expiryDate': expiryDate.toIso8601String(),
    'taxPercent': taxPercent,
    'taxInclusive': taxInclusive,
  };

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      medicineName: json['medicineName'],
      hsnCode: json['hsnCode'],
      quantity: json['quantity'],
      rate: json['rate'],
      saleRate: json['saleRate'],
      batchNo: json['batchNo'],
      expiryDate: DateTime.parse(json['expiryDate']),
      taxPercent: json['taxPercent'],
      taxInclusive: json['taxInclusive'],
    );
  }
}
