import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../routes/transitions.dart';
import '../theme.dart';
import '../widgets/itisam_emblem.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rope;
  late final Animation<double> _star;
  late final Animation<double> _wordFade;
  late final Animation<double> _zoom;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2700),
    );
    _rope = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.42, curve: Curves.easeOutCubic),
    );
    _star = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.62, curve: Curves.easeOutBack),
    );
    _wordFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.58, 0.8, curve: Curves.easeOut),
    );
    _zoom = Tween<double>(begin: 1, end: 1.14).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.62, 0.88, curve: Curves.easeInOut),
      ),
    );
    _controller.forward();
    _timer = Timer(const Duration(milliseconds: 3600), _goHome);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      itisamPageRoute(page: const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amiri = GoogleFonts.amiriTextTheme();
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_controller.isAnimating) _controller.value = 1;
          _timer?.cancel();
          _goHome();
        },
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.2),
              radius: 1.1,
              colors: [ItisamColors.darkSurface, ItisamColors.deepGreen],
            ),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _zoom,
                      child: ItisamEmblem(
                        ropeProgress: _rope.value,
                        starProgress: _star.value,
                        size: 220,
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeTransition(
                      opacity: _wordFade,
                      child: Column(
                        children: [
                          Text(
                            'الاعتصام',
                            style: amiri.displayMedium!.copyWith(
                              color: ItisamColors.gold,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '﴿وَاعْتَصِمُوا بِحَبْلِ اللَّهِ جَمِيعًا وَلَا تَفَرَّقُوا﴾',
                            textAlign: TextAlign.center,
                            style: amiri.titleLarge!.copyWith(
                              color: ItisamColors.cream.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}