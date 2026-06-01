import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../screens/login_screen.dart';

class GuestChecker {
  static bool check({PendingAction? action}) {
    if (ApiService.accessToken == null) {
      final String message = action?.type == PendingActionType.wishlist
          ? 'Please login to wishlisting your favorite products.'
          : 'Please login to continue adding items to your cart and placing orders.';

      Get.dialog(
        AlertDialog(
          title: const Text(
            'Login Required',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4D555C),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                if (action != null) {
                  ApiService.setPendingAction(action);
                }
                Get.offAll(() => const LoginScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3374F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }
}
