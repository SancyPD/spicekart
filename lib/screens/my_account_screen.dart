import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../controllers/main_controller.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'wishlist_screen.dart';
import 'order_history_screen.dart';
import 'package:get/get.dart';
import 'subscription_screen.dart';
import 'active_subscription_screen.dart';
import 'personal_info_screen.dart';
import 'terms_conditions_screen.dart';
import 'privacy_policy_screen.dart';
import 'preference_screen.dart';
import 'payment_method_screen.dart';
import '../model/profile_response.dart' as pr;
import 'package:shared_preferences/shared_preferences.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  bool _isLoggedIn = false; // Change to true when user logs in
  pr.Data? _userProfile;
  String? _cachedFirstName;
  String? _cachedEmail;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = ApiService.accessToken != null;
    if (_isLoggedIn) {
      _loadCachedProfile();
      _fetchProfile();
    }
  }

  Future<void> _loadCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _cachedFirstName = prefs.getString('user_first_name');
        _cachedEmail = prefs.getString('user_email');
      });
    }
  }

  Future<void> _fetchProfile() async {
    final profile = await ApiService.getProfile();
    if (mounted) {
      setState(() {
        _userProfile = profile?.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
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
                      ),
                      // const Text(
                      //   'Profile',
                      //   style: TextStyle(
                      //     color: Color(0xFF4D555C),
                      //     fontSize: 18,
                      //     fontFamily: 'ITC Avant Garde Gothic Pro',
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      if (_isLoggedIn)
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _showLogoutDialog,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
                              child: Image.asset(
                                'assets/images/logout.png',
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_isLoggedIn && (_userProfile != null || _cachedFirstName != null)) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Hi ${_userProfile?.firstName ?? _cachedFirstName}',
                      style: const TextStyle(
                        color: Color(0xFF171717),
                        fontSize: 20,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if ((_userProfile?.email ?? _cachedEmail ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _userProfile?.email ?? _cachedEmail!,
                        style: const TextStyle(
                          color: Color(0xFF4D555C),
                          fontSize: 12,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            // Content
            Expanded(
              child: Container(
                color: Colors.grey.shade100,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (!_isLoggedIn) _buildBeforeLoginCard(),
                    if (_isLoggedIn) ...[
                      _buildAfterLoginCard(),
                      const SizedBox(height: 16),
                    ],
                    if (!_isLoggedIn) const SizedBox(height: 16),
                    _buildMenuCard(),
                  ],
                ),
              ),
            ),
          ),
          Container(color: Colors.grey.shade100, height: 16),
            // Footer at bottom
            Container(
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  _buildFooter(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildBeforeLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Profile Icon
          GestureDetector(
            onTap: () {
              Get.offAll(() => const LoginScreen());
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.instance.mutedColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Login / Sign up Text
          GestureDetector(
            onTap: () {
              Get.offAll(() => const LoginScreen());
            },
            child: const Text(
              'Login / Sign up',
              style: TextStyle(
                color: Color(0xFF4D555C),
                fontSize: 18,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Sign up Text
          GestureDetector(
            onTap: () {
              Get.offAll(() => const LoginScreen());
            },
            child: const Text(
              'Don\'t have an Account? Sign up',
              style: TextStyle(
                color: Color(0xFF7F858A),
                fontSize: 14,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAfterLoginCard() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.description_outlined,
            title: 'Order history',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.favorite_outline,
            title: 'My Wishlist',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.instance.mutedColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF4D555C),
                fontSize: 12,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _isLoggedIn
            ? [
                _buildMenuItemWithIcon(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Account',
                  onTap: () {
                    // Navigate to Account
                  },
                ),
                _buildMenuItemWithIcon(
                  icon: Icons.payment_outlined,
                  title: 'Payment',
                  onTap: () {
                    Get.to(() => const PaymentMethodScreen());
                  },
                ),
                /*
                _buildMenuItemWithIcon(
                  icon: Icons.subscriptions_outlined,
                  title: 'Subscription',
                  onTap: () async {
                    // Show loading dialog
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );

                    // Call API
                    final response = await ApiService.checkActiveSubscription();

                    // Hide loading dialog
                    if (Get.isDialogOpen ?? false) {
                      Get.back();
                    }

                    if (response['data'] == null) {
                      // No active subscription, show plans
                      Get.to(() => const SubscriptionScreen(isFromMyAccount: true));
                    } else {
                      // Active subscription found, show details screen
                      Get.to(() => ActiveSubscriptionScreen(
                        subscriptionData: response['data'],
                      ));
                    }
                  },
                ),
                */
                _buildMenuItemWithIcon(
                  icon: Icons.person_outline,
                  title: 'Personal info',
                  onTap: () async {
                    await Get.to(() => const PersonalInfoScreen());
                    _loadCachedProfile();
                    _fetchProfile();
                  },
                ),
                _buildMenuItemWithIcon(
                  icon: Icons.sync_outlined,
                  title: 'Preferences',
                  onTap: () {
                    Get.to(() => const PreferenceScreen());
                  },
                ),
                /*_buildMenuItemWithIcon(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    // Navigate to Settings
                  },
                ),*/
                _buildMenuItem(
                  assetPath: 'assets/images/terms.png',
                  title: 'Terms & Conditions',
                  onTap: () {
                    Get.to(() => const TermsConditionsScreen());
                  },
                ),
                _buildMenuItem(
                  assetPath: 'assets/images/privacy.png',
                  title: 'Privacy policy',
                  onTap: () {
                    Get.to(() => const PrivacyPolicyScreen());
                  },
                ),
              ]
            : [
                _buildMenuItem(
                  assetPath: 'assets/images/faqs.png',
                  title: 'FAQs',
                  onTap: () {
                    // Navigate to FAQs
                  },
                ),
                _buildMenuItem(
                  assetPath: 'assets/images/terms.png',
                  title: 'Terms & Conditions',
                  onTap: () {
                    Get.to(() => const TermsConditionsScreen());
                  },
                ),
                _buildMenuItem(
                  assetPath: 'assets/images/privacy.png',
                  title: 'Privacy policy',
                  onTap: () {
                    Get.to(() => const PrivacyPolicyScreen());
                  },
                ),
              ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String assetPath,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Image.asset(
              assetPath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF4D555C),
                  fontSize: 14,
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0x4D555CD5)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemWithIcon({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4D555C), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF4D555C),
                  fontSize: 14,
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0x4D555CD5)),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure to Logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Okay'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _handleLogout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    // Optional: Show loading indicator here if the API takes time
    await ApiService.logout();
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
      });
      Get.offAll(() => const LoginScreen());
    }
  }

  Widget _buildFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (Get.isRegistered<MainController>()) {
              MainController.to.changeTab(0);
            }
            Get.back(); // Pop MyAccountScreen
            // If there's more than one screen on the stack, pop until first
            Get.until((route) => route.isFirst);
          },
          child: Center(
            child: Image.asset(
              'assets/images/logo_horizontal.png',
              fit: BoxFit.contain,
              height: 45,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Version
        Center(
          child: const Text(
            'Version 1.0',
            style: TextStyle(
              color:  Color(0xFF4D555C),
              fontSize: 14,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
