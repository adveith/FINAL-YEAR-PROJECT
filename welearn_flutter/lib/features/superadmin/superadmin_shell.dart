import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuperAdminShell extends StatelessWidget {
  const SuperAdminShell({super.key, required this.child});
  final Widget child;

  int _index(BuildContext context) {
    final p = GoRouterState.of(context).uri.path;
    if (p.startsWith('/superadmin/schools')) return 1;
    if (p.startsWith('/superadmin/packages')) return 2;
    if (p.startsWith('/superadmin/analytics')) return 3;
    if (p.startsWith('/superadmin/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index(context),
        onDestinationSelected: (i) {
          const routes = [
            '/superadmin',
            '/superadmin/schools',
            '/superadmin/packages',
            '/superadmin/analytics',
            '/superadmin/settings',
          ];
          context.go(routes[i]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Schools',
          ),
          NavigationDestination(
            icon: Icon(Icons.card_membership_outlined),
            selectedIcon: Icon(Icons.card_membership),
            label: 'Packages',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
