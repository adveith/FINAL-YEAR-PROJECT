import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5, curve: Curves.easeIn)));
    _scale = Tween<double>(begin: 0.7, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.elasticOut)));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen and redirect once auth resolves
    ref.listen(authStateProvider, (_, next) {
      if (next.isLoading) return;
      final state = next.value;
      if (state == null) return;
      if (!state.isAuthenticated) {
        context.go('/login');
        return;
      }
      switch (state.user?.role) {
        case 'student': context.go('/student'); break;
        case 'school': context.go('/school'); break;
        case 'facilitator': context.go('/teacher'); break;
        case 'counselor': context.go('/counselor'); break;
        case 'doctor': context.go('/doctor'); break;
        case 'parent': context.go('/parent'); break;
        case 'individual': context.go('/individual'); break;
        case 'admin': context.go('/admin'); break;
        case 'superadmin': context.go('/superadmin'); break;
        default: context.go('/login');
      }
    });

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primary, colors.secondary],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(Icons.school_rounded, size: 56, color: colors.primary),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'WeLearn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Learning Reimagined',
                      style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 48),
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
