import 'package:flutter/material.dart';

class BlockWardBedsTab extends StatelessWidget {
  const BlockWardBedsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final bedController = TextEditingController();

    return Center(
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Block Ward Bed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bedController,
                  decoration: const InputDecoration(
                    labelText: 'Bed/Ward Number to Block',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final bed = bedController.text.trim();
                      if (bed.isNotEmpty) {
                        // Save to DB
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Blocked bed: $bed')),
                        );
                      }
                    },
                    child: const Text('Block Bed'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
