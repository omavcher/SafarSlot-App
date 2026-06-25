import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_fonts.dart';
import 'main.dart';
import 'language_screen.dart';
import 'location_screen.dart';
import 'notification_screen.dart';
import 'login_signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  // Animations
  late Animation<double> _bgFadeAnimation;
  late Animation<double> _bgScaleAnimation;   // Ken Burns zoom on bg image
  late Animation<Offset> _topOrangeOffset;
  late Animation<Offset> _bottomGreenOffset;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _dividerWidthAnimation;
  late Animation<double> _footerFadeAnimation;
  late Animation<double> _loadingProgressAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // Background: fade in
    _bgFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller,
          curve: const Interval(0.0, 0.30, curve: Curves.easeIn)),
    );

    // Background: slow Ken Burns scale 1.0 → 1.08
    _bgScaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller,
          curve: const Interval(0.0, 1.0, curve: Curves.linear)),
    );

    // Top orange wave
    _topOrangeOffset = Tween<Offset>(
      begin: const Offset(-0.3, -0.3), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller,
        curve: const Interval(0.1, 0.45, curve: Curves.easeOutCubic)));

    // Bottom green wave
    _bottomGreenOffset = Tween<Offset>(
      begin: const Offset(0.3, 0.3), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller,
        curve: const Interval(0.1, 0.45, curve: Curves.easeOutCubic)));

    // Logo
    _logoScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller,
          curve: const Interval(0.15, 0.5, curve: Curves.easeOutBack)),
    );
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller,
          curve: const Interval(0.15, 0.4, curve: Curves.easeIn)),
    );

    // Text
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller,
          curve: const Interval(0.30, 0.60, curve: Curves.easeOut)),
    );

    // Divider lines
    _dividerWidthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller,
          curve: const Interval(0.45, 0.75, curve: Curves.easeInOutCubic)),
    );

    // Footer
    _footerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller,
          curve: const Interval(0.45, 0.70, curve: Curves.easeIn)),
    );

    // Progress bar
    _loadingProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller,
          curve: const Interval(0.2, 0.97, curve: Curves.easeInOutSine)),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _navigateToHome();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingStep = prefs.getInt('onboarding_step') ?? 0;
    final isLoggedIn    = prefs.getBool('is_logged_in') ?? false;

    if (!mounted) return;

    Widget nextScreen;
    if (isLoggedIn && onboardingStep >= 4) {
      nextScreen = const SafarSlotHome();
    } else {
      switch (onboardingStep) {
        case 1:  nextScreen = LocationPermissionScreen();    break;
        case 2:  nextScreen = NotificationPermissionScreen(); break;
        case 3:  nextScreen = const LoginSignupScreen();     break;
        case 0:
        default: nextScreen = const LanguageSelectionScreen(); break;
      }
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:       (_, a, s) => nextScreen,
        transitionsBuilder:(_, a, s, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [

          // ══════════════════════════════════════════════════════════════════
          // LAYER 0 — Full-screen background image (Ken Burns zoom + fade in)
          // ══════════════════════════════════════════════════════════════════
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Opacity(
              opacity: _bgFadeAnimation.value,
              child: Transform.scale(
                scale: _bgScaleAnimation.value,
                child: child,
              ),
            ),
            child: Image.asset(
              'assets/images/splash_screen_bg.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // ══════════════════════════════════════════════════════════════════
          // LAYER 1 — Dark gradient scrim for readability
          // ══════════════════════════════════════════════════════════════════
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xBB000000), // strong dark at top → logo readable
                  Color(0x22000000), // near-transparent mid → show train
                  Color(0x44000000), // slight mid-bottom
                  Color(0xDD000000), // strong dark bottom → terminal readable
                ],
                stops: [0.0, 0.35, 0.55, 1.0],
              ),
            ),
          ),

          // ══════════════════════════════════════════════════════════════════
          // LAYER 2 — Top saffron wave
          // ══════════════════════════════════════════════════════════════════
          Positioned(
            top: 0, left: 0, right: 0,
            child: SlideTransition(
              position: _topOrangeOffset,
              child: FadeTransition(
                opacity: _bgFadeAnimation,
                child: Image.asset(
                  'assets/images/splash_screen_top_orange.png',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topLeft,
                ),
              ),
            ),
          ),

          // ══════════════════════════════════════════════════════════════════
          // LAYER 3 — Bottom green wave
          // ══════════════════════════════════════════════════════════════════
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SlideTransition(
              position: _bottomGreenOffset,
              child: FadeTransition(
                opacity: _bgFadeAnimation,
                child: Image.asset(
                  'assets/images/splash_screen_bottom_green.png',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // ══════════════════════════════════════════════════════════════════
          // LAYER 4 — All UI content
          // ══════════════════════════════════════════════════════════════════
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                const SizedBox(height: 16),

                // ── TOP BRANDING ─────────────────────────────────────────
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo card
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) => Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: child,
                        ),
                      ),
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(100),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                              color: Colors.white.withAlpha(180), width: 2),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                              'assets/images/logo.jpg', fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // App name + tagline
                    FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // SafarSlot
                          Text(
                            'SafarSlot',
                            style: AppFonts.poppins(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ─ हर सफर आसान ─
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: _dividerWidthAnimation,
                                    builder: (_, c) => Container(
                                      width: _dividerWidthAnimation.value * 22,
                                      height: 2.5,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF671F),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'हर सफर आसान, हर जानकारी आपके पास',
                                    style: AppFonts.notoSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withAlpha(230),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedBuilder(
                                    animation: _dividerWidthAnimation,
                                    builder: (_, c) => Container(
                                      width: _dividerWidthAnimation.value * 22,
                                      height: 2.5,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF046A38),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          Text(
                            'Your Smart Railway Companion',
                            style: AppFonts.poppins(
                              fontSize: 13.5,
                              color: Colors.white.withAlpha(200),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Spacer — train image fills the rest of the screen naturally
                const Spacer(),

                // ── FOOTER ────────────────────────────────────────────────
                FadeTransition(
                  opacity: _footerFadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // India badge + progress row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // India badge (glassmorphic on dark bg)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(25),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: Colors.white.withAlpha(50), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const IndianFlagIcon(),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Made for India. Made for You.',
                                        style: AppFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                      Text(
                                        '100% Free • Secure • Reliable',
                                        style: AppFonts.inter(
                                          color: Colors.white.withAlpha(180),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Progress % + bar
                            AnimatedBuilder(
                              animation: _loadingProgressAnimation,
                              builder: (_, c) {
                                final pct =
                                    (_loadingProgressAnimation.value * 100)
                                        .toInt();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$pct%',
                                      style: AppFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFFF671F),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 90,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(40),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor:
                                            _loadingProgressAnimation.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFFF671F),
                                                Color(0xFFFF9500),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Indian Flag Badge ────────────────────────────────────────────────────────
class IndianFlagIcon extends StatelessWidget {
  const IndianFlagIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withAlpha(20), width: 0.5),
      ),
      child: ClipOval(
        child: Column(
          children: [
            Expanded(child: Container(color: const Color(0xFFFF9933))),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: SizedBox(
                    width: 6, height: 6,
                    child: CustomPaint(painter: ChakraPainter()),
                  ),
                ),
              ),
            ),
            Expanded(child: Container(color: const Color(0xFF128807))),
          ],
        ),
      ),
    );
  }
}

// ─── Ashoka Chakra ────────────────────────────────────────────────────────────
class ChakraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0A2342)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius, paint);
    final spoke = Paint()
      ..color = const Color(0xFF0A2342)
      ..strokeWidth = 0.3;
    for (int i = 0; i < 24; i++) {
      final angle = (i * 15) * pi / 180;
      canvas.drawLine(
        center,
        center + Offset(radius * cos(angle), radius * sin(angle)),
        spoke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
