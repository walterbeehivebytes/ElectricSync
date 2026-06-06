import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    final authService = AuthService();
    await Future.wait([
      authService.init(),
      Future.delayed(const Duration(milliseconds: 2200)),
    ]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => authService.currentUser != null
            ? HomeScreen(authService: authService)
            : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background geometry
          Positioned(
            right: -70, top: -70,
            child: Transform.rotate(
              angle: 0.35,
              child: Container(
                width: 240, height: 240,
                decoration: BoxDecoration(
                  color: AppColors.pm.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
          Positioned(
            left: -50, bottom: -50,
            child: Transform.rotate(
              angle: -0.25,
              child: Container(
                width: 190, height: 190,
                decoration: BoxDecoration(
                  color: AppColors.pm.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
          ),
          Positioned(
            left: 36, top: 100,
            child: Container(width: 3, height: 72, color: AppColors.pm.withValues(alpha: 0.18)),
          ),
          Positioned(
            right: 48, bottom: 160,
            child: Container(width: 3, height: 48, color: AppColors.sm.withValues(alpha: 0.14)),
          ),

          // Centre content
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo box
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.pm.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.pm, width: 1.5),
                    ),
                    child: const Icon(Icons.bolt, size: 44, color: AppColors.pm),
                  ),
                  const SizedBox(height: 28),
                  Text('ELECTRIC', style: AppText.display(44, weight: FontWeight.w900, letterSpacing: 4)),
                  Text('SYNC',     style: AppText.display(44, weight: FontWeight.w300, color: AppColors.pm, letterSpacing: 4)),
                  const SizedBox(height: 12),
                  Text(
                    'FIELD COORDINATION SYSTEM',
                    style: AppText.display(11, color: AppColors.textMuted, letterSpacing: 2.5, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 52),
                  // Dot loader
                  _DotLoader(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotLoader extends StatefulWidget {
  @override
  State<_DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<_DotLoader> with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true, period: Duration(milliseconds: 1200 + i * 200)));
    _anims = _ctrls.map((c) => CurvedAnimation(parent: c, curve: Curves.easeInOut)).toList();
    // Stagger
    Future.delayed(const Duration(milliseconds: 200), () { if (mounted) _ctrls[1].forward(); });
    Future.delayed(const Duration(milliseconds: 400), () { if (mounted) _ctrls[2].forward(); });
    _ctrls[0].forward();
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.pm, AppColors.pm.withValues(alpha: 0.55), AppColors.pm.withValues(alpha: 0.25)];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Transform.scale(
            scale: 0.8 + _anims[i].value * 0.5,
            child: Container(
              width: 7, height: 7,
              decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle),
            ),
          ),
        ),
      )),
    );
  }
}
