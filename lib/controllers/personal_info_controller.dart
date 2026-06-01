import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../services/api_service.dart';
import '../model/profile_response.dart';

class PersonalInfoController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final isLoading = false.obs;
  final isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    final response = await ApiService.getProfile();
    isLoading.value = false;

    if (response != null && response.status == 1 && response.data != null) {
      final profile = response.data!;
      firstNameController.text = profile.firstName;
      lastNameController.text = profile.lastName;
      emailController.text = profile.email;
      phoneController.text = profile.phone;
    } else {
      Get.snackbar(
        'Error',
        'Failed to load profile details',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateProfile() async {
    String phone = phoneController.text.trim();
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phone.isEmpty) {
      Get.snackbar(
        'Error',
        'All fields are required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final email = emailController.text.trim();
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Basic US phone formatting/validation
    if (phone.startsWith('+1')) {
      if (phone.length != 12) {
        Get.snackbar('Error', 'Invalid US phone number format. Use +1 followed by 10 digits.', snackPosition: SnackPosition.BOTTOM);
        return;
      }
    } else if (phone.length == 10 && RegExp(r'^\d{10}$').hasMatch(phone)) {
      phone = '+1$phone';
    } else if (phone.length == 11 && phone.startsWith('1') && RegExp(r'^\d{11}$').hasMatch(phone)) {
      phone = '+$phone';
    } else {
      Get.snackbar('Error', 'Please enter a valid 10-digit US mobile number', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    phoneController.text = phone; // Update UI with formatted number

    isUpdating.value = true;
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      print("timezone: $timezone");
      await ApiService.updateUserTimezone(timezone);
      
      final result = await ApiService.updateProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        timezone: timezone,
      );
      isUpdating.value = false;

      if (result['status'] == 1) {
        Get.snackbar(
          'Success',
          result['message'] ?? 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        fetchProfile();
      } else {
        String errorMessage = result['message'] ?? 'Failed to update profile';

        // If there are detailed validation errors, join them
        if (result['errors'] != null && result['errors'] is Map) {
          final Map<String, dynamic> errors = result['errors'];
          final List<String> allErrors = [];
          errors.forEach((key, value) {
            if (value is List) {
              allErrors.addAll(value.map((e) => e.toString()));
            } else {
              allErrors.add(value.toString());
            }
          });
          if (allErrors.isNotEmpty) {
            errorMessage = allErrors.join('\n');
          }
        }

        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      isUpdating.value = false;
      print('Error updating profile: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
