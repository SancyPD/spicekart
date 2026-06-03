import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spicekart/controllers/cart_controller.dart';
import '../services/api_service.dart';
import '../model/checkout_preview_response.dart';
import '../model/delivery_slots.dart';
import '../screens/home_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/hot_food_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/usual_items_screen.dart';
import '../screens/order_success_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../screens/main_screen.dart';
import 'main_controller.dart';

class CheckoutController extends GetxController {
  final currentIndex = 4.obs;
  final Rx<DeliverySlot?> selectedDeliveryDate = Rx<DeliverySlot?>(null);
  final Rx<Slot?> selectedSlot = Rx<Slot?>(null);
  final selectedDeliverySlot = ''.obs;
  /// `percent` (presets / no tip) or `custom` (flat dollar amount).
  final appliedTipType = 'percent'.obs;
  final appliedPercentTip = 0.obs;
  final appliedCustomTipDollars = Rxn<double>();
  /// Default to Stripe card flow so checkout opens with Credit/Debit selected.
  final Rx<String?> selectedPaymentMethod = Rx<String?>('stripe');

  /// Stripe PaymentMethod id (`pm_...`) when the user selects a saved card.
  final selectedStripePaymentMethodId = Rxn<String>();

  /// Short label for checkout UI, e.g. "Visa ···· 4242".
  final selectedPaymentMethodSummary = Rxn<String>();

  // Removed cartType

  final couponController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final otpController = TextEditingController();

  final isWalletRedeemed = false.obs;
  final isLoading = true.obs;

  final Rx<dynamic> checkoutData = Rx<dynamic>(null);
  final cartItems = <dynamic>[].obs;
  final deliverySlots = <DeliverySlot>[].obs;
  final apiCartCount = 0.obs;

  final isOtpSent = false.obs;
  final isPhoneVerified = false.obs;
  final isVerifyingOtp = false.obs;
  final isDeliveryCodeGenerated = (Get.arguments is Map &&
          Get.arguments.containsKey('isDeliveryCodeGenerated'))
      ? (Get.arguments['isDeliveryCodeGenerated'] == true).obs
      : false.obs;
  final isEditMobileVisible = false.obs;

  final allowSubstitutions = true.obs;
  final refundInsteadOfSubstitution = false.obs;

  void selectAllowSubstitutions() {
    allowSubstitutions.value = true;
    refundInsteadOfSubstitution.value = false;
  }

