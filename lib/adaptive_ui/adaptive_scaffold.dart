import 'package:flutter/material.dart';
import 'nav_rail_sidebar.dart';
import 'bottom_nav_pane.dart';
import 'extra_info_pane.dart';

/// A robust adaptive shell for the application.
class AdaptiveScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final List<Widget> screens;
  final String title;

  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.screens,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoints optimized for Chrome and Tablet (iPad Air)
        if (constraints.maxWidth < 600) {
          return _buildMobile(context);
        } else if (constraints.maxWidth < 1024) {
          return _buildTablet(context);
        } else {
          return _buildLarge(context);
        }
      },
    );
  }

  /// 1. Mobile (< 600px): BottomNav + Single Screen
  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavPane(
        selectedIndex: selectedIndex,
        onDestinationSelected: onIndexChanged,
      ),
    );
  }

  /// 2. Tablet (600px - 1024px): NavRail + Single Pane
  Widget _buildTablet(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavRailSidebar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onIndexChanged,
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Column(
              children: [
                AppBar(elevation: 0, title: Text(title)),
                Expanded(child: screens[selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Large Screens (> 1024px): NavRail + Dual Pane (Main + Extra Info)
  Widget _buildLarge(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavRailSidebar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onIndexChanged,
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // Main Content
          Expanded(
            flex: 5,
            child: Column(
              children: [
                AppBar(elevation: 0, title: Text(title)),
                Expanded(child: screens[selectedIndex]),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // Analytic / Extra Info Screen (Keep on Right Side)
          const Expanded(flex: 3, child: ExtraInfoPane()),
        ],
      ),
    );
  }
}
