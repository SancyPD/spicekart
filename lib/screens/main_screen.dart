import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'hot_food_screen.dart';
import 'usual_items_screen.dart';
import 'cart_screen.dart';

class MainScreen extends StatelessWidget {
  final String? initialRegion;
  
  const MainScreen({super.key, this.initialRegion});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainController());
    Get.put(HomeController());

    final List<Widget> tabs = [
      _buildTabNavigator(controller, 0, HomeScreen(selectedRegion: initialRegion ?? '')),
      _buildTabNavigator(controller, 1, const CategoriesScreen()),
      _buildTabNavigator(controller, 2, const HotFoodScreen()),
      _buildTabNavigator(controller, 3, const UsualItemsScreen()),
      _buildTabNavigator(controller, 4, const CartScreen()),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await controller.handleBack(context);
        if (shouldExit) {
          // Use SystemNavigator.pop() to exit the app safely.
          // Navigator.of(context).pop() would crash when MainScreen is the
          // root of the navigator stack (e.g. after Get.offAll()).
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Obx(() => IndexedStack(
          index: controller.currentIndex.value,
          children: tabs,
        )),
        bottomNavigationBar: Obx(() => CustomBottomNavBar(
          currentIndex: controller.currentIndex.value,
        )),
      ),
    );
  }

  Widget _buildTabNavigator(MainController controller, int index, Widget root) {
    return Navigator(
      key: controller.navigatorKeys[index],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => root,
        );
      },
    );
  }
}
