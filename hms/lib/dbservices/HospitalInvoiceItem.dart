class InvoiceItem {
  final String description;
  final double cost;

  InvoiceItem({required this.description, required this.cost});
}

class Invoice {
  final List<InvoiceItem> items;
  final double insuranceCoveragePercent;
  final double discountAmount;
  final double taxPercent;

  Invoice({
    required this.items,
    this.insuranceCoveragePercent = 0,
    this.discountAmount = 0,
    this.taxPercent = 0,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.cost);

  double get insuranceDiscount => subtotal * (insuranceCoveragePercent / 100);

  double get totalAfterInsurance => subtotal - insuranceDiscount;

  double get totalAfterDiscount => totalAfterInsurance - discountAmount;

  double get tax => totalAfterDiscount * (taxPercent / 100);

  double get totalPayable => totalAfterDiscount + tax;
}
