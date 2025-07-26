import 'package:hms/service_utilities/enums_utils.dart';
import 'package:flutter/material.dart';

class GlobalToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    bool showCloseButton = false,
  }) {
    final colorData = _toastColorAndIcon(type);

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (ctx) => _ToastWidget(
        message: message,
        backgroundColor: colorData.backgroundColor,
        icon: colorData.icon,
        iconColor: colorData.iconColor,
        showCloseButton: showCloseButton,
      ),
    );

    overlay?.insert(overlayEntry);

    Future.delayed(duration).then((_) {
      overlayEntry.remove();
    });
  }

  static _ToastColorIcon _toastColorAndIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastColorIcon(
          backgroundColor: Colors.green.shade700,
          icon: Icons.check_circle,
          iconColor: Colors.white,
        );
      case ToastType.error:
        return _ToastColorIcon(
          backgroundColor: Colors.red.shade700,
          icon: Icons.error,
          iconColor: Colors.white,
        );
      case ToastType.warning:
        return _ToastColorIcon(
          backgroundColor: Colors.orange.shade700,
          icon: Icons.warning,
          iconColor: Colors.white,
        );
      case ToastType.info:
      default:
        return _ToastColorIcon(
          backgroundColor: Colors.blue.shade700,
          icon: Icons.info,
          iconColor: Colors.white,
        );
    }
  }
}

class _ToastColorIcon {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;

  _ToastColorIcon({
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
  });
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final bool showCloseButton;

  const _ToastWidget({
    Key? key,
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    this.showCloseButton = false,
  }) : super(key: key);

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeToast() {
    _controller.reverse().then((value) {
      if (mounted) {
        Overlay.of(context)?.dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 20;

    return Positioned(
      bottom: bottomPadding,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: widget.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              children: [
                Icon(widget.icon, color: widget.iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                if (widget.showCloseButton)
                  GestureDetector(
                    onTap: _closeToast,
                    child: Icon(Icons.close, color: widget.iconColor),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
