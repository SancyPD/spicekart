import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'package:spicekart/services/api_service.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'hot_food_screen.dart';
import 'cart_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int _currentIndex = 0; // Home is at index 0
  String? _selectedPaymentMethod;
  int _cartCount = 0;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Master Card',
      'logo': 'mastercard', // We'll use icon or text for now
      'details': '7463 8472 8472 435',
      'type': 'card',
    },
    {
      'name': 'Visa',
      'logo': 'visa',
      'details': 'Not Registered',
      'type': 'card',
    },
    {
      'name': 'Paypal',
      'logo': 'paypal',
      'details': 'feliceayase@gmail.com',
      'type': 'paypal',
    },
    {
      'name': 'Apple Pay',
      'logo': 'apple',
      'details': '7463 8472 8472 435',
      'type': 'apple',
    },
    {
      'name': 'Google Pay',
      'logo': 'google',
      'details': '7463 8472 8472 435',
      'type': 'google',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchCartCount();
    _fetchCartCount();
  }

  Widget _buildPaymentMethodLogo(String logoType) {
    switch (logoType.toLowerCase()) {
      case 'mastercard':
        return Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [Colors.red.shade700, Colors.orange.shade600],
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-6, 0),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case 'visa':
        return Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.blue.shade900,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'VISA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      case 'paypal':
        return Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'PayPal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case 'apple':
        return Container(
          width: 40,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.apple, color: Colors.white, size: 20),
        );
      case 'google':
        return Container(
          width: 40,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue,
                    Colors.green,
                    Colors.yellow,
                    Colors.red,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      default:
        return Container(
          width: 40,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
    }
  }

  Future<void> _fetchCartCount() async {
    final count = await ApiService.getCartCount();
    setState(() {
      _cartCount = count;
    });
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
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
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
                    const SizedBox(height: 8),
                    // Title
                    const Text(
                      'Checkout',
                      style: TextStyle(
                        color: Color(0xFF4D555C),
                        fontSize: 16,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                        height: 1.30,
                        letterSpacing: -0.48,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Payment Method Title
                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            color: Color(0xFF4D555C),
                            fontSize: 18,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                            fontWeight: FontWeight.w600,
                            height: 1.30,
                            letterSpacing: -0.18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Payment Methods List
                        ...List.generate(_paymentMethods.length, (index) {
                          final method = _paymentMethods[index];
                          return _buildPaymentMethodCard(method, index);
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              // NEXT Button (Fixed at bottom)
              Container(
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedPaymentMethod != null
                          ? () {
                              Navigator.pop(context, _selectedPaymentMethod);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.instance.mutedBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'NEXT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom Navigation Bar
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index == 0) {
                  // Home icon tapped
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                } else if (index == 1) {
                  // Categories icon tapped
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesScreen(),
                    ),
                    (route) => false,
                  );
                } else if (index == 2) {
                  // Hot food icon tapped
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HotFoodScreen(),
                    ),
                    (route) => false,
                  );
                } else if (index == 4) {
                  // Cart icon tapped
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                    (route) => false,
                  );
                } else {
                  setState(() {
                    _currentIndex = index;
                  });
                }
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.instance.mutedBlue,
              unselectedItemColor: Colors.grey,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view),
                  label: 'Categories',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant),
                  label: 'Hot food',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.refresh),
                  label: 'Usuals',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Icon(Icons.shopping_cart),
                      if (_cartCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              _cartCount > 9 ? '9+' : '$_cartCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Cart',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method['name'];
        });
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: index < _paymentMethods.length - 1 ? 12 : 0,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Logo
            SizedBox(
              width: 50,
              height: 30,
              child: _buildPaymentMethodLogo(method['logo'] as String),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    method['name'] as String,
                    style: TextStyle(
                      color: const Color(0xFF4D555C),
                      fontSize: 16,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method['details'] as String,
                    style: TextStyle(
                      color: const Color(0xFF7F858A),
                      fontSize: 14,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      fontWeight: FontWeight.w500,
                      height: 1.71,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Radio Button
            SizedBox(
              width: 24,
              height: 24,
              child: Radio<String>(
                value: method['name'] as String,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
                activeColor: AppTheme.instance.mutedBlue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
