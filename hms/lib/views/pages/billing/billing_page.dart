import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy billing data - replace with real billing info later
    final List<Map<String, String>> bills = [
      {
        'invoice': 'INV001',
        'patient': 'John Doe',
        'amount': '\$200',
        'status': 'Paid',
      },
      {
        'invoice': 'INV002',
        'patient': 'Jane Smith',
        'amount': '\$350',
        'status': 'Pending',
      },
      {
        'invoice': 'INV003',
        'patient': 'Alice Johnson',
        'amount': '\$150',
        'status': 'Paid',
      },
    ];

    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'Billing'),
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Billing Records',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to billing creation form
              },
              child: const Text('Create New Bill'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text('Invoice: ${bill['invoice']}'),
                      subtitle: Text(
                        'Patient: ${bill['patient']} - Amount: ${bill['amount']}',
                      ),
                      trailing: Text(
                        bill['status']!,
                        style: TextStyle(
                          color: bill['status'] == 'Paid'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        // TODO: Show bill details or edit
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
