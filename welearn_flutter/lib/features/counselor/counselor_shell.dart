import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CounselorShell extends StatelessWidget {
  const CounselorShell({super.key, required this.child});
  final Widget child;

  int _index(BuildContext context) {
    final p = GoRouterState.of(context).uri.path;
    if (p.startsWith('/counselor/sessions')) return 1;
    if (p.startsWith('/counselor/bookings')) return 2;
    if (p.startsWith('/counselor/clients')) return 3;
    if (p.startsWith('/counselor/profile')) return 4;
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
            '/counselor',
            '/counselor/sessions',
            '/counselor/bookings',
            '/counselor/clients',
            '/counselor/profile',
          ];
          context.go(routes[i]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_camera_front_outlined),
            selectedIcon: Icon(Icons.video_camera_front),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt),
            label: 'Clients',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
