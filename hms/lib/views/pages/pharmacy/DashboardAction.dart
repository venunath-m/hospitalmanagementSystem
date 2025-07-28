import 'package:flutter/material.dart';

class DashboardAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardAction({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        shadowColor: Colors.red.shade800,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade100, Colors.indigo.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                radius: 24,
                child: Icon(icon, size: 28, color: Colors.indigo.shade900),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
