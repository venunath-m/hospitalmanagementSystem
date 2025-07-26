import 'package:flutter/material.dart';

class GradientBackgroundWrapper extends StatelessWidget {
  final Widget child;

  const GradientBackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF), // White
            Color(0xFFE0FFFF), // Light Cyan
            Color(0xFFAFEEEE), // Pale Turquoise
            Color(0xFF7FFFD4), // Aquamarine
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
