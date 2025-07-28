import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'Settings', showBackButton: true),
      scrollable: false,
      child: const Center(
        child: Text(
          'Settings Page Content Here',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
