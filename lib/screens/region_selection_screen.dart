import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../controllers/region_selection_controller.dart';
import '../model/all_regions.dart';

class RegionSelectionScreen extends StatelessWidget {
  final bool fromHome;
  final bool fromPreferences;
  const RegionSelectionScreen({super.key, required this.fromHome, this.fromPreferences = false});

  @override
  Widget build(BuildContext context) {

    // Set system status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final controller = Get.put(RegionSelectionController(fromHome: fromHome, fromPreferences: fromPreferences));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      // Back button
                      Row(
                        children: [
                          if (Navigator.canPop(context))
                            TextButton(
                              onPressed: () => Get.back(),
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
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Title
                      const Text(
                        'Select Region',
                        style: TextStyle(
                          color: Color(0xFF323C42),
                          fontSize: 22,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w600,
                          height: 1.30,
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable region cards
                Expanded(
                  child: Obx(() {
                    if (controller.isFetchingRegions.value) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (controller.errorMessage.value.isNotEmpty) {
                      return Center(child: Text(controller.errorMessage.value));
                    } else if (controller.regions.isEmpty) {
                      return const Center(child: Text('No regions found.'));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: controller.regions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final region = controller.regions[index];
                        return _buildRegionCard(
                          title: region.title,
                          description: '',
                          imageAsset: "https://spicekart1.mockupz.in/storage/regions/${region.regionImage}",
                          onTap: () => controller.selectRegion(region),
                        );
                      },
                    );
                  }),
                ),
                // Footer logo
                Container(
                  padding: const EdgeInsets.only(bottom: 40,top: 20),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo_horizontal.png',
                        fit: BoxFit.contain,
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildRegionCard({
    required String title,
    required String description,
    required dynamic imageAsset,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.56, 0.57),
          end: const Alignment(0.63, 1.64),
          colors: [Colors.white, AppTheme.instance.secondaryColor],
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: AppTheme.instance.secondaryColor,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            child: Row(
              children: [
                // Left side - Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF364238),
                          fontSize: 20,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                          fontWeight: FontWeight.w600,
                          height: 1.30,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Color(0xFF4D555C),
                            fontSize: 12,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                            fontWeight: FontWeight.w500,
                            height: 1.38,
                            letterSpacing: -0.36,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Arrow button
                      Image.asset(
                        'assets/images/region_arrow.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        color: AppTheme.instance.secondaryColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right side - Region image
                SizedBox(
                  width: 56,
                  height: 56,
                  child: _buildRegionImage(imageAsset),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegionImage(dynamic imageSource) {
    if (imageSource is String && imageSource.isNotEmpty) {
      if (imageSource.startsWith('http')) {
        return Image.network(
          imageSource,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
        );
      } else {
        try {
          return Image.asset(
            imageSource.startsWith('assets') ? imageSource : 'assets/images/$imageSource',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
          );
        } catch (e) {
          return const Icon(Icons.broken_image);
        }
      }
    }
    return const Icon(Icons.image);
  }
}

