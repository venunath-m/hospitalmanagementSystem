import 'package:flutter/material.dart';

class RoomsTab extends StatefulWidget {
  const RoomsTab({super.key});

  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  final TextEditingController _roomController = TextEditingController();
  String? selectedDept;
  final Map<String, List<String>> deptRooms = {};

  void _addRoom() {
    if (_roomController.text.trim().isNotEmpty && selectedDept != null) {
      setState(() {
        deptRooms.putIfAbsent(selectedDept!, () => []);
        deptRooms[selectedDept!]!.add(_roomController.text.trim());
        _roomController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final departments = [
      'Cardiology',
      'Neurology',
      'Pediatrics',
      'Orthopedics',
    ]; // Ideally fetched from DB

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
                DropdownButtonFormField<String>(
                  value: selectedDept,
                  hint: const Text('Select Department'),
                  items: departments
                      .map(
                        (dept) =>
                            DropdownMenuItem(value: dept, child: Text(dept)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => selectedDept = value),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _roomController,
                  decoration: const InputDecoration(
                    labelText: 'Add Room Number',
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
                    onPressed: _addRoom,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Room'),
                  ),
                ),
                const SizedBox(height: 20),
                if (deptRooms.isNotEmpty)
                  Expanded(
                    child: ListView(
                      children: deptRooms.entries.map((entry) {
                        return ExpansionTile(
                          title: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          children: entry.value
                              .map(
                                (room) => ListTile(
                                  leading: const Icon(Icons.meeting_room),
                                  title: Text('Room: $room'),
                                ),
                              )
                              .toList(),
                        );
                      }).toList(),
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
