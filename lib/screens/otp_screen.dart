import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../utils/app_theme.dart';
import 'subscription_screen.dart';
import 'subscription_agreement_screen.dart';
import 'main_screen.dart';
import 'region_selection_screen.dart';
import '../services/api_service.dart';
import '../controllers/cart_controller.dart';
import 'package:get/get.dart';
import 'login_screen.dart';


class OtpScreen extends StatefulWidget {
  final String phoneOrEmail;

  const OtpScreen({super.key, required this.phoneOrEmail});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _remainingSeconds = 293; // 4:53 in seconds
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _startTimer();
    // Focus on first OTP field when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }

  void _handleOtpInput(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _resendOtp() async {
    if (_remainingSeconds > 0 || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final success = await ApiService.sendOtp(widget.phoneOrEmail);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully!')),
        );
        setState(() {
          _remainingSeconds = 293;
        });
        _startTimer();
        // Clear OTP fields
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send OTP. Please try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp(String otp) async {
    if (otp.length == 6) {
      setState(() {
        _isLoading = true;
      });

      final success = await ApiService.verifyOtp(widget.phoneOrEmail, otp);

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        // Sync cart count after successful login
        if (Get.isRegistered<CartController>()) {
          CartController.to.updateCartCount();
        }

        // Check for pending action FIRST
        if (ApiService.pendingAction != null) {
          final success = await ApiService.executePendingAction();
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successfully!')),
            );
          }
        }

        // COMMENTED: Check for active subscription before deciding where to navigate
        /*
        final subResult = await ApiService.checkActiveSubscription();
        if (subResult['status'] == 1 && subResult['data'] != null) {
          // Already has a subscription, skip Plans and Agreement
          if (ApiService.selectedRegion != null &&
              ApiService.selectedRegion!.isNotEmpty) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(
                    initialRegion: ApiService.selectedRegion!),
              ),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const RegionSelectionScreen(fromHome: false,),
              ),
              (route) => false,
            );
          }
        } else {
          // No active subscription, go to Subscription Plans screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SubscriptionScreen(),
            ),
          );
        }
        */

        // FOR NOW: Skip subscription checking
        if (ApiService.selectedRegion != null &&
            ApiService.selectedRegion!.isNotEmpty) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(
                  initialRegion: ApiService.selectedRegion!),
            ),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const RegionSelectionScreen(fromHome: false,),
            ),
            (route) => false,
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid OTP. Please try again.'),
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black,
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
                        // Back button
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 8, right: 20),
                            child: Text(
                              'Back',
                              style: TextStyle(
                                color: Color(0xFF4D555C),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // One Time Password title
                        const Text(
                          'One Time Password',
                          style: TextStyle(
                            color:  Color(0xFF323C42),
                            fontSize: 30,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                            fontWeight: FontWeight.w600,
                            height: 1.30,
                            letterSpacing: 0.30,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // OTP sent message
                        Column(
                          children: [
                            const Text(
                              "We've send 6 digit otp to",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xff4D555C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                // Handle phone number tap (e.g., edit)
                              },
                              child: Text(
                                widget.phoneOrEmail,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.instance.secondaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Enter OTP here text
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Enter OTP here',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // OTP input boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 50,
                              height: 60,
                              child: TextField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: TextStyle(
                                  color: const Color(0xFF475057),
                                  fontSize: 18,
                                  fontFamily: 'ITC Avant Garde Gothic Pro',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.36,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppTheme.instance.secondaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  if (value.length > 1) {
                                    // Handle paste or multiple characters
                                    _otpControllers[index].text = value[value.length - 1];
                                  }
                                  _handleOtpInput(index, value);
                                  
                                  // Check for auto-verification
                                  String otp = _otpControllers.map((e) => e.text).join();
                                  if (otp.length == 6) {
                                     _verifyOtp(otp);
                                  }
                                },
                                onTap: () {
                                  _otpControllers[index].selection =
                                      TextSelection.fromPosition(
                                    TextPosition(offset: _otpControllers[index].text.length),
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 32),
                        // Resend code section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Didn't Receive?",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            Expanded(child: const SizedBox(width: 8)),
                            GestureDetector(
                              onTap: _remainingSeconds > 0 || _isLoading
                                  ? null
                                  : _resendOtp,
                              child: Text(
                                'Resend code',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _remainingSeconds > 0 || _isLoading
                                      ? Colors.grey.shade400
                                      : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Timer
                        Text(
                          'OTP expires in ${_formatTime(_remainingSeconds)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // GET STARTED button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              String otp = _otpControllers
                                  .map((controller) => controller.text)
                                  .join();
                              _verifyOtp(otp);
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.instance.secondaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
                                    'GET STARTED',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
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
    ));
  }
}