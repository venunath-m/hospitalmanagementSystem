import 'package:flutter/material.dart';

class SaleDetailPage extends StatelessWidget {
  final String patientName;
  final String patientType;
  final String? ward;
  final String? bed;
  final String? patientId;
  final String billingType;
  final String? insuranceType;
  final String? insuranceNumber;
  final DateTime saleDate;
  final List<Map<String, dynamic>> salesItems;
  final double totalAmount;

  const SaleDetailPage({
    Key? key,
    required this.patientName,
    required this.patientType,
    this.ward,
    this.bed,
    this.patientId,
    required this.billingType,
    this.insuranceType,
    this.insuranceNumber,
    required this.saleDate,
    required this.salesItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Details'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient & sale info
            Text(
              'Patient: $patientName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Type: $patientType'),
            if (patientType == 'Inpatient') ...[
              Text('Ward: ${ward ?? '-'}'),
              Text('Bed: ${bed ?? '-'}'),
              Text('Patient ID: ${patientId ?? '-'}'),
            ],
            Text('Billing Type: $billingType'),
            if (insuranceType != null && insuranceType != 'None') ...[
              Text('Insurance: $insuranceType'),
              Text('Insurance No: ${insuranceNumber ?? '-'}'),
            ],
            Text('Date: ${saleDate.toLocal().toString().split(' ')[0]}'),
            const Divider(height: 30, thickness: 2),

            // Items header
            const Text(
              'Items:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Items list
            Expanded(
              child: ListView.separated(
                itemCount: salesItems.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = salesItems[index];
                  final qty = item['qty'] as double;
                  final rate = item['rate'] as double;
                  final tax = item['tax'] as double;
                  final subTotal = qty * rate;
                  final taxAmt = subTotal * tax / 100;
                  final total = subTotal + taxAmt;

                  return ListTile(
                    title: Text(item['medicine']),
                    subtitle: Text('Qty: $qty, Rate: ₹$rate, Tax: $tax%'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Subtotal: ₹${subTotal.toStringAsFixed(2)}'),
                        Text('Tax: ₹${taxAmt.toStringAsFixed(2)}'),
                        Text(
                          'Total: ₹${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(thickness: 2),

            // Grand total
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Grand Total: ₹${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Call print PDF method here
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add share logic if needed
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
