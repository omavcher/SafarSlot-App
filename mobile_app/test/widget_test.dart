import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safar_slot/main.dart';

// A mock asset bundle to bypass loading real assets (images) during widget tests
class TestAssetBundle extends CachingAssetBundle {
  // A valid 1x1 pixel transparent PNG file's bytes
  static final Uint8List _transparentPngBytes = Uint8List.fromList([
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
    0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137,
    0, 0, 0, 13, 73, 68, 65, 84, 120, 156, 99, 96, 96, 96, 0, 0,
    0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130
  ]);

  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('.png') || key.endsWith('.jpg') || key.endsWith('.jpeg')) {
      // Return a valid transparent image byte data so that the image decoder succeeds
      return _transparentPngBytes.buffer.asByteData();
    }
    // Load metadata and manifest from the standard rootBundle
    return rootBundle.load(key);
  }
}

void main() {
  testWidgets('Safar Slot home page smoke test', (WidgetTester tester) async {
    // Mock shared preferences to bypass onboarding and login for this smoke test
    SharedPreferences.setMockInitialValues({
      'onboarding_step': 4,
      'is_logged_in': true,
    });

    // Build our app and trigger a frame with a mocked asset bundle.
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: const MyApp(),
      ),
    );
    // Wait for the splash screen animations and transition to complete
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify that location 'Nagpur, MH' is shown.
    expect(find.text('Nagpur, MH'), findsOneWidget);

    // Verify that 'Search Trains' header/button is shown.
    expect(find.text('Search Trains'), findsAtLeastNWidgets(2)); // Card title + Button text

    // Verify that 'Quick Actions' section is shown.
    expect(find.text('Quick Actions'), findsOneWidget);
  });

  testWidgets('Safar Slot onboarding redirection test', (WidgetTester tester) async {
    // Mock empty initial values (first launch)
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame with a mocked asset bundle.
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: const MyApp(),
      ),
    );
    // Wait for the splash screen animations and transition to complete
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify that the app redirected to the Language Selection Screen
    expect(find.text('Namaste! 🙏'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Safar Slot location step redirection test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_step': 1,
    });

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text('Allow Location Access'), findsWidgets);
    expect(find.text('Not Now'), findsOneWidget);
  });

  testWidgets('Safar Slot notification step redirection test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_step': 2,
    });

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text('Stay Updated, Travel Worry-Free'), findsOneWidget);
    expect(find.text('Not Now'), findsOneWidget);
  });

  testWidgets('Safar Slot login signup redirection test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_step': 3,
    });

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text('Welcome Back! 👋'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Continue with Google'), findsWidgets);
    expect(find.text('Email ID'), findsWidgets);
    expect(find.text('Password'), findsWidgets);
  });

  testWidgets('Safar Slot sign up OTP transition test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_step': 3,
    });

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Tap on the Sign Up tab
    await tester.tap(find.text('Sign Up').first);
    await tester.pumpAndSettle();

    // Verify name field exists
    expect(find.text('Full Name'), findsOneWidget);

    // Enter name, email, password
    final nameField = find.widgetWithText(TextField, 'Full Name');
    await tester.ensureVisible(nameField);
    await tester.enterText(nameField, 'John Doe');

    final emailField = find.widgetWithText(TextField, 'Email ID');
    await tester.ensureVisible(emailField);
    await tester.enterText(emailField, 'john@example.com');

    final passwordField = find.widgetWithText(TextField, 'Password');
    await tester.ensureVisible(passwordField);
    await tester.enterText(passwordField, 'password123');
    await tester.pumpAndSettle();

    // Tap Sign Up button
    final signUpBtn = find.text('Sign Up').last;
    await tester.ensureVisible(signUpBtn);
    await tester.tap(signUpBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify OTP view is shown
    expect(find.text('Email Verification'), findsOneWidget);
    expect(find.text('Verify & Register'), findsOneWidget);
  });

  testWidgets('Safar Slot forgot password flow test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_step': 3,
    });

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Tap forgot password button
    final forgotPasswordBtn = find.text('Forgot Password?');
    await tester.ensureVisible(forgotPasswordBtn);
    await tester.tap(forgotPasswordBtn);
    await tester.pumpAndSettle();

    // Verify Find Account screen
    expect(find.text('Find Account'), findsOneWidget);

    // Enter email and tap Send
    final emailField = find.widgetWithText(TextField, 'Email ID');
    await tester.ensureVisible(emailField);
    await tester.enterText(emailField, 'john@example.com');

    final sendOtpBtn = find.text('Send Reset OTP').last;
    await tester.ensureVisible(sendOtpBtn);
    await tester.tap(sendOtpBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify Reset Password screen
    expect(find.text('Reset Password'), findsWidgets);
    expect(find.text('Confirm Password'), findsOneWidget);
  });

  testWidgets('Safar Slot search trains page navigation and search test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_step': 4,
      'is_logged_in': true,
    });

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Find the Search Trains button on the main dashboard and tap it
    final searchTrainsDashboardBtn = find.widgetWithText(ElevatedButton, 'Search Trains');
    expect(searchTrainsDashboardBtn, findsOneWidget);
    await tester.tap(searchTrainsDashboardBtn);
    await tester.pumpAndSettle();

    // Verify SearchTrainsPage has opened by checking the page title
    expect(find.text('Find trains between stations'), findsOneWidget);
    expect(find.text('Recent Searches'), findsOneWidget);

    // Verify presence of Search Trains button inside SearchTrainsPage
    final innerSearchBtn = find.widgetWithText(ElevatedButton, 'Search Trains');
    expect(innerSearchBtn, findsOneWidget);
    await tester.ensureVisible(innerSearchBtn);
    await tester.pumpAndSettle();

    // Tap the inner Search Trains button to navigate to results
    await tester.tap(innerSearchBtn);
    await tester.pumpAndSettle();

    // Verify TrainResultsPage has opened
    expect(find.text('Fastest'), findsOneWidget);
    expect(find.text('Cheapest'), findsOneWidget);
    expect(find.text('SL'), findsWidgets);
  });
}

