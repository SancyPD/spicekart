import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:spicekart/screens/cart_screen.dart';
import '../utils/app_theme.dart';
import '../controllers/order_success_controller.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderSuccessController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          controller.continueShopping();
        },
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
                      onPressed: controller.continueShopping,
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
                              'assets/images/success.png',
                              width: 150,
                              height: 150,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
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
                                color: Color(0xFF323C42),
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
                                color: Color(0xFF4D555C),
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
                                color: Color(0xFF4D555C),
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
                                    decoration: const ShapeDecoration(
                                      color: Colors.white,
                                      shape: OvalBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: Color(0x9338424A),
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
                                    child: Obx(
                                      () => RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Color(0xFF4D555C),
                                            fontSize: 14,
                                            fontFamily: 'ITC Avant Garde Gothic Pro',
                                            fontWeight: FontWeight.w500,
                                          ),
                                          children: [
                                            const TextSpan(
                                                text:
                                                    'Order will be delivered at '),
                                            TextSpan(
                                              text: controller
                                                      .deliveryAddress.isEmpty
                                                  ? 'your address'
                                                  : controller
                                                      .deliveryAddress.value,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            TextSpan(
                                                text: ' ${controller.deliveryDate.value} ${controller.deliverySlot.value}'),
                                          ],
                                        ),
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
                            onPressed: controller.continueShopping,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.instance.mutedColor,
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
        ),
      ));
  }
}

