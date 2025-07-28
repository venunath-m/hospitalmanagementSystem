import 'package:flutter/material.dart';

class DetailTile extends StatelessWidget {
  final String title;
  final String value;

  const DetailTile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }
}
