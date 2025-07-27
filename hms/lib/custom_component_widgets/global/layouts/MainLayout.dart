import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;

  const MainLayout({
    Key? key,
    required this.child,
    this.title = "Hospital Management System",
  }) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = context.watch<ThemeProvider>().selectedBackground;

    return BackgroundScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey, // Pass the key to your CustomAppBar
        title: widget.title,
        centerTitle: false,
        showBackButton: true,

        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ThemeSwitcherWidget(),
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            tooltip: "Change Background",
            onPressed: () async {
              final selectedBg =
                  await BackgroundSelectorService.showBackgroundSelector(
                    context,
                    backgroundOptions,
                  );
              if (selectedBg != null) {
                await context.read<ThemeProvider>().setSelectedBackground(
                  selectedBg,
                );
                context.read<ThemeProvider>().updateDarkBackground(
                  selectedBg.contains('dark'),
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: const AppFooter(),
      scrollable: false,
      child: widget.child,
    );
  }
}
