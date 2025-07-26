import 'package:flutter/material.dart';

class BackgroundSelectorService {
  static Future<String?> showBackgroundSelector(
    BuildContext context,
    List<String> backgroundOptions,
  ) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Background'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: backgroundOptions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final bg = backgroundOptions[index];
              return GestureDetector(
                onTap: () => Navigator.pop(ctx, bg),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(bg, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
