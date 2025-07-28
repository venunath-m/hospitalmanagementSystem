import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class ServicesTab extends StatefulWidget {
  const ServicesTab({super.key});

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  final TextEditingController _serviceController = TextEditingController();
  final List<String> services = [];

  void _addService() {
    if (_serviceController.text.trim().isNotEmpty) {
      setState(() {
        services.add(_serviceController.text.trim());
        _serviceController.clear();
      });
      // TODO: Save to DB here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Hospital Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _serviceController,
                  decoration: const InputDecoration(
                    labelText: 'Add Service (e.g., MRI, Lab Test)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addService,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Service'),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: services.isEmpty
                      ? const Center(
                          child: Text(
                            'No services added yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : CustomPaginatedTable(
                          columns: const [
                            DataColumn(label: Text('Service')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: List.generate(services.length, (index) {
                            final service = services[index];
                            return DataRow(
                              cells: [
                                DataCell(Text(service)),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      // Remove service on delete pressed
                                      setState(() {
                                        services.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            );
                          }),
                          currentPage: 0,
                          totalPages: 1,
                          onNextPage: null,
                          onPreviousPage: null,
                          isLoading: false,
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
