import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/preference_controller.dart';
import '../utils/app_theme.dart';
import 'region_selection_screen.dart';

class PreferenceScreen extends StatelessWidget {
  const PreferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PreferenceController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4D555C)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Preferences',
          style: TextStyle(
            color: Color(0xFF4D555C),
            fontSize: 18,
            fontFamily: 'ITC Avant Garde Gothic Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRegionSection(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionSection(PreferenceController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Region',
          style: TextStyle(
            color: Color(0xFF4D555C),
            fontSize: 14,
            fontFamily: 'ITC Avant Garde Gothic Pro',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                controller.selectedRegion.value.isNotEmpty
                    ? controller.selectedRegion.value
                    : 'Select Region',
                style: const TextStyle(
                  color: Color(0xFF4D555C),
                  fontSize: 16,
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                  fontWeight: FontWeight.w400,
                ),
              )),
              TextButton(
                onPressed: () => Get.to(() => const RegionSelectionScreen(fromHome: false, fromPreferences: true,)),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Change',
                  style: TextStyle(
                    color: Color(0xFF63A6D1),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