  void selectRefundInsteadOfSubstitution() {
    refundInsteadOfSubstitution.value = true;
    allowSubstitutions.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    // Use microtask to ensure this doesn't run synchronously during a build phase
    Future.microtask(() => fetchCheckoutPreview());

    // Listen to refresh signal from CartController to refresh checkout screen when user switches back to Cart tab
    ever(CartController.to.refreshSignal, (_) {
      fetchCheckoutPreview();
    });

    // Automatically call generateDeliveryCode when the preference changes, if phone is verified
    /*ever(isDeliveryCodeGenerated, (bool value) {
      if (isPhoneVerified.value) {
        ApiService.generateDeliveryCode(generate: value);
      }
    });*/
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> fetchCheckoutPreview() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        ApiService.checkoutPreview(),
        ApiService.listDeliverySlots(),
        ApiService.getCartCount(),
      ]);

      final dynamic response = results[0];
      final slotsResponse = results[1] as DeliverySlots?;
      final count = results[2] as int;

      apiCartCount.value = count;
      checkoutData.value = response;

      print('DEBUG: Checkout Preview Response Status: ${response?.status}');
      if (response != null && response.data.cart != null) {
        final List<dynamic> responseCartItems = response.data.cart!.cartItems;
        print(
          'DEBUG: Cart Items count in response: ${responseCartItems.length}',
        );
        for (var i = 0; i < responseCartItems.length; i++) {
          final item = responseCartItems[i];
          final String itemName = item.itemType == 'product'
              ? item.item.productName
              : item.item.name;
          print('DEBUG: Item $i: $itemName (ID: ${item.item.id})');
        }
      } else {
        print('DEBUG: response.data.cart is NULL');
      }

      _syncDriverTipFromPreview();

      if (response != null && response.status == 1) {
        final List<dynamic> responseCartItems =
            response.data.cart?.cartItems ?? [];
        cartItems.value = responseCartItems
            .where((item) => item.isSavedForLater == 0)
            .toList();
      } else {
        cartItems.value = [];
      }

      deliverySlots.value = slotsResponse?.data ?? [];

      // Clear current selection and strictly use checkoutPreview response
      selectedDeliveryDate.value = null;
      selectedSlot.value = null;

      final cart = response?.data.cart;
      if (cart != null &&
          cart.deliveryDate != null &&
          cart.deliverySlot != null) {
        final existingDate = deliverySlots.firstWhereOrNull(
          (d) =>
              d.deliveryDate.year == cart.deliveryDate!.year &&
              d.deliveryDate.month == cart.deliveryDate!.month &&
              d.deliveryDate.day == cart.deliveryDate!.day,
        );
        if (existingDate != null) {
          selectedDeliveryDate.value = existingDate;
          // Note: Assuming Slot IDs are consistent across models
          final existingSlot = existingDate.slots.firstWhereOrNull(
            (s) => s.id == cart.deliverySlot!.id,
          );
          if (existingSlot != null) {
            selectedSlot.value = existingSlot;
          }
        }
      }

      if (response != null && response.data.cart != null) {
        final phone = response.data.cart!.checkoutPhone;
        if (phone != null && phone.toString().trim().isNotEmpty) {
          mobileNumberController.text = phone.toString();
        }

      /*  if (response.data.cart!.checkoutPhoneVerifiedAt != null) {
          isPhoneVerified.value = true;
          // Initial sync of delivery preference if already verified
          ApiService.generateDeliveryCode(
            generate: isDeliveryCodeGenerated.value,
          );
        }*/
      }
    } catch (e) {
      print('Error in fetchCheckoutPreview: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtp() async {
    String phone = mobileNumberController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a mobile number',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Basic US phone formatting/validation
    if (phone.startsWith('+1')) {
      if (phone.length != 12) {
        Get.snackbar(
          'Error',
          'Invalid US phone number format. Use +1 followed by 10 digits.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    } else if (phone.length == 10 && RegExp(r'^\d{10}$').hasMatch(phone)) {
      phone = '+1$phone';
    } else if (phone.length == 11 &&
        phone.startsWith('1') &&
        RegExp(r'^\d{11}$').hasMatch(phone)) {
      phone = '+$phone';
    } else {
      Get.snackbar(
        'Error',
        'Please enter a valid 10-digit US mobile number',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    mobileNumberController.text = phone;
    isVerifyingOtp.value = true;
    final result = await ApiService.sendCheckoutPhoneOtp(
      phone: phone,
    );
    isVerifyingOtp.value = false;

    if (result['success'] == true) {
      isOtpSent.value = true;
      Get.snackbar(
        'Success',
        result['message']?.isNotEmpty == true
            ? result['message']
            : 'OTP sent successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      final errorMessage = result['message']?.isNotEmpty == true
          ? result['message']
          : 'Failed to send OTP';
      Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> verifyOtp() async {
    final phone = mobileNumberController.text.trim();
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isVerifyingOtp.value = true;
    final success = await ApiService.verifyCheckoutPhoneOtp(
      phone: phone,
      otp: otp,
    );
    isVerifyingOtp.value = false;
    if (success) {
      isPhoneVerified.value = true;
      isOtpSent.value = false;
      // Trigger delivery code generation as soon as phone is verified
     /* ApiService.generateDeliveryCode(
        generate: isDeliveryCodeGenerated.value,
      );*/
      Get.snackbar(
        'Success',
        'Phone number verified',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar('Error', 'Invalid OTP', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void editMobileNumber() {
    isPhoneVerified.value = false;
    isOtpSent.value = false;
    isEditMobileVisible.value = false;
    otpController.clear();
  }

  void updateQuantity(int cartItemId, String action) async {
    try {
      isLoading.value = true;
      final success = await ApiService.updateCartItem(
        cartItemId: cartItemId,
        action: action,
      );
      if (success) {
        await fetchCheckoutPreview();
        CartController.to.triggerRefresh();
        if (cartItems.isEmpty) {
          if (Get.isRegistered<MainController>()) {
            MainController.to.changeTab(4); // Back to Cart tab
          } else {
            Get.offAll(() => const CartScreen());
          }
        }
      }
    } catch (e) {
      print('Error in updateQuantity: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void deleteCartItem(int cartItemId) async {
    try {
      isLoading.value = true;
      final success = await ApiService.deleteCartItem(
        cartId: cartItemId,
      );
      if (success) {
        await fetchCheckoutPreview();
        CartController.to.triggerRefresh();
        if (cartItems.isEmpty) {
          if (Get.isRegistered<MainController>()) {
            MainController.to.changeTab(4); // Back to Cart tab
          } else {
            Get.offAll(() => const CartScreen());
          }
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete item',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error in deleteCartItem: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _syncDriverTipFromPreview() {
    final response = checkoutData.value;
    if (response == null) {
      appliedTipType.value = 'percent';
      appliedPercentTip.value = 0;
      appliedCustomTipDollars.value = null;
      return;
    }
    final summary = response.data.totalAmountSummary;
    if (summary == null) {
      appliedTipType.value = 'percent';
      appliedPercentTip.value = 0;
      appliedCustomTipDollars.value = null;
      return;
    }

    final apiTipType = summary.tipType?.toLowerCase();
    final pct = summary.tipPercent;
    final tipAmt = summary.tipAmount;

    if (apiTipType == 'custom') {
      appliedTipType.value = 'custom';
      appliedPercentTip.value = 0;
      final custom = summary.customTipAmount;
      appliedCustomTipDollars.value =
          (custom != null && custom > 0) ? custom : (tipAmt > 0 ? tipAmt : null);
      return;
    }

    if (apiTipType == null ||
        apiTipType.isEmpty ||
        apiTipType == 'percent') {
      if (pct == 0 && tipAmt > 0.009) {
        appliedTipType.value = 'custom';
        appliedPercentTip.value = 0;
        appliedCustomTipDollars.value = tipAmt;
        return;
      }
      appliedTipType.value = 'percent';
      appliedPercentTip.value = pct;
      appliedCustomTipDollars.value = null;
      return;
    }

    appliedTipType.value = 'percent';
    appliedPercentTip.value = pct;
    appliedCustomTipDollars.value = null;
  }

  Future<void> applyTipPercent(int percent) async {
    isLoading.value = true;
    final success = await ApiService.applyTip(
      tipType: 'percent',
      tipPercent: percent,
      customTipAmount: 0,
    );
    if (success) {
      await fetchCheckoutPreview();
    } else {
      Get.snackbar(
        'Error',
        'Failed to apply tip',
        snackPosition: SnackPosition.BOTTOM,
      );
      isLoading.value = false;
    }
  }

  Future<void> applyCustomTipDollars(double dollars) async {
    final rounded = double.parse(dollars.clamp(0, 99999).toStringAsFixed(2));
    isLoading.value = true;
    final success = await ApiService.applyTip(
      tipType: 'custom',
      tipPercent: 0,
      customTipAmount: rounded,
    );
    if (success) {
      await fetchCheckoutPreview();
    } else {
      Get.snackbar(
        'Error',
        'Failed to apply tip',
        snackPosition: SnackPosition.BOTTOM,
      );
      isLoading.value = false;
    }
  }

  Future<void> applyCoupon() async {
    final coupon = couponController.text.trim();
    if (coupon.isEmpty) return;

    isLoading.value = true;
    final success = await ApiService.applyCoupon(
      couponCode: coupon,
    );
    if (success) {
      Get.snackbar('Success', 'Coupon applied successfully');
      await fetchCheckoutPreview();
    } else {
      Get.snackbar('Error', 'Failed to apply coupon');
      isLoading.value = false;
    }
  }

  Future<void> removeCoupon() async {
    isLoading.value = true;
    final success = await ApiService.removeCoupon();
    if (success) {
      couponController.clear();
      await fetchCheckoutPreview();
    } else {
      Get.snackbar('Error', 'Failed to remove coupon');
      isLoading.value = false;
    }
  }

  Future<void> applyWallet(bool redeem) async {
    isLoading.value = true;
    final success = await ApiService.applyWallet(
      redeem: redeem,
    );
    if (success) {
      isWalletRedeemed.value = redeem;
      await fetchCheckoutPreview();
    } else {
      Get.snackbar('Error', 'Failed to update wallet redemption');
      isLoading.value = false;
    }
  }

  Future<void> processCheckout([String? playerId]) async {
    if (selectedPaymentMethod.value == null) {
      Get.snackbar(
        'Error',
        'Please select a payment method first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final totalAmount =
        checkoutData.value?.data.totalAmountSummary?.total ?? 0.0;
    if (totalAmount <= 0) return;

    isLoading.value = true;

    final checkoutResponse = await ApiService.checkout(
      paymentMethod: selectedPaymentMethod.value!,
      playerId: playerId,
      allowSubstitution: allowSubstitutions.value,
      refundInstead: refundInsteadOfSubstitution.value,
    );

    if (checkoutResponse['status'] != 1) {
      isLoading.value = false;
      String errorMessage =
          checkoutResponse['message'] ?? 'Failed to process checkout';
      Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final address = checkoutData.value?.data.cart?.address;
    String formattedAddress = '';
    if (address != null) {
      formattedAddress =
          "${address.addressLine1}${address.addressLine2 != null ? ' ${address.addressLine2}' : ''}, ${address.city}, ${address.state}, ${address.postalCode}";
    }

    String deliveryDayStr = 'today';
    final selectedDate = selectedDeliveryDate.value?.deliveryDate;
    if (selectedDate != null) {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final isToday = selectedDate.year == now.year &&
          selectedDate.month == now.month &&
          selectedDate.day == now.day;
      final isTomorrow = selectedDate.year == tomorrow.year &&
          selectedDate.month == tomorrow.month &&
          selectedDate.day == tomorrow.day;

      if (isToday) {
        deliveryDayStr = 'today';
      } else if (isTomorrow) {
        deliveryDayStr = 'tomorrow';
      } else {
        final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final weekdayStr = selectedDate.weekday >= 1 && selectedDate.weekday <= 7
            ? weekdays[selectedDate.weekday - 1]
            : '';
        deliveryDayStr = 'on $weekdayStr (${selectedDate.month}/${selectedDate.day})';
      }
    }

    String deliverySlotStr = 'before 6 PM';
    final slot = selectedSlot.value;
    if (slot != null) {
      deliverySlotStr = 'between ${slot.startTime} - ${slot.endTime}';
    }

    final successArgs = {
      'address': formattedAddress,
      'deliveryDate': deliveryDayStr,
      'deliverySlot': deliverySlotStr,
    };

    if (selectedPaymentMethod.value == 'stripe' ||
        selectedPaymentMethod.value == 'google_pay' ||
        selectedPaymentMethod.value == 'apple_pay') {
      final clientSecret =
          checkoutResponse['data']?['payment_intent_client_secret'];

      final customerId = checkoutResponse['data']?['customer_id'];

      final ephemeralKey = checkoutResponse['data']?['ephemeral_key'];

      if (clientSecret == null) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Failed to initialize Stripe checkout',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      try {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'SpiceKart',
            style: ThemeMode.light,
            applePay: selectedPaymentMethod.value == 'apple_pay'
                ? const PaymentSheetApplePay(merchantCountryCode: 'US')
                : null,
            googlePay: selectedPaymentMethod.value == 'google_pay'
                ? const PaymentSheetGooglePay(
                    merchantCountryCode: 'US',
                    testEnv: true,
                  )
                : null,
            customerId: customerId,
            customerEphemeralKeySecret: ephemeralKey,
          ),
        );
      } catch (e) {
        isLoading.value = false;
        print("Error initializing Payment Sheet: $e");
        return;
      }

      try {
        await Stripe.instance.presentPaymentSheet();
        isLoading.value = false;
        // Global cart count update
        CartController.to.updateCartCount();
        Get.offAll(
          () => const OrderSuccessScreen(),
          arguments: successArgs,
        );
      } on StripeException catch (e) {
        isLoading.value = false;
        print('Stripe Error: $e');
        Get.snackbar(
          'Error',
          'Payment canceled or failed: ${e.error.localizedMessage}',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        isLoading.value = false;
        print('Error presenting payment sheet: $e');
      }
    } else {
      isLoading.value = false;

      // Global cart count update
      CartController.to.updateCartCount();
      // Handle other payment methods such as net_banking, upi, cod
      Get.offAll(() => const OrderSuccessScreen(), arguments: successArgs);
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

  void toggleWalletRedeemed() {
    isWalletRedeemed.value = !isWalletRedeemed.value;
  }

  Future<void> updateSelectedSlot(DeliverySlot dateDatum, Slot slot) async {
    try {
      selectedDeliveryDate.value = dateDatum;
      selectedSlot.value = slot;

      final date = dateDatum.deliveryDate;
      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      isLoading.value = true;
      final success = await ApiService.addDeliverySlot(
        deliverySlotId: slot.id,
        deliveryDate: dateStr,
      );

      if (success) {
        // Refresh preview to get updated totals or slot info if needed
        await fetchCheckoutPreview();
      } else {
        Get.snackbar(
          'Error',
          'Failed to update delivery slot',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error in updateSelectedSlot: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
