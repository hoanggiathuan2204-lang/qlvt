import 'package:flutter/material.dart';

import '../widgets/dashboard_sidebar.dart';
import '../theme/app_colors.dart';

import 'dashboard_screen.dart';
import 'material_screen.dart';
import 'supplier_screen.dart';
import 'product_screen.dart';
import 'delivery_history_screen.dart';
import 'report_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selected = 0;

  // Responsive breakpoint
  static const double _desktopBreakpoint = 900;

  // Screens list for IndexedStack (must match menu order in DashboardSidebar)
  static const int _screenCount = 6;

  void _onSelect(int index) {
    if (index < 0 || index >= _screenCount) return;
    setState(() => _selected = index);
  }

  /// Builds the list of screen widgets with onMenuTap wired for mobile.
  List<Widget> _buildScreens() {
    return [
      DashboardScreen(
        showSidebar: false,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      MaterialScreen(
        showSidebar: false,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      SupplierScreen(
        showSidebar: false,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      ProductScreen(
        showSidebar: false,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      DeliveryHistoryScreen(
        showSidebar: false,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      ReportScreen(
        showSidebar: false,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _desktopBreakpoint;

        if (isDesktop) {
          // ─── Desktop layout: sidebar + content ───
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                DashboardSidebar(selectedIndex: _selected, onSelect: _onSelect),
                Expanded(
                  child: IndexedStack(index: _selected, children: screens),
                ),
              ],
            ),
          );
        } else {
          // ─── Mobile layout: drawer + content (NO AppBar) ───
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.background,
            drawer: Drawer(
              child: DashboardSidebar(
                selectedIndex: _selected,
                onSelect: (index) {
                  _onSelect(index);
                  Navigator.of(context).pop(); // close drawer
                },
                onCloseDrawer: () {
                  Navigator.of(context).pop(); // close drawer
                },
              ),
            ),
            body: IndexedStack(index: _selected, children: screens),
          );
        }
      },
    );
  }
}
