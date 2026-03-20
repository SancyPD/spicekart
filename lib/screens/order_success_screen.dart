import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'package:spicekart/services/api_service.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'hot_food_screen.dart';
import 'cart_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  int _currentIndex = 0; // Home is at index 0
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartCount();
    _fetchCartCount();
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
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // White Card Container
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Chili Pepper Character
                          Image.asset(
                            'assets/images/success.png', // Assuming the success image is named success.png
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if image doesn't exist
                              return Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  size: 80,
                                  color: Colors.red,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // Green Checkmark Icon
                          Container(
                            width: 37,
                            height: 37,
                            decoration: const BoxDecoration(
                              color: Color(0xFF61CF7E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Thank You Message
                          const Text(
                            'Thank You!',
                            style: TextStyle(
                              color: const Color(0xFF323C42),
                              fontSize: 22,
                              fontFamily: 'ITC Avant Garde Gothic Pro',
                              fontWeight: FontWeight.w600,
                              height: 1.30,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Order Status
                          const Text(
                            'Your Order Has Been Placed',
                            style: TextStyle(
                              color: const Color(0xFF4D555C),
                              fontSize: 16,
                              fontFamily: 'ITC Avant Garde Gothic Pro',
                              fontWeight: FontWeight.w500,
                              height: 1.30,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Confirmation Note
                          const Text(
                            'Confirmation Will Be Sent To Your Phone',
                            style: TextStyle(
                              color: const Color(0xFF4D555C),
                              fontSize: 16,
                              fontFamily: 'ITC Avant Garde Gothic Pro',
                              fontWeight: FontWeight.w500,
                              height: 1.30,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          // Delivery Information Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9FDFD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: OvalBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: const Color(0x9338424A),
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/box.png',
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.inventory_2,
                                          color: Color(0xFF4D555C),
                                          size: 24,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                        color: Color(0xFF4D555C),
                                        fontSize: 14,
                                        fontFamily: 'ITC Avant Garde Gothic Pro',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: 'Order will be delivered at '),
                                        TextSpan(
                                          text: 'Bagby, Houston, TX, 77002',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(text: ' today before 6 PM'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Continue Shopping Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to home screen
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.instance.mutedBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'CONTINUE SHOPPING',
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
                    const SizedBox(height: 32),
                  ],
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
                if (_currentIndex != index) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                }
              } else if (index == 1) {
                // Categories icon tapped
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoriesScreen()),
                  (route) => false,
                );
              } else if (index == 2) {
                // Hot food icon tapped
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HotFoodScreen()),
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
}

