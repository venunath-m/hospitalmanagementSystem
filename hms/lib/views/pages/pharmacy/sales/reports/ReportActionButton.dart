import 'package:flutter/material.dart';

class ReportActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const ReportActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 32),
      label: Text(title, style: const TextStyle(fontSize: 14)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 1.5,
        minimumSize: const Size(100, 36), // control button height/width
      ),
    );
  }
}
