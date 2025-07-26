import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? textColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.showBackButton = true,
    this.textColor,
    this.iconColor,
    this.backgroundColor,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkBackground = themeProvider.isDarkBackground;

    final theme = Theme.of(context);
    final appBrightness = theme.brightness;

    // Decide if we need light foreground
    final useLightForeground =
        appBrightness == Brightness.dark || isDarkBackground;

    final effectiveTextColor =
        textColor ?? (useLightForeground ? Colors.white : Colors.black87);
    final effectiveIconColor =
        iconColor ?? (useLightForeground ? Colors.white : Colors.black87);
    final effectiveBackgroundColor = backgroundColor ?? Colors.transparent;

    return AppBar(
      backgroundColor: effectiveBackgroundColor,
      elevation: theme.appBarTheme.elevation ?? 0.0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,

      leading: Builder(
        builder: (context) {
          if (scaffoldKey != null && scaffoldKey!.currentState != null) {
            return IconButton(
              icon: Icon(Icons.menu, color: effectiveIconColor),
              onPressed: () => scaffoldKey!.currentState!.openDrawer(),
            );
          }

          if (Scaffold.of(context).hasDrawer) {
            return IconButton(
              icon: Icon(Icons.menu, color: effectiveIconColor),
              onPressed: () {
                scaffoldKey?.currentState?.openDrawer();
              },
            );
          }

          if (showBackButton) {
            return BackButton(color: effectiveIconColor);
          }

          return Container();
        },
      ),

      iconTheme: IconThemeData(color: effectiveIconColor),
      title: Text(
        title,
        style:
            theme.appBarTheme.titleTextStyle?.copyWith(
              color: effectiveTextColor,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.7),
                  blurRadius: 4,
                  offset: Offset(1, 1),
                ),
              ],
            ) ??
            TextStyle(
              color: effectiveTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.7),
                  blurRadius: 4,
                  offset: Offset(1, 1),
                ),
              ],
            ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
