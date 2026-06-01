import 'package:get/get.dart';
import 'package:spicekart/controllers/cart_controller.dart';
import '../services/api_service.dart';
import '../screens/home_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/hot_food_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/usual_items_screen.dart';
import '../screens/main_screen.dart';
import 'main_controller.dart';

class OrderSuccessController extends GetxController {
  final currentIndex = 0.obs;
  final deliveryAddress = ''.obs;
  final deliveryDate = 'today'.obs;
  final deliverySlot = 'before 6 PM'.obs;

  @override
  void onInit() {
    super.onInit();
    CartController.to.updateCartCount();
    if (Get.arguments is Map) {
      final args = Get.arguments as Map;
      deliveryAddress.value = args['address']?.toString() ?? '';
      deliveryDate.value = args['deliveryDate']?.toString() ?? 'today';
      deliverySlot.value = args['deliverySlot']?.toString() ?? 'before 6 PM';
    } else if (Get.arguments is String) {
      deliveryAddress.value = Get.arguments;
    }
  }


  void onBottomNavTapped(int index) {
    Get.offAll(
      () => MainScreen(initialRegion: ApiService.selectedRegion),
    );
    // After stack reset, ensure the correct tab is selected
    if (Get.isRegistered<MainController>()) {
      MainController.to.changeTab(index);
    }
    currentIndex.value = index;
  }

  void continueShopping() {
    Get.offAll(
      () => MainScreen(initialRegion: ApiService.selectedRegion),
    );
    // Explicitly set to Home tab (index 0)
    Future.microtask(() {
      if (Get.isRegistered<MainController>()) {
        MainController.to.changeTab(0);
      }
    });
  }
}
