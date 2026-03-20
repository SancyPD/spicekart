import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'subscription_agreement_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _selectedPlan = 'executive'; // 'executive' or 'value'

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEFEC),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
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
                          const Spacer(),
                        ],
                      ),
                    ),

                    // Top section with gradient background
                    Container(
                      padding: EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.instance.tertiaryCyan,
                            AppTheme.instance.mutedBlue,
                            AppTheme.instance.primaryDeepBlue,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Select A Subscription Plan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // 90 Days Free Trial Section
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0x78000000),
                                // 47% opacity of black
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Banner
                                  Container(
                                    width:double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.instance.tertiaryCyan,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: const Text(
                                        'You Get The Access To Executive Plan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: const Color(0xFF062B0A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Free Trial Text
                                  RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                      children: [
                                        TextSpan(text: '90 Days '),
                                        TextSpan(
                                          text: 'Free Trial',
                                          style: TextStyle(
                                            color: Color(0xFFFFD700), // Yellow
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Unlimited FREE Deliveries With No Minimum Purchase Required.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    textAlign: TextAlign.center,
                                    'Enjoy 90 days of executive membership absolutely free! get access to premium benefits including unlimited free deliveries and exclusive rewards. no commitment required — your membership will automatically continue as an executive membership after the trial period unless cancelled.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Start Free Trial Button
                                  /*   SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RegionSelectionScreen(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.instance.mutedBlue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'START FREE TRIAL',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),*/
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 100), // Overlap space
                        ],
                      ),
                    ),
                    // White rectangle that overlaps the gradient (Select The Best Option section)
                    Transform.translate(
                      offset: const Offset(0, -100), // Overlap by 100px
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 20,
                          left: 24,
                          right: 24,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            // Select The Best Option Title
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                'Select The Best Option For You',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4D555C),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Plan Selection Cards
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Row(
                                children: [
                                  // Executive Plan Card
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedPlan = 'executive';
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: _selectedPlan == 'executive'
                                                ? AppTheme.instance.mutedBlue
                                                : const Color(0xFFAEC1CC),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          boxShadow:
                                              _selectedPlan == 'executive'
                                              ? [
                                                  BoxShadow(
                                                    color: AppTheme.instance.mutedBlue.withValues(alpha: 0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              _selectedPlan == 'executive'
                                                  ? 'assets/images/selected_badge.png'
                                                  : 'assets/images/unselected_badge.png',
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Executive',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF4D555C),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Premium plan',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF999999),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '\$39.99',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey.shade400,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  '\$19.99',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF4D555C),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Per month',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF999999),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Value Plan Card
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedPlan = 'value';
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: _selectedPlan == 'value'
                                                ? AppTheme.instance.mutedBlue
                                                : const Color(0xFFAEC1CC),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          boxShadow: _selectedPlan == 'value'
                                              ? [
                                                  BoxShadow(
                                                    color: AppTheme.instance.mutedBlue.withValues(alpha: 0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              _selectedPlan == 'value'
                                                  ? 'assets/images/selected_badge.png'
                                                  : 'assets/images/unselected_badge.png',
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Value',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF4D555C),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Essential plan',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF999999),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '\$19.99',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey.shade400,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  '\$9.99',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF4D555C),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Per month',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF999999),
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
                            const SizedBox(height: 24),
                            // Executive Membership Details
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  _selectedPlan == 'executive'
                                      ? 'Executive Membership'
                                      : 'Value Membership',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4D555C),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Early Bird Deal
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xff9DA3A8)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _selectedPlan == 'executive'
                                      ? '\$19.99/month or \$229/Year (Early Bird Deal)'
                                      : '\$119.88/month ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF323C42),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                'Designed for our most active and loyal customers, this tier offers the best value and premium perks.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF4D555C),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Benefits List Container
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE4F3FF),
                                  border: Border.all(
                                    color: const Color(0xFFB9CFDF),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'All Value Membership benefits plus:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFF485058),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildBenefitItem(
                                      'Unlimited Free Deliveries — no minimum purchase require',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildBenefitItem(
                                      '\$2 Cashback for every \$100 you spend',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildBenefitItem(
                                      'Free seasonal gift hampers (may include luxury goodies, home essentials, or surprise bundles)',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildBenefitItem(
                                      'Complimentary vouchers for movies, concerts, and special events throughout the year',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildBenefitItem(
                                      'Early access to exclusive deals and coupons',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildBenefitItem(
                                      'Birthday and anniversary surprises to make your special days even more memorable Experience shopping with the convenience, rewards, and luxury you deserve.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Subscribe Button (Fixed at bottom)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(color: Color(0xFFEBEFEC)),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showFreeTrialCupertinoAlert(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.instance.secondaryLightBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'SUBSCRIBE',
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

  void showFreeTrialCupertinoAlert(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: const Text(
            "You will get 90 days free trial of executive plans.",
            textAlign: TextAlign.center,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionAgreementScreen(),
                  ),
                );
              },
              child: const Text("Okay"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBenefitItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF485058),
            ),
          ),
        ),
      ],
    );
  }
}
