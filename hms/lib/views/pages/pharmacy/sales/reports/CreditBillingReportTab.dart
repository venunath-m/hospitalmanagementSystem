import 'package:flutter/material.dart';

class CreditBillingReportTab extends StatelessWidget {
  const CreditBillingReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample credit billing data - inpatients with pending bills
    final creditBillings = [
      {
        'patientName': 'John Doe',
        'admissionDate': DateTime(2025, 7, 20),
        'totalCredit': 5000.0,
        'dueDate': DateTime(2025, 8, 5),
      },
      {
        'patientName': 'Jane Smith',
        'admissionDate': DateTime(2025, 7, 22),
        'totalCredit': 3500.0,
        'dueDate': DateTime(2025, 8, 10),
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Credit Billing Report (Inpatients)',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.separated(
              itemCount: creditBillings.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = creditBillings[index];
                final admissionDate = item['admissionDate'] as DateTime;
                final dueDate = item['dueDate'] as DateTime;

                return ListTile(
                  leading: const Icon(
                    Icons.credit_card,
                    color: Colors.deepOrange,
                  ),
                  title: Text(item['patientName'].toString()),
                  subtitle: Text(
                    'Admission: ${admissionDate.toLocal().toString().split(' ')[0]}  |  Due: ${dueDate.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: Text(
                    '₹${(item['totalCredit'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
