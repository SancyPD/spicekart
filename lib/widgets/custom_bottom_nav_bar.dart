import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spicekart/controllers/main_controller.dart';
import '../utils/app_theme.dart';
import '../controllers/cart_controller.dart';
import '../screens/home_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/hot_food_screen.dart';
import '../screens/usual_items_screen.dart';
import '../screens/cart_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppTheme.instance,
      builder: (context, _) {
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
        bottom: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex > 4 ? 1 : currentIndex, // Highlight Categories if on CategoryScreen
          onTap: (index) {
            MainController.to.changeTab(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.instance.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Categories'),
            const BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Hot food'),
            const BottomNavigationBarItem(icon: Icon(Icons.refresh), label: 'Usuals'),
            BottomNavigationBarItem(
              icon: Obx(() {
                final cartCount = CartController.to.cartCount.value;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (cartCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            cartCount > 99 ? '99+' : '$cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }),
              label: 'Cart',
            ),
          ],
        ),
      ),
        );
      },
    );
  }
}
