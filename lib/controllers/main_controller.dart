import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/theme_controller.dart';

class MainController extends GetxController {
  static MainController get to => Get.find();

  final currentIndex = 0.obs;
  final tabHistory = <int>[0].obs;
  final categoriesRefreshTick = 0.obs;

  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void changeTab(int index) {
    if (currentIndex.value == index) {
      // If tapping same tab, pop to root
      navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      if (index == 0) HomeController.to.refreshData();
      if (index == 1) categoriesRefreshTick.value++;
      if (index == 4) CartController.to.triggerRefresh();
      return;
    }

    currentIndex.value = index;
    if (index == 0) HomeController.to.refreshData();
    if (index == 1) categoriesRefreshTick.value++;
    if (index == 4) CartController.to.triggerRefresh();
    
    // Check for theme updates on tab change
    ThemeController.to.checkThemeOnNavigation();
    
    // Manage history
    tabHistory.remove(index);
    tabHistory.add(index);
  }

  Future<bool> handleBack(BuildContext context) async {
    final index = currentIndex.value;
    final navigatorState = navigatorKeys[index].currentState;

    if (navigatorState != null && navigatorState.canPop()) {
      navigatorState.pop();
      return false;
    }

    if (tabHistory.length > 1) {
      tabHistory.removeLast();
      currentIndex.value = tabHistory.last;
      return false;
    }

    if (currentIndex.value != 0) {
      currentIndex.value = 0;
      tabHistory.clear();
      tabHistory.add(0);
      return false;
    }

    // On home tab and no history, show exit dialog
    return await _showExitDialog(context);
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              SystemNavigator.pop();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
