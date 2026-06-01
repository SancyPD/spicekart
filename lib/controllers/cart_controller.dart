import 'package:get/get.dart';
import '../services/api_service.dart';

class CartController extends GetxController {
  static CartController get to => Get.find();

  final RxInt cartCount = 0.obs;
  final RxInt refreshSignal = 0.obs;

  @override
  void onInit() {
    super.onInit();
    updateCartCount();
  }

  void triggerRefresh() {
    refreshSignal.value++;
  }

  Future<void> updateCartCount() async {
    try {
      final count = await ApiService.getCartCount();
      cartCount.value = count;
    } catch (e) {
      print('Error updating cart count: $e');
    }
  }
}
