import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'package:spicekart/screens/region_selection_screen.dart';
import 'package:spicekart/screens/subscription_screen.dart';
import '../screens/otp_screen.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Set system status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _navigateToOtp() async {
    if (_phoneController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      String input = _phoneController.text.trim();
      String phoneOrEmail = input;
      bool isValid = false;

      // Simple check to distinguish email from phone
      // If it contains '@', assume email. Otherwise assume phone.
      if (input.contains('@')) {
        // Email validation (basic)
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (emailRegex.hasMatch(input)) {
          isValid = true;
          phoneOrEmail = input;
        }
      } else {
        // Phone validation
        // Remove any non-digits mostly, but here we expect user might type +91
        if (input.startsWith('+91')) {
          if (input.length == 13) {
            // +91 + 10 digits
            isValid = true;
            phoneOrEmail = input;
          }
        } else {
          // Assume 10 digit number
          if (RegExp(r'^\d{10}$').hasMatch(input)) {
            isValid = true;
            phoneOrEmail = '+91$input';
          }
        }
      }

      if (isValid) {
        final success = await ApiService.sendOtp(phoneOrEmail);

        setState(() {
          _isLoading = false;
        });

        if (success && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(phoneOrEmail: phoneOrEmail),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send OTP. Please try again.'),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter a valid phone number or email address.',
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number or email.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Main content area (white background)
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Back button (only show if there's a previous route)
                        if (Navigator.canPop(context))
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  color: Color(0xFF4D555C),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        if (Navigator.canPop(context))
                          const SizedBox(height: 20),
                        // Namaste icon
                        Image.asset(
                          'assets/images/namaste_ic.png',
                          height: 120,
                          width: 120,
                        ),
                        const SizedBox(height: 24),

                        // To Get Started text
                        const Text(
                          'To Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xff4D555C),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Mobile number input
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.mobile_friendly,
                                color: Colors.grey,
                              ),
                              hintText: 'Mobile(e.g. +919876543210) / Email',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              hintStyle: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // SEND OTP button
                        GestureDetector(
                          onTap: _navigateToOtp,
                          child: Container(
                            width: double.infinity,
                            height: 65,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 24,
                            ),
                            decoration: ShapeDecoration(
                              color: AppTheme.instance.secondaryLightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'SEND OTP',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'ITC Avant Garde Gothic Pro',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Continue as Guest divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white)),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegionSelectionScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'Continue as Guest',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Google Sign In button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              // Handle Google sign in
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/g_logo.png',
                                      fit: BoxFit.contain,
                                      height: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Apple Sign In button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              // Handle Apple sign in
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.apple,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Sign in with Apple',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Terms and Privacy text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'By Continuing, You Agree To Our Terms Of Service And Privacy Policy',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom logo area (black background)
            Container(
              height: 96,
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 40),
              child: Center(
                child: Image.asset(
                  'assets/images/logo_horizontal.png',
                  fit: BoxFit.contain,
                  height: 55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
