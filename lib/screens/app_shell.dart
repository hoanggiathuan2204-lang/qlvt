import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'material_screen.dart';
import 'supplier_screen.dart';
import 'product_screen.dart';
import 'delivery_history_screen.dart';
import 'report_screen.dart';
import '../widgets/dashboard_sidebar.dart';
import '../theme/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  int _selected = 0;

  static const _routes = {
    0: '/dashboard',
    1: '/materials',
    2: '/suppliers',
    3: '/products',
    4: '/delivery',
    5: '/reports',
  };

  void _onSelect(int index) {
    final route = _routes[index];
    if (route == null) return;
    setState(() => _selected = index);
    _navigatorKey.currentState?.pushReplacementNamed(route);
  }

  Route<dynamic> _onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(showSidebar: false),
        );
      case '/materials':
        return MaterialPageRoute(
          builder: (_) => const MaterialScreen(showSidebar: false),
        );
      case '/suppliers':
        return MaterialPageRoute(
          builder: (_) => const SupplierScreen(showSidebar: false),
        );
      case '/products':
        return MaterialPageRoute(builder: (_) => const ProductScreen());
      case '/delivery':
        return MaterialPageRoute(builder: (_) => const DeliveryHistoryScreen());
      case '/reports':
        return MaterialPageRoute(
          builder: (_) => const ReportScreen(showSidebar: false),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(showSidebar: false),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          DashboardSidebar(selectedIndex: _selected, onSelect: _onSelect),
          Expanded(
            child: Navigator(
              key: _navigatorKey,
              initialRoute: '/dashboard',
              onGenerateRoute: _onGenerate,
            ),
          ),
        ],
      ),
    );
  }
}
