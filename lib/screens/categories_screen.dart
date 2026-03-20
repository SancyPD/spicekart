import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../model/category_list.dart';
import 'category_screen.dart';
import 'home_screen.dart';
import 'hot_food_screen.dart';
import 'cart_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _currentIndex = 1; // Categories is index 1
  List<Category> _categories = [];
  bool _isLoading = true;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchCartCount();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.listAllCategories();
      if (response != null && response.status == 1) {
        setState(() {
          _categories = response.data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() => _isLoading = false);
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'All Categories',
            style: TextStyle(
              color: Color(0xFF374338),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(_categories[index]);
                },
              ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryScreen(
              categoryId: category.id,
              categoryName: category.categoryName,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.instance.lightBlueBg,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Center(
                child: category.categoryImage != null && category.categoryImage.toString().isNotEmpty
                    ? Image.network(
                        'https://spicekart.mockupz.in/storage/categories/${category.categoryImage}',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, color: Colors.blue),
                      )
                    : const Icon(Icons.category, color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.categoryName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374338),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == _currentIndex) return;
            if (index == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            } else if (index == 1) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const CategoriesScreen()),
                (route) => false,
              );
            } else if (index == 2) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HotFoodScreen()),
                (route) => false,
              );
            } else if (index == 4) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
                (route) => false,
              );
            } else {
              setState(() => _currentIndex = index);
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.instance.mutedBlue,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Categories'),
            const BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Hot food'),
            const BottomNavigationBarItem(icon: Icon(Icons.refresh), label: 'Usuals'),
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
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          _cartCount > 9 ? '9+' : '$_cartCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
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
    );
  }
}
