import 'package:flutter/material.dart';

class MedicineStockPage extends StatelessWidget {
  const MedicineStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine Stock Management"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Add Stock Page
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search by medicine or batch...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Table header
            Container(
              color: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: Text("Medicine")),
                  Expanded(flex: 2, child: Text("Batch")),
                  Expanded(flex: 1, child: Text("Exp.")),
                  Expanded(flex: 1, child: Text("In")),
                  Expanded(flex: 1, child: Text("Out")),
                  Expanded(flex: 1, child: Text("Current")),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Stock list items (demo)
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Replace with actual stock list
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: const [
                          Expanded(flex: 2, child: Text("Paracetamol")),
                          Expanded(flex: 2, child: Text("B23-001")),
                          Expanded(flex: 1, child: Text("12/2025")),
                          Expanded(flex: 1, child: Text("500")),
                          Expanded(flex: 1, child: Text("200")),
                          Expanded(flex: 1, child: Text("300")),
                        ],
                      ),
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
