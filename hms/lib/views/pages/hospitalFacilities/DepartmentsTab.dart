import 'package:flutter/material.dart';

class DepartmentsTab extends StatefulWidget {
  const DepartmentsTab({super.key});

  @override
  State<DepartmentsTab> createState() => _DepartmentsTabState();
}

class _DepartmentsTabState extends State<DepartmentsTab> {
  final TextEditingController _deptController = TextEditingController();
  final List<String> departments = [];

  void _addDepartment() {
    if (_deptController.text.trim().isNotEmpty) {
      setState(() {
        departments.add(_deptController.text.trim());
        _deptController.clear();
      });
      // Save to DB here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          elevation: 4,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _deptController,
                  decoration: const InputDecoration(
                    labelText: 'Add Department Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addDepartment,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Department'),
                  ),
                ),
                const SizedBox(height: 20),
                if (departments.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Departments List',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: departments.length,
                          itemBuilder: (context, index) => ListTile(
                            leading: const Icon(Icons.local_hospital),
                            title: Text(departments[index]),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
