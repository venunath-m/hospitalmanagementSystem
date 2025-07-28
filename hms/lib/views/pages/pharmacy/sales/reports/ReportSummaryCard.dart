import 'package:flutter/material.dart';

class ReportSummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final Color color;

  const ReportSummaryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
