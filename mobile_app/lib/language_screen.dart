import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_fonts.dart';
import 'stepper.dart';
import 'location_screen.dart';

class LanguageModel {
  final String code;
  final String nativeName;
  final String englishName;
  final String iconPath;

  const LanguageModel({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.iconPath,
  });
}

class LanguageSelectionScreen extends StatefulWidget {
  final bool isFromProfile;
  const LanguageSelectionScreen({super.key, this.isFromProfile = false});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLangCode = 'en';

  final List<LanguageModel> _languages = const [
    LanguageModel(
      code: 'en',
      nativeName: 'English',
      englishName: 'English',
      iconPath: 'assets/images/lang_symbol/en.png',
    ),
    LanguageModel(
      code: 'hi',
      nativeName: 'हिंदी',
      englishName: 'Hindi',
      iconPath: 'assets/images/lang_symbol/hi.png',
    ),
    LanguageModel(
      code: 'ma',
      nativeName: 'मराठी',
      englishName: 'Marathi',
      iconPath: 'assets/images/lang_symbol/ma.png',
    ),
    LanguageModel(
      code: 'ta',
      nativeName: 'தமிழ்',
      englishName: 'Tamil',
      iconPath: 'assets/images/lang_symbol/ta.png',
    ),
    LanguageModel(
      code: 'tel',
      nativeName: 'తెలుగు',
      englishName: 'Telugu',
      iconPath: 'assets/images/lang_symbol/tel.png',
    ),
    LanguageModel(
      code: 'ka',
      nativeName: 'ಕನ್ನಡ',
      englishName: 'Kannada',
      iconPath: 'assets/images/lang_symbol/ka.png',
    ),
    LanguageModel(
      code: 'mal',
      nativeName: 'മലയാളം',
      englishName: 'Malayalam',
      iconPath: 'assets/images/lang_symbol/mal.png',
    ),
    LanguageModel(
      code: 'bengali',
      nativeName: 'বাংলা',
      englishName: 'Bengali',
      iconPath: 'assets/images/lang_symbol/bengali.png',
    ),
    LanguageModel(
      code: 'panj',
      nativeName: 'ਪੰਜਾਬੀ',
      englishName: 'Punjabi',
      iconPath: 'assets/images/lang_symbol/panj.png',
    ),
    LanguageModel(
      code: 'odia',
      nativeName: 'ଓଡ଼ିଆ',
      englishName: 'Odia',
      iconPath: 'assets/images/lang_symbol/odia.png',
    ),
  ];

  Future<void> _handleContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language_code', _selectedLangCode);

    if (widget.isFromProfile) {
      if (mounted) {
        Navigator.pop(context, _selectedLangCode);
      }
      return;
    }

    await prefs.setBool('has_selected_language', true);
    await prefs.setInt('onboarding_step', 1); // Track step progress

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LocationPermissionScreen(),
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
              'assets/images/language_screen.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Main content container (Scrollable to prevent overflows)
          SafeArea(
            child: Column(
              children: [
                if (!widget.isFromProfile) const OnboardingStepper(currentStep: 0),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        if (!widget.isFromProfile) ...[
                          // Logo and App Branding
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: const Color(0xFFF0F0F0),
                                width: 1.2,
                              ),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/logo.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          const Text(
                            'SafarSlot',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Text(
                            'Your Smart Railway Companion',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Onboarding title & subtitle
                          const Text(
                            'Namaste! 🙏',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Choose your preferred language\nto continue',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 28),
                        ] else ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Text(
                                'App Language',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Select a language below to change your app\'s display language.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 3-Column Language Selection Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: _languages.length + 1, // +1 for "More Languages"
                          itemBuilder: (context, index) {
                            if (index == _languages.length) {
                              // "More Languages" card
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(240),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.black.withAlpha(10),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Grid of dots icon
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.grid_view_rounded,
                                        color: Colors.black38,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'More Languages',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Coming Soon',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.black38,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }

                            final lang = _languages[index];
                            final isSelected = _selectedLangCode == lang.code;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedLangCode = lang.code;
                                });
                              },
                              child: Stack(
                                children: [
                                  // The Language Selection Card
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFFF671F) // Saffron Border
                                            : Colors.black.withAlpha(10),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? const Color(0xFFFF671F).withAlpha(15)
                                              : Colors.black.withAlpha(5),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // 1:1 Transparent PNG Icon
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Image.asset(
                                              lang.iconPath,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Native script text (Noto Sans for proper Indic rendering)
                                        Text(
                                          lang.nativeName,
                                          style: AppFonts.notoSans(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0F172A),
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // English label (Inter for clean latin text)
                                        Text(
                                          lang.englishName,
                                          style: AppFonts.inter(
                                            fontSize: 10.5,
                                            color: const Color(0xFF64748B),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Orange Circular Checked Badge at Top Right
                                  if (isSelected)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFF671F),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 11,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom CTA Section (Stays anchored at the bottom)
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0, top: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Disclaimer Shield Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4), // Ultra light green
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFDCFCE7), width: 1),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.gpp_good_rounded,
                              color: Color(0xFF15803D), // Green
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'You can change the language anytime from settings',
                                style: TextStyle(
                                  color: Color(0xFF15803D),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Continue Button (Orange)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleContinue,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF8C3B), // Saffron Gradient Start
                                  Color(0xFFFF671F), // Saffron Gradient End
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
                                const SizedBox(width: 48), // Balanced size to offset the arrow circle
                                const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 18,
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
                                    Icons.arrow_forward,
                                    color: Color(0xFFFF671F),
                                    size: 20,
                                  ),
                                ),
                              ],
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
}
