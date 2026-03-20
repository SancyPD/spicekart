import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'wishlist_screen.dart';
import 'order_history_screen.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  bool _isLoggedIn = false; // Change to true when user logs in

  @override
  void initState() {
    super.initState();
    _isLoggedIn = ApiService.accessToken != null;
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
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Align(
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
            ),
            // Content
            Expanded(
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
                    if (_isLoggedIn) ...[
                      const SizedBox(height: 10),
                      _buildLogOutButton(),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Footer at bottom
            _buildFooter(),
            const SizedBox(height: 16),
          ],
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.instance.mutedBlue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          // Login / Sign up Text
          const Text(
            'Login / Sign up',
            style: TextStyle(
              color: Color(0xFF4D555C),
              fontSize: 18,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // Sign up Text
          GestureDetector(
            onTap: () {
              setState(() {
                _isLoggedIn = true;
              });
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
                color: AppTheme.instance.mutedBlue,
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
                    // Navigate to Payment
                  },
                ),
                _buildMenuItemWithIcon(
                  icon: Icons.subscriptions_outlined,
                  title: 'Subscription',
                  onTap: () {
                    // Navigate to Subscription
                  },
                ),
                _buildMenuItemWithIcon(
                  icon: Icons.person_outline,
                  title: 'Personal info',
                  onTap: () {
                    // Navigate to Personal info
                  },
                ),
                _buildMenuItemWithIcon(
                  icon: Icons.sync_outlined,
                  title: 'Preferences',
                  onTap: () {
                    // Navigate to Preferences
                  },
                ),
                _buildMenuItemWithIcon(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    // Navigate to Settings
                  },
                ),
                _buildMenuItem(
                  assetPath: 'assets/images/terms.png',
                  title: 'Terms & Conditions',
                  onTap: () {
                    // Navigate to Terms & Conditions
                  },
                ),
                _buildMenuItem(
                  assetPath: 'assets/images/privacy.png',
                  title: 'Privacy policy',
                  onTap: () {
                    // Navigate to Privacy policy
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
                    // Navigate to Terms & Conditions
                  },
                ),
                _buildMenuItem(
                  assetPath: 'assets/images/privacy.png',
                  title: 'Privacy policy',
                  onTap: () {
                    // Navigate to Privacy policy
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildLogOutButton() {
    return InkWell(
      onTap: _showLogoutDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Log Out',
              style: TextStyle(
                color: AppTheme.instance.mutedBlue,
                fontSize: 16,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              color: AppTheme.instance.mutedBlue,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Logo with Chili Pepper
        Image.asset(
          'assets/images/logo_horizontal.png',
          fit: BoxFit.contain,
          height: _isLoggedIn ? 45: 68,
        ),
        const SizedBox(height: 8),
        // Version
        const Text(
          'Version 1.0',
          style: TextStyle(
            color:  Color(0xFF4D555C),
            fontSize: 14,
            fontFamily: 'ITC Avant Garde Gothic Pro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
