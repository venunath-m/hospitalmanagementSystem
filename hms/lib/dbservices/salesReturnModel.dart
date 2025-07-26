class SalesReturn {
  final String id;
  final String companyId;
  final String billEntryDate;
  final double returnAmount;
  final String status;

  SalesReturn({
    required this.id,
    required this.companyId,
    required this.billEntryDate,
    required this.returnAmount,
    required this.status,
  });

  factory SalesReturn.fromMap(Map<String, dynamic> data) {
    return SalesReturn(
      id: data['id'] ?? '',
      companyId: data['companyId'] ?? '',
      billEntryDate: data['billEntryDate'] ?? '',
      returnAmount: data['returnAmount']?.toDouble() ?? 0.0,
      status: data['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'billEntryDate': billEntryDate,
      'returnAmount': returnAmount,
      'status': status,
    };
  }
}
