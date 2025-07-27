import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48, // fixed height
      color: Colors.black.withOpacity(0.1),
      padding: const EdgeInsets.all(12),
      child: const Center(
        child: Text(
          "© 2025 Hospital Management System. All rights reserved.",
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
