import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'stepper.dart';
import 'main.dart';
import 'config/api_config.dart';

enum AuthState {
  form,
  signUpOtp,
  forgotPasswordEmail,
  forgotPasswordOtp,
}

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupOtpController = TextEditingController();
  
  final _forgotEmailController = TextEditingController();
  final _forgotOtpController = TextEditingController();
  final _forgotNewPasswordController = TextEditingController();
  final _forgotConfirmPasswordController = TextEditingController();

  // FocusNodes for OTP
  final _signupOtpFocusNode = FocusNode();
  final _forgotOtpFocusNode = FocusNode();

  // States
  bool _isObscuredLogin = true;
  bool _isObscuredSignup = true;
  bool _isObscuredForgotNew = true;
  bool _isObscuredForgotConfirm = true;
  bool _isLoading = false;
  
  AuthState _authState = AuthState.form;
  String _generatedOtp = "";
  
  // Resend OTP timer variables
  Timer? _countdownTimer;
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Redraw headers/titles on tab switch
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupOtpController.dispose();
    _forgotEmailController.dispose();
    _forgotOtpController.dispose();
    _forgotNewPasswordController.dispose();
    _forgotConfirmPasswordController.dispose();
    _signupOtpFocusNode.dispose();
    _forgotOtpFocusNode.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = 30;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await GoogleSignIn.instance.initialize(
        clientId: '282412601110-tte4h5fp1v9kgme48rhiqjscrpp1vkjo.apps.googleusercontent.com',
        serverClientId: '282412601110-tte4h5fp1v9kgme48rhiqjscrpp1vkjo.apps.googleusercontent.com',
      );
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      // Send to backend
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcm_token');
      final response = await http.post(
        Uri.parse(ApiConfig.signup),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': googleUser.displayName ?? 'Google User',
          'email': googleUser.email,
          'password': '', // No password for Google Auth
          'provider': 'google',
          'googleId': googleUser.id,
          'location': {},
          if (fcmToken != null) 'fcm_token': fcmToken,
        }),
      );

      // We might get 409 if user exists, so let's try login route instead if signup fails
      http.Response finalResponse = response;
      if (response.statusCode == 409) {
        finalResponse = await http.post(
          Uri.parse(ApiConfig.login),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': googleUser.email,
            'provider': 'google',
          }),
        );
      }

      final data = jsonDecode(finalResponse.body);

      if (finalResponse.statusCode == 200 || finalResponse.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setInt('onboarding_step', 4);
        await prefs.setString('user_name', googleUser.displayName ?? 'Google User');
        await prefs.setString('user_email', googleUser.email);
        await prefs.setString('token', data['token'] ?? '');

        if (mounted) {
          _showSnackbar('Signed in with Google successfully!');
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const SafarSlotHome(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      } else {
        _showSnackbar('Google sign-in failed: ${data["message"] ?? "Unknown error"}');
      }
    } catch (e) {
      _showSnackbar('Google sign-in error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleEmailLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _showSnackbar('Please enter a valid email address');
      return;
    }
    if (password.length < 4) {
      _showSnackbar('Password must be at least 4 characters long');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcm_token');
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'provider': 'email',
          if (fcmToken != null) 'fcm_token': fcmToken,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setInt('onboarding_step', 4);
        await prefs.setString('user_email', email);
        await prefs.setString('user_name', email.split('@')[0]); // fallback
        await prefs.setString('token', data['token'] ?? '');

        if (mounted) {
          _showSnackbar('Welcome back!');
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const SafarSlotHome(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      } else {
        _showSnackbar(data['message'] ?? 'Login failed. Please try again.');
      }
    } catch (e) {
      _showSnackbar('Error connecting to server. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignUpRequest() async {
    final name = _signupNameController.text.trim();
    final email = _signupEmailController.text.trim();
    final password = _signupPasswordController.text;

    if (name.isEmpty) {
      _showSnackbar('Please enter your full name');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showSnackbar('Please enter a valid email address');
      return;
    }
    if (password.length < 4) {
      _showSnackbar('Password must be at least 4 characters long');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.sendOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _authState = AuthState.signUpOtp;
          });
          _startCountdown();
          _signupOtpController.clear();
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _signupOtpFocusNode.requestFocus();
          });

          _showSnackbar('OTP sent to $email!');
        }
      } else {
        _showSnackbar(data['message'] ?? 'Failed to send OTP.');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showSnackbar('Error connecting to server. Please try again.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignUpVerify() async {
    if (_signupOtpController.text.length < 6) {
      _showSnackbar('Please enter the 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcm_token');
      
      final name = _signupNameController.text.trim();
      final email = _signupEmailController.text.trim();
      final password = _signupPasswordController.text;
      final otp = _signupOtpController.text;

      final response = await http.post(
        Uri.parse(ApiConfig.signup),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'provider': 'email',
          'location': {},
          'otp': otp,
          if (fcmToken != null) 'fcm_token': fcmToken,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setInt('onboarding_step', 4);
        await prefs.setString('user_email', email);
        await prefs.setString('user_name', name);
        // Login right away or store token if backend gives it on signup

        if (mounted) {
          _showSnackbar('Email verified and registered successfully!');
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const SafarSlotHome(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      } else {
        _showSnackbar(data['message'] ?? 'Registration failed. Try again.');
      }
    } catch (e) {
      _showSnackbar('Error connecting to server. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleForgotPasswordRequest() async {
    final email = _forgotEmailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showSnackbar('Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    // Generate simulated 6-digit OTP for reset
    final otp = (100000 + math.Random().nextInt(900000)).toString();
    _generatedOtp = otp;

    if (mounted) {
      setState(() {
        _isLoading = false;
        _authState = AuthState.forgotPasswordOtp;
      });
      _startCountdown();
      _forgotOtpController.clear();
      _forgotNewPasswordController.clear();
      _forgotConfirmPasswordController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _forgotOtpFocusNode.requestFocus();
      });

      _showSnackbar('Reset OTP sent to $email! (Use code: $otp for testing)');
    }
  }

  Future<void> _handleForgotPasswordReset() async {
    final otp = _forgotOtpController.text;
    final newPassword = _forgotNewPasswordController.text;
    final confirmPassword = _forgotConfirmPasswordController.text;

    if (otp.length < 6) {
      _showSnackbar('Please enter the 6-digit OTP');
      return;
    }
    if (otp != _generatedOtp) {
      _showSnackbar('Invalid OTP code. Please try again.');
      return;
    }
    if (newPassword.length < 4) {
      _showSnackbar('New password must be at least 4 characters long');
      return;
    }
    if (newPassword != confirmPassword) {
      _showSnackbar('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _authState = AuthState.form;
        _tabController.index = 0; // Return to login tab
      });

      _showSnackbar('Password reset successfully! Please login with your new password.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showHelpDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Icon(Icons.help_outline_rounded, color: Color(0xFFFF671F), size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Help & Support (FAQ)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Frequently Asked Questions to assist your rail journey:',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildFaqItem(
                        'How do I book a slot?',
                        'Once logged in, click "Book a Slot" on the home page. Choose your destination, select a preferred time slot, and confirm the booking.',
                      ),
                      _buildFaqItem(
                        'Is SafarSlot free to use?',
                        'Yes, SafarSlot is completely free. We do not charge fees for tracking train status or checking availability slots.',
                      ),
                      _buildFaqItem(
                        'Is my email and personal data secure?',
                        'Absolutely. Your login credentials and personal search data are fully encrypted and never shared with third parties.',
                      ),
                      _buildFaqItem(
                        'Can I change my language later?',
                        'Yes. Go to the profile or settings panel inside the app to toggle between Hindi, English, and other regional scripts.',
                      ),
                      _buildFaqItem(
                        'How does the email OTP work?',
                        'During sign up or password recovery, we send a mock 6-digit code to your email for demonstration safety. Simply enter the code shown in the popup dialog.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF671F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Close Helpdesk',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF0F172A),
          ),
        ),
        iconColor: const Color(0xFFFF671F),
        collapsedIconColor: const Color(0xFF64748B),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getWelcomeHeaderTitle(bool isLoginTab) {
    switch (_authState) {
      case AuthState.form:
        return isLoginTab ? 'Welcome Back! 👋' : 'Create Account 🚀';
      case AuthState.signUpOtp:
        return 'Verify Email ✉️';
      case AuthState.forgotPasswordEmail:
        return 'Reset Password 🔒';
      case AuthState.forgotPasswordOtp:
        return 'Verify & Reset 🔑';
    }
  }

  String _getWelcomeHeaderSubtitle(bool isLoginTab) {
    switch (_authState) {
      case AuthState.form:
        return isLoginTab ? 'Login to continue your journey' : 'Sign up to start booking railway slots';
      case AuthState.signUpOtp:
        return 'Confirm your registration details';
      case AuthState.forgotPasswordEmail:
        return 'Find your SafarSlot account';
      case AuthState.forgotPasswordOtp:
        return 'Complete your password recovery';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoginTab = _tabController.index == 0;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image Template
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_sign_screen.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Main Page Layout (Scrollable)
          SafeArea(
            child: Column(
              children: [
                // Top Stepper Navigation Header (Step 4/Personalize Active)
                const OnboardingStepper(currentStep: 3),

                // Top Bar with Back Arrow and Help Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _showHelpDialog,
                        icon: const Icon(Icons.headset_mic_rounded, color: Color(0xFF0F172A), size: 18),
                        label: const Text(
                          'Help',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Form Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

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
                        
                        
                        
                        Text(
                          _getWelcomeHeaderTitle(isLoginTab),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getWelcomeHeaderSubtitle(isLoginTab),
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: Colors.black26,
                            fontWeight: FontWeight.w500,
                            
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Main Content Card containing switcher and forms
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                          child: _buildCardContent(),
                        ),
                        const SizedBox(height: 24),
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

  Widget _buildCardContent() {
    switch (_authState) {
      case AuthState.form:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tab Switcher headers
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFFF671F),
                indicatorWeight: 3,
                labelColor: const Color(0xFFFF671F),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Login'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_alt_1_outlined, size: 18),
                        SizedBox(width: 6),
                        Text('Sign Up'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form content inputs
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: IndexedStack(
                index: _tabController.index,
                children: [
                  _buildLoginForm(),
                  _buildSignupForm(),
                ],
              ),
            ),
          ],
        );
      case AuthState.signUpOtp:
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildSignUpOtpForm(),
        );
      case AuthState.forgotPasswordEmail:
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildForgotPasswordEmailForm(),
        );
      case AuthState.forgotPasswordOtp:
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildForgotPasswordOtpForm(),
        );
    }
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Google sign-in at top (Primary)
        _buildGoogleButton(),
        
        const SizedBox(height: 16),
        // Divider
        _buildDividerText('or continue with Email'),
        const SizedBox(height: 16),

        // 2. Email input
        _buildTextField(
          controller: _loginEmailController,
          hint: 'Email ID',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // 3. Password input
        _buildPasswordField(
          controller: _loginPasswordController,
          isObscured: _isObscuredLogin,
          onToggle: () {
            setState(() {
              _isObscuredLogin = !_isObscuredLogin;
            });
          },
        ),

        // 4. Forgot Password Link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                _authState = AuthState.forgotPasswordEmail;
              });
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 5. Submit button
        _buildSubmitButton(
          label: 'Login',
          onTap: _handleEmailLogin,
        ),
        const SizedBox(height: 20),

        // 6. Security disclaimer banner
        _buildSafeDataBanner(),
        const SizedBox(height: 24),

        

        // 8. Olive Wreath Footer
        _buildWreathFooter(),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Google sign-in at top (Primary)
        _buildGoogleButton(),

        const SizedBox(height: 16),
        // Divider
        _buildDividerText('or continue with Email'),
        const SizedBox(height: 16),

        // 2. Full name input
        _buildTextField(
          controller: _signupNameController,
          hint: 'Full Name',
          icon: Icons.person_rounded,
        ),
        const SizedBox(height: 16),

        // 3. Email input
        _buildTextField(
          controller: _signupEmailController,
          hint: 'Email ID',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // 4. Password input
        _buildPasswordField(
          controller: _signupPasswordController,
          isObscured: _isObscuredSignup,
          onToggle: () {
            setState(() {
              _isObscuredSignup = !_isObscuredSignup;
            });
          },
        ),
        const SizedBox(height: 24),

        // 5. Submit button
        _buildSubmitButton(
          label: 'Sign Up',
          onTap: _handleSignUpRequest,
        ),
        const SizedBox(height: 20),

        // 6. Security disclaimer banner
        _buildSafeDataBanner(),
        const SizedBox(height: 24),

        

        // 8. Olive Wreath Footer
        _buildWreathFooter(),
      ],
    );
  }

  Widget _buildSignUpOtpForm() {
    final email = _signupEmailController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read_rounded, size: 48, color: Color(0xFFFF671F)),
        const SizedBox(height: 14),
        const Text(
          'Email Verification',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a 6-digit OTP code to\n$email. Enter it below to register.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        _buildOtpBoxes(_signupOtpController, _signupOtpFocusNode),
        const SizedBox(height: 20),

        _buildResendTimerSection(() {
          _showSnackbar('Verification code resent!');
          _startCountdown();
        }),
        const SizedBox(height: 24),

        _buildSubmitButton(
          label: 'Verify & Register',
          onTap: _handleSignUpVerify,
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: () {
            setState(() {
              _authState = AuthState.form;
            });
          },
          child: const Text(
            'Change Email / Back',
            style: TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_reset_rounded, size: 48, color: Color(0xFFFF671F)),
        const SizedBox(height: 14),
        const Text(
          'Find Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter the email address registered with your account. We will send an OTP to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        _buildTextField(
          controller: _forgotEmailController,
          hint: 'Email ID',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),

        _buildSubmitButton(
          label: 'Send Reset OTP',
          onTap: _handleForgotPasswordRequest,
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: () {
            setState(() {
              _authState = AuthState.form;
            });
          },
          child: const Text(
            'Back to Login',
            style: TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordOtpForm() {
    final email = _forgotEmailController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.key_rounded, size: 48, color: Color(0xFFFF671F)),
        const SizedBox(height: 14),
        const Text(
          'Reset Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the OTP sent to $email and choose a new password.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        // OTP code box
        _buildOtpBoxes(_forgotOtpController, _forgotOtpFocusNode),
        const SizedBox(height: 16),

        // Resend section
        _buildResendTimerSection(() {
          _showSnackbar('Reset code resent!');
          _startCountdown();
        }),
        const SizedBox(height: 20),

        // New password
        _buildPasswordField(
          controller: _forgotNewPasswordController,
          isObscured: _isObscuredForgotNew,
          onToggle: () {
            setState(() {
              _isObscuredForgotNew = !_isObscuredForgotNew;
            });
          },
        ),
        const SizedBox(height: 16),

        // Confirm new password
        TextField(
          controller: _forgotConfirmPasswordController,
          obscureText: _isObscuredForgotConfirm,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFFFF671F), size: 18),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isObscuredForgotConfirm = !_isObscuredForgotConfirm;
                });
              },
              icon: Icon(
                _isObscuredForgotConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: Colors.black45,
                size: 18,
              ),
            ),
            hintText: 'Confirm Password',
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14.5),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFF671F), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 24),

        _buildSubmitButton(
          label: 'Reset Password',
          onTap: _handleForgotPasswordReset,
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: () {
            setState(() {
              _authState = AuthState.forgotPasswordEmail;
            });
          },
          child: const Text(
            'Resend OTP to another Email',
            style: TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _isLoading ? null : _handleGoogleSignIn,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/google_logo.png',
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDividerText(String label) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFF1F5F9))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFF1F5F9))),
      ],
    );
  }

  Widget _buildOtpBoxes(TextEditingController controller, FocusNode focusNode) {
    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hidden TextField that is visually transparent but technically fully visible to the OS keyboard manager
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: Colors.transparent, fontSize: 1.0),
              cursorColor: Colors.transparent,
              showCursor: false,
              onChanged: (val) {
                setState(() {}); // Re-render visual boxes
              },
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                filled: true,
              ),
            ),
          ),
          // Visual Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final text = controller.text;
              final isFocused = focusNode.hasFocus && text.length == index;
              final hasValue = text.length > index;
              final char = hasValue ? text[index] : "";

              return Container(
                width: 42,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFocused
                        ? const Color(0xFFFF671F)
                        : (hasValue ? const Color(0xFF046A38) : const Color(0xFFE2E8F0)),
                    width: isFocused ? 2.0 : 1.5,
                  ),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF671F).withAlpha(20),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  char,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildResendTimerSection(VoidCallback onResend) {
    final canResend = _secondsRemaining == 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          canResend ? "Didn't receive the OTP? " : "Resend OTP in ",
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        canResend
            ? TextButton(
                onPressed: onResend,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: Color(0xFFFF671F),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              )
            : Text(
                '${_secondsRemaining}s',
                style: const TextStyle(
                  color: Color(0xFFFF671F),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFFFF671F), size: 18),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            isObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: Colors.black45,
            size: 18,
          ),
        ),
        hintText: 'Password',
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14.5),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF671F), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFFF671F), size: 18),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14.5),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF671F), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSubmitButton({required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : onTap,
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
              const SizedBox(width: 40),
              _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
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
    );
  }

  Widget _buildSafeDataBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Soft Blue
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
      ),
      child: Row(
        children: const [
          Icon(
            Icons.gpp_good_rounded,
            color: Color(0xFF2563EB), // Lock shield blue
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your data is safe with us. We never share your information.',
              style: TextStyle(
                color: Color(0xFF1E40AF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildWreathFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          '🍃  Trusted by 1M+ Indian Rail Travelers  🍃',
          style: TextStyle(
            fontSize: 11.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}
