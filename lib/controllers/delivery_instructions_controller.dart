import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spicekart/controllers/cart_controller.dart';
import '../services/api_service.dart';
import '../screens/main_screen.dart';
import '../screens/home_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/hot_food_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/usual_items_screen.dart';
import 'checkout_controller.dart';
import 'main_controller.dart';
import '../screens/add_edit_address_screen.dart';
import '../screens/user_address_list_screen.dart';
import '../screens/checkout_screen.dart';
import '../model/property_types.dart' as pt;

class DeliveryInstructionsController extends GetxController {
  final bool isInitialFlow;
  DeliveryInstructionsController({this.isInitialFlow = false});

  final currentIndex = 4.obs;
  final selectedPropertyType = 'House'.obs;
  final selectedDropoffLocation = 'Front Door'.obs;
  // final gateCodeController = TextEditingController();
  final deliveryNotesController = TextEditingController();
  final propertyTypes = <pt.Datum>[].obs;
  final selectedPropertyTypeId = 0.obs;
  final isLoading = false.obs;
  final isDeliveryCodeGenerated = false.obs;
  // Removed cartType

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    CartController.to.updateCartCount();
    fetchInitialData();
  }

  void _loadArguments() {
    final args = Get.arguments;
    if (args is Map) {
      if (args.containsKey('isDeliveryCodeGenerated')) {
        isDeliveryCodeGenerated.value = args['isDeliveryCodeGenerated'] == true;
      }
    }
  }

  Future<void> fetchInitialData() async {
    isLoading.value = true;
    try {
      // Fetch property types
      final pTypes = await ApiService.listPropertyTypes();
      if (pTypes != null) {
        propertyTypes.value = pTypes.data;
      }

      // Fetch existing delivery instructions
      final instructions = await ApiService.getDeliveryInstructions();
      if (instructions != null && instructions['status'] == 1) {
        final data = instructions['data'];
        selectedPropertyTypeId.value = data['property_type_id'] ?? 0;
        // gateCodeController.text = data['gate_code'] ?? '';
        deliveryNotesController.text = data['delivery_notes'] ?? '';
        selectedDropoffLocation.value = data['drop_off_location'] ?? 'Front Door';
        if (data['delivery_preference'] != null) {
          isDeliveryCodeGenerated.value = data['delivery_preference'] == 'hand_to_hand';
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // gateCodeController.dispose();
    deliveryNotesController.dispose();
    super.onClose();
  }




  Future<void> saveDeliveryInstructions(BuildContext context) async {

    if (selectedPropertyTypeId.value == 0) {
      Get.snackbar('Alert', 'Please select a Property Type', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // if (deliveryNotesController.text.trim().isEmpty) {
    //   Get.snackbar('Alert', 'Please enter Delivery Notes', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    //   return;
    // }

    if (selectedDropoffLocation.value.isEmpty) {
      Get.snackbar('Alert', 'Please select a Dropoff Location', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // if (gateCodeController.text.trim().isEmpty) {
    //   Get.snackbar('Alert', 'Please enter a Gate or call box Code', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    //   return;
    // }

    isLoading.value = true;
    final String pref = isDeliveryCodeGenerated.value
        ? 'hand_to_hand'
        : 'leave_at_door';

    final success = await ApiService.addDeliveryInstructions(
      propertyTypeId: selectedPropertyTypeId.value,
      gateCode: "",
      deliveryNotes: deliveryNotesController.text,
      dropOffLocation: selectedDropoffLocation.value,
      deliveryPreference: pref,
    );

    if (success) {
      isLoading.value = false;
      if (Get.isRegistered<CheckoutController>()) {
        final checkoutCtrl = Get.find<CheckoutController>();
        checkoutCtrl.isDeliveryCodeGenerated.value = isDeliveryCodeGenerated.value;
      }
      if (isInitialFlow) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CheckoutScreen(),
            settings: RouteSettings(
              arguments: {
                'isDeliveryCodeGenerated': isDeliveryCodeGenerated.value,
              },
            ),
          ),
        );
      } else {
        Navigator.of(context).pop(true);
      }
    } else {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to save delivery instructions',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void onBottomNavTapped(int index) {
    if (Get.isRegistered<MainController>()) {
      MainController.to.changeTab(index);
    } else {
      Get.offAll(() => const MainScreen());
    }
    currentIndex.value = index;
  }
 
}
