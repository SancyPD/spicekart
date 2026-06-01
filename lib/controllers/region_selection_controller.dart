import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spicekart/controllers/preference_controller.dart';
import '../services/api_service.dart';
import '../model/all_regions.dart';
import '../screens/main_screen.dart';

class RegionSelectionController extends GetxController {
  final bool fromHome;
  final bool fromPreferences;
  final isLoading = false.obs;
  final isFetchingRegions = true.obs;
  final regions = <Region>[].obs;
  final errorMessage = ''.obs;

  // 👇 ADD THIS CONSTRUCTOR
  RegionSelectionController({this.fromHome = false, this.fromPreferences = false});

  @override
  void onInit() {
    super.onInit();
    fetchRegions();
  }

  Future<void> fetchRegions() async {
    isFetchingRegions.value = true;
    errorMessage.value = '';
    try {
      final result = await ApiService.getAllRegions();
      if (result != null && result.data.isNotEmpty) {
        regions.value = result.data;
      } else {
        errorMessage.value = 'No regions found.';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isFetchingRegions.value = false;
    }
  }

  Future<void> selectRegion(Region region) async {
    if (isLoading.value) return;
    isLoading.value = true;

    await Future.delayed(const Duration(milliseconds: 200));

    try {
      await ApiService.updateUserRegion(region.id);
      await ApiService.saveRegion(region.title);
      
      if (Get.isRegistered<PreferenceController>()) {
        Get.find<PreferenceController>().selectedRegion.value = region.title;
      }

      // Always use offAll for region change to ensure 
      // full app refresh with the new region data.
      // Get.offAll(() => MainScreen(initialRegion: region.title));

      if (fromHome || fromPreferences) {
        // ✅ Go back to previous screen (Home or Preferences)
        Get.back(result: region.title);
      } else {
        // ✅ Full app refresh only when needed
        Get.offAll(() => MainScreen(initialRegion: region.title));
      }

    } finally {
      isLoading.value = false;
    }
  }
}