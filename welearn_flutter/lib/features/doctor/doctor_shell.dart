import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DoctorShell extends StatelessWidget {
  const DoctorShell({super.key, required this.child});
  final Widget child;

  int _index(BuildContext context) {
    final p = GoRouterState.of(context).uri.path;
    if (p.startsWith('/doctor/patients')) return 1;
    if (p.startsWith('/doctor/appointments')) return 2;
    if (p.startsWith('/doctor/reports')) return 3;
    if (p.startsWith('/doctor/profile')) return 4;
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
            '/doctor',
            '/doctor/patients',
            '/doctor/appointments',
            '/doctor/reports',
            '/doctor/profile',
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
            icon: Icon(Icons.sick_outlined),
            selectedIcon: Icon(Icons.sick),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Reports',
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
