import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'region_selection_screen.dart';

class SubscriptionAgreementScreen extends StatefulWidget {
  const SubscriptionAgreementScreen({super.key});

  @override
  State<SubscriptionAgreementScreen> createState() => _SubscriptionAgreementScreenState();
}

class _SubscriptionAgreementScreenState extends State<SubscriptionAgreementScreen> {
  bool _isAgreed = false;

  @override
  void initState() {
    super.initState();
    // Set system status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Back button
                      if (Navigator.canPop(context))
                        TextButton(
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
                      const SizedBox(height: 24),
                      // Section 1: Subscription agreement
                      const Text(
                        '1.Subscription agreement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF323C42),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'By subscribing to grocery online premium, you agree to pay a recurring subscription fee. The subscription will automatically renew unless cancelled at least 24 hours before the end of the current period.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4D555C),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Section 2: Privacy And Data Collection
                      const Text(
                        '2.Privacy And Data Collection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF323C42),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'We collect and process your personal information, including your name, email address, delivery address, and payment information, to provide you with our services. We also collect usage data to improve your experience. Your data will be handled in accordance with our privacy policy and applicable data protection laws.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4D555C),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Section 3: Delivery Terms
                      const Text(
                        '3.Delivery Terms',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF323C42),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'We collect and process your personal information, including your name, email address, delivery address, and payment information, to provide you with our services. We also collect usage data to improve your experience. Your data will be handled in accordance with our privacy policy and applicable data protection laws.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4D555C),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Section 4: Cancellation Policy
                      const Text(
                        '4.Cancellation Policy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF323C42),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'You can cancel your subscription at any time through your account settings or by contacting customer support. Cancellation will take effect at the end of the current billing period. No refunds will be provided for partial subscription periods.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4D555C),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Checkbox and consent text
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _isAgreed,
                            onChanged: (value) {
                              setState(() {
                                _isAgreed = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF63A6D1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isAgreed = !_isAgreed;
                                  });
                                },
                                child: const Text(
                                  'I agree to the Terms and Conditions and Privacy Policy.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF4D555C),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            // Continue Button (Fixed at bottom)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isAgreed
                        ? () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegionSelectionScreen(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF63A6D1),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

