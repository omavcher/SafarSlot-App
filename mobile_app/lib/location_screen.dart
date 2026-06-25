import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'stepper.dart';
import 'notification_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  Future<void> _handleNextStep(bool requestPermission) async {
    bool actuallyGranted = false;
    if (requestPermission) {
      final status = await Permission.location.request();
      actuallyGranted = status.isGranted || status.isLimited;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onboarding_step', 2); // Save step progress
    await prefs.setBool('location_granted', actuallyGranted); // Save choice

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const NotificationPermissionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image Template
          Positioned.fill(
            child: Image.asset(
              'assets/images/locationse_screen.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Scrollable content to prevent vertical layout overflows
          SafeArea(
            child: Column(
              children: [
                // Custom Stepper Progress Indicator (Step 2/Location Active)
                const OnboardingStepper(currentStep: 1),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Logo and App Branding
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFF0F0F0),
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/images/logo.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'SafarSlot',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'Your Smart Railway Companion',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Main Header Title
                        const Text(
                          'Allow Location Access',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Orange divider line
                        Container(
                          width: 45,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF671F),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 8),
                         const Text(
                          'Help us serve you better',
                          style: TextStyle(
                            fontSize: 14.5,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // "Why we need location" Details Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(245),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.black.withAlpha(8), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text(
                                  'Why we need your location?',
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Item 1: Find Nearby Stations
                              _buildInfoRow(
                                color: const Color(0xFFE8F5E9),
                                iconColor: const Color(0xFF2E7D32),
                                icon: Icons.location_on_rounded,
                                title: 'Find Nearby Stations',
                                description: 'Show nearby railway stations, platforms and facilities around you.',
                              ),
                              const SizedBox(height: 18),

                              // Item 2: Live Train Updates
                              _buildInfoRow(
                                color: const Color(0xFFE3F2FD),
                                iconColor: const Color(0xFF1565C0),
                                icon: Icons.train_rounded,
                                title: 'Live Train Updates',
                                description: 'Get accurate arrival, departure and delay updates based on your location.',
                              ),
                              const SizedBox(height: 18),

                              // Item 3: Smart Alerts
                              _buildInfoRow(
                                color: const Color(0xFFFFF3E0),
                                iconColor: const Color(0xFFE65100),
                                icon: Icons.notifications_rounded,
                                title: 'Smart Alerts',
                                description: 'Receive timely alerts for your journey, platform changes and more.',
                              ),
                              const SizedBox(height: 18),

                              // Item 4: Better Experience
                              _buildInfoRow(
                                color: const Color(0xFFF3E5F5),
                                iconColor: const Color(0xFF6A1B9A),
                                icon: Icons.send_rounded,
                                title: 'Better Experience',
                                description: 'Personalized journey recommendations and faster search results.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Bottom Anchor Section
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0, top: 4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Privacy Footnote Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                  height: 1.3,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Your location is used only to improve your experience. We never share your location with anyone. ',
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Allow Location Access Button (Orange)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _handleNextStep(true),
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF8C3B),
                                  Color(0xFFFF671F),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF671F).withAlpha(30),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const Text(
                                  'Allow Location Access',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFFFF671F),
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Not Now Button (Outlined/Text)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => _handleNextStep(false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            foregroundColor: const Color(0xFF0F172A),
                          ),
                          child: const Text(
                            'Not Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required Color color,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rounded Icon container
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Text explanations
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
