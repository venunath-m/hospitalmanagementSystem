import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'Appointments'),
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Manage your appointments here',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Add your booking logic or navigate to booking screen
              },
              child: const Text('Book New Appointment'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Appointment with Dr. Smith'),
                    subtitle: Text('Date: 2025-08-01, 10:00 AM'),
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Appointment with Dr. Lee'),
                    subtitle: Text('Date: 2025-08-03, 02:00 PM'),
                  ),
                  // Add more dummy or dynamic appointments here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
