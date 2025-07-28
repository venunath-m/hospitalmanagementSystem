import 'package:flutter/material.dart';

class PharmacyCustomerFormPage extends StatelessWidget {
  const PharmacyCustomerFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add / Edit Customer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Customer Name'),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Email (optional)'),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Address'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Save customer
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
