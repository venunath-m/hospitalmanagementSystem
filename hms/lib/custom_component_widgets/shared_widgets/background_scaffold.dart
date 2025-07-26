import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BackgroundScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;
  final bool scrollable;
  final GlobalKey<ScaffoldState>? scaffoldKey; // <-- Add this

  const BackgroundScaffold({
    Key? key,
    required this.child,
    this.appBar,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
    this.scrollable = true,
    this.scaffoldKey, // <-- Add this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkBackground;
    final bg = context.watch<ThemeProvider>().selectedBackground;

    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      drawerDragStartBehavior: DragStartBehavior.start,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: bg != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(bg),
                  fit: BoxFit.cover,
                ),
              )
            : null,
        child: SafeArea(
          child: scrollable
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _ThemedContent(isDark: isDark, child: child),
                )
              : _ThemedContent(isDark: isDark, child: child),
        ),
      ),
    );
  }
}

class _ThemedContent extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _ThemedContent({Key? key, required this.isDark, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);

    final customColorScheme = isDark
        ? baseTheme.colorScheme.copyWith(
            brightness: Brightness.dark,
            onSurface: Colors.white,
            surface: Colors.grey[900],
            primary: Colors.blueAccent,
          )
        : baseTheme.colorScheme.copyWith(
            brightness: Brightness.light,
            onSurface: Colors.black87,
            surface: Colors.white,
            primary: Colors.blue,
          );

    final customTheme = baseTheme.copyWith(
      colorScheme: customColorScheme,
      textTheme: baseTheme.textTheme.apply(
        bodyColor: customColorScheme.onSurface,
        displayColor: customColorScheme.onSurface,
      ),
      iconTheme: baseTheme.iconTheme.copyWith(
        color: customColorScheme.onSurface,
      ),
    );

    return Theme(data: customTheme, child: child);
  }
}
