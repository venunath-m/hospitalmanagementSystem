import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/views/pages/hospitalFacilities/BlockWardBedsTab.dart';
import 'package:hms/views/pages/hospitalFacilities/DepartmentsTab.dart';
import 'package:hms/views/pages/hospitalFacilities/RoomsTab.dart';
import 'package:hms/views/pages/hospitalFacilities/ServicesTab.dart';

class HospitalFacilitiesPage extends StatefulWidget {
  const HospitalFacilitiesPage({super.key});

  @override
  State<HospitalFacilitiesPage> createState() => _HospitalFacilitiesPageState();
}

class _HospitalFacilitiesPageState extends State<HospitalFacilitiesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'Hospital Facilities Setup'),
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
                Tab(text: 'Departments'),
                Tab(text: 'Rooms'),
                Tab(text: 'Ward Beds'),
                Tab(text: 'Services'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Just widgets here — no Scaffold or AppBar inside
                DepartmentsTab(),
                RoomsTab(),
                BlockWardBedsTab(),
                ServicesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
