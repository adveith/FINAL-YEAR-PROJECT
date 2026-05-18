import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IndividualShell extends StatelessWidget {
  const IndividualShell({super.key, required this.child});
  final Widget child;

  int _index(BuildContext context) {
    final p = GoRouterState.of(context).uri.path;
    if (p.startsWith('/individual/courses')) return 1;
    if (p.startsWith('/individual/sessions')) return 2;
    if (p.startsWith('/individual/cosmos')) return 3;
    if (p.startsWith('/individual/profile')) return 4;
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
            '/individual',
            '/individual/courses',
            '/individual/sessions',
            '/individual/cosmos',
            '/individual/profile',
          ];
          context.go(routes[i]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_lesson_outlined),
            selectedIcon: Icon(Icons.play_lesson),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_call_outlined),
            selectedIcon: Icon(Icons.video_call),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Cosmos',
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
