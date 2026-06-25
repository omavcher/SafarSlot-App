import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'stepper.dart';
import 'login_signup_screen.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() => _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState extends State<NotificationPermissionScreen> {
  Future<void> _handleNextStep(bool requestPermission) async {
    bool actuallyGranted = false;
    if (requestPermission) {
      final status = await Permission.notification.request();
      actuallyGranted = status.isGranted;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onboarding_step', 3); // Save step progress
    await prefs.setBool('notifications_granted', actuallyGranted); // Save choice
    
    // Simulate fetching FCM token when permission is granted
    if (actuallyGranted) {
      final mockFcmToken = 'mock_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('fcm_token', mockFcmToken);
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginSignupScreen(),
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
              'assets/images/notifica_screen.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Scrollable content to prevent vertical layout overflows
          SafeArea(
            child: Column(
              children: [
                // Custom Stepper Progress Indicator (Step 3/Notifications Active)
                const OnboardingStepper(currentStep: 2),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
 
                        // Main Header Title
                        const Text(
                          'Stay Updated, Travel Worry-Free',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
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
                          'Allow notifications to never miss\nimportant updates',
                          style: TextStyle(
                            fontSize: 14.5,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        // Large vertical spacing to skip past the phone mock inside the background image
                        const SizedBox(height: 220),

                        // "You'll get notified about:" Details Card
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
                                  'You\'ll get notified about:',
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Item 1: Live Train Updates
                              _buildNotifyRow(
                                color: const Color(0xFFE8F5E9),
                                iconColor: const Color(0xFF2E7D32),
                                icon: Icons.train_rounded,
                                title: 'Live Train Updates',
                                description: 'Arrivals, departures, delays & running status',
                              ),
                              const SizedBox(height: 14),
                              const Divider(color: Color(0xFFF1F5F9), height: 1),
                              const SizedBox(height: 14),

                              // Item 2: Important Alerts
                              _buildNotifyRow(
                                color: const Color(0xFFFFF3E0),
                                iconColor: const Color(0xFFE65100),
                                icon: Icons.notifications_rounded,
                                title: 'Important Alerts',
                                description: 'Platform changes, cancellations & more',
                              ),
                              const SizedBox(height: 14),
                              const Divider(color: Color(0xFFF1F5F9), height: 1),
                              const SizedBox(height: 14),

                              // Item 3: Nearby Trains & Stations
                              _buildNotifyRow(
                                color: const Color(0xFFE3F2FD),
                                iconColor: const Color(0xFF1565C0),
                                icon: Icons.location_on_rounded,
                                title: 'Nearby Trains & Stations',
                                description: 'Updates about trains & stations near you',
                              ),
                              const SizedBox(height: 14),
                              const Divider(color: Color(0xFFF1F5F9), height: 1),
                              const SizedBox(height: 14),

                              // Item 4: Booking & Offers
                              _buildNotifyRow(
                                color: const Color(0xFFF3E5F5),
                                iconColor: const Color(0xFF6A1B9A),
                                icon: Icons.local_activity_rounded, // Ticket-like icon
                                title: 'Booking & Offers',
                                description: 'Booking confirmations, offers & travel tips',
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
                        children: const [
                          Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'We respect your privacy. You can change notification settings anytime.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Allow Notifications Button (Orange)
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
                                    Icons.notifications_active_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const Text(
                                  'Allow Notifications',
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
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFFFF671F),
                                    size: 20,
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

  Widget _buildNotifyRow({
    required Color color,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        // Rounded Icon container
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Text explanations
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Far-right chevron
        const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF94A3B8),
          size: 20,
        ),
      ],
    );
  }
}
