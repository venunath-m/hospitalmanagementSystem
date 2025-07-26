class SalesReturnSummary {
  final String salesReturnId;
  final String customerId;
  final String customerName;
  final double returnAmount;
  final double taxAmount;
  final String returnDate;
  final double grandTotal;

  SalesReturnSummary({
    required this.salesReturnId,
    required this.customerId,
    required this.customerName,
    required this.returnAmount,
    required this.taxAmount,
    required this.returnDate,
    required this.grandTotal,
  });

  factory SalesReturnSummary.fromMap(Map<String, dynamic> data) {
    return SalesReturnSummary(
      salesReturnId: data['salesReturnId'],
      customerId: data['customerId'],
      customerName: data['customerName'],
      returnAmount: data['returnAmount'],
      taxAmount: data['taxAmount'],
      returnDate: data['returnDate'],
      grandTotal: data['grandTotal'],
    );
  }
}

class SalesReturnDetail {
  final String itemName;
  final double price;
  final int quantity;
  final double taxAmount;
  final double itemTotalAmount;
  final double taxPercentage;
  final String reason;

  SalesReturnDetail({
    required this.itemName,
    required this.price,
    required this.quantity,
    required this.taxAmount,
    required this.itemTotalAmount,
    required this.taxPercentage,
    required this.reason,
  });

  factory SalesReturnDetail.fromMap(Map<String, dynamic> data) {
    return SalesReturnDetail(
      itemName: data['itemName'],
      price: data['price'],
      quantity: data['quantity'],
      taxAmount: data['taxAmount'],
      itemTotalAmount: data['itemTotalAmount'],
      taxPercentage: data['taxPercentage'],
      reason: data['reason'],
    );
  }
}
