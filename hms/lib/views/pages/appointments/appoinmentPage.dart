import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/views/pages/appointments/AppointmentBookingPage.dart';
import 'package:hms/views/pages/appointments/AppointmentListingPage.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'Appointments'),
      scrollable: false,
      child: Column(
        children: [
          Container(
            color: Colors.red.shade800,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Book Appointment'),
                Tab(text: 'Appointment List'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Just widgets here — no Scaffold or AppBar inside
                AppointmentBookingPage(),
                AppointmentListingPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
