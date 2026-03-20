import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import '../services/api_service.dart';
import 'categories_screen.dart';

class HotFoodScreen extends StatefulWidget {
  const HotFoodScreen({super.key});

  @override
  State<HotFoodScreen> createState() => _HotFoodScreenState();
}

class _HotFoodScreenState extends State<HotFoodScreen> {
  int _currentIndex = 2; // Hot food is index 2
  int? _selectedRestaurantIndex; // Track selected restaurant
  int _cartCount = 0;

  // Sample restaurant data
  final List<Map<String, dynamic>> _restaurants = [
    {
      'name': 'Aga\'s Restaurant Menu',
      'address': '11842 Wilcrest Dr, Houston, TX',
      'image': 'assets/images/hot_food_img.png',
    },
    {
      'name': 'Kiran\'s',
      'address': '2925 Richmond Ave. Suite 160, Houston, TX',
      'image': 'assets/images/hot_food_img.png',
    },
    {
      'name': 'Bombay Brasserie',
      'address': '123 Main St, Houston, TX',
      'image': 'assets/images/hot_food_img.png',
    },
  ];

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
           /* Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
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
                          color:  Color(0xFF0C4112),
                          fontSize: 16,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w600,
                          height: 1.30,
                          letterSpacing: -0.48,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                ],
              ),
            ),*/
            // Restaurant List
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Top Indian Restaurants In Houston',
                    style: TextStyle(
                      color:  Color(0xFF4D555C),
                      fontSize: 22,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      fontWeight: FontWeight.w500,
                      height: 1.30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _restaurants.length,
                      itemBuilder: (context, index) {
                        return _buildRestaurantCard(_restaurants[index], index);
                      },
                    ),
                  ),
                ],
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
                  MaterialPageRoute(builder: (context) => const CategoriesScreen()),
                  (route) => false,
                );
              } else if (index == 2) {
                // Hot food icon tapped
                if (_currentIndex != index) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HotFoodScreen()),
                    (route) => false,
                  );
                }
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
      ),)
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant, int index) {
    final isSelected = _selectedRestaurantIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          // Toggle selection - if already selected, deselect; otherwise select
          _selectedRestaurantIndex = _selectedRestaurantIndex == index ? null : index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.instance.lightBlueBg // Light blue background for selected
              : Colors.white, // White background for unselected
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Restaurant Image
              Stack(
                children: [
                  Image.asset(
                    restaurant['image'] as String,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),


                ],
              ),

              if(isSelected) Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.instance.secondaryLightBlue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurant['address'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'ITC Avant Garde Gothic Pro',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),


              // White background with text (for unselected restaurants)
              if (!isSelected)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant['name'] as String,
                        style: const TextStyle(
                          color: Color(0xFF4D555C),
                          fontSize: 18,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF4D555C),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              restaurant['address'] as String,
                              style: const TextStyle(
                                color: Color(0xFF4D555C),
                                fontSize: 14,
                                fontFamily: 'ITC Avant Garde Gothic Pro',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

