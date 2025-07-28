import 'package:flutter/material.dart';
import 'package:hms/views/pages/pharmacy/customer/PharmacyCustomerFormPage.dart';

class PharmacyCustomerListPage extends StatelessWidget {
  const PharmacyCustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PharmacyCustomerFormPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Customer',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Replace with customer list length
              itemBuilder: (context, index) {
                return ListTile(
                  title: const Text("Customer Name"),
                  subtitle: const Text("Phone: 9876543210"),
                  trailing: const Text("₹ 250"), // Outstanding
                  onTap: () {
                    // Optionally navigate to detail/edit
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
