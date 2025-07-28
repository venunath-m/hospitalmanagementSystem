import 'package:flutter/material.dart';

class PharmacySettingsPage extends StatelessWidget {
  const PharmacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings / Configuration'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "General"),
              Tab(text: "Tax/Discount"),
              Tab(text: "Printing"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            GeneralSettingsTab(),
            TaxDiscountSettingsTab(),
            PrintingSettingsTab(),
          ],
        ),
      ),
    );
  }
}

class GeneralSettingsTab extends StatelessWidget {
  const GeneralSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: const [
          TextField(decoration: InputDecoration(labelText: 'Pharmacy Name')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Invoice Prefix')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Contact Number')),
        ],
      ),
    );
  }
}

class TaxDiscountSettingsTab extends StatelessWidget {
  const TaxDiscountSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: const [
          TextField(
            decoration: InputDecoration(labelText: 'Default Tax %'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(labelText: 'Default Discount %'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

class PrintingSettingsTab extends StatelessWidget {
  const PrintingSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          TextField(
            decoration: InputDecoration(labelText: 'Print Footer Message'),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
