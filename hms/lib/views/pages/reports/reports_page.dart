import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'Reports', showBackButton: true),
      scrollable: false,
      child: const Center(
        child: Text(
          'Reports Page Content Here',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
