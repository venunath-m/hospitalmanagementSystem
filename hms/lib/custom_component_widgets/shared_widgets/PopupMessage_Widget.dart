import 'package:flutter/material.dart';

class PopupMessage {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.info_outline,
    Color iconColor = Colors.blue,
    Color backgroundColor = Colors.white,
    Duration duration = const Duration(seconds: 5),
    List<PopupActionButton>? actionButtons,
    bool autoDismiss = true,
  }) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Popup Message",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              width: MediaQuery.of(ctx).size.width * 0.85,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: iconColor, size: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: iconColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(message, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  if (actionButtons != null && actionButtons.isNotEmpty) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actionButtons
                          .map(
                            (btn) => Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ElevatedButton.icon(
                                icon: Icon(btn.icon),
                                label: Text(btn.label),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  btn.onPressed?.call();
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(anim1),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );

    if (autoDismiss) {
      await Future.delayed(duration);
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}

class PopupActionButton {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  PopupActionButton({required this.label, required this.icon, this.onPressed});
}

  //Example usage:
  // await PopupMessage.show(
  //   context,
  //   title: "Invoice Created",
  //   message: "Your invoice has been successfully created.",
  //   icon: Icons.check_circle_outline,
  //   iconColor: Colors.green,
  //   actionButtons: [
  //     PopupActionButton(
  //       label: "Print",
  //       icon: Icons.print,
  //       onPressed: () {
  //         // Call your print logic here
  //       },
  //     ),
  //     PopupActionButton(
  //       label: "Back",
  //       icon: Icons.arrow_back,
  //       onPressed: () {
  //         Navigator.of(context).pop();
  //       },
  //     ),
  //   ],
  //   autoDismiss: false, // Let user close manually after action
  // );
