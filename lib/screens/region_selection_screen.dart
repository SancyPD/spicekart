import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import '../services/api_service.dart';
import '../model/all_regions.dart';

class RegionSelectionScreen extends StatefulWidget {
  const RegionSelectionScreen({super.key});

  @override
  State<RegionSelectionScreen> createState() => _RegionSelectionScreenState();
}

class _RegionSelectionScreenState extends State<RegionSelectionScreen> {
  late Future<AllRegions?> _regionsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set system status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    _regionsFuture = ApiService.getAllRegions();
  }

  @override
  Widget build(BuildContext context) {
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
                              onPressed: () => Navigator.pop(context),
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
                          color:  Color(0xFF323C42),
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
                  child: FutureBuilder<AllRegions?>(
                    future: _regionsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data?.data.isEmpty == true) {
                        return const Center(child: Text('No regions found.'));
                      }

                      final regions = snapshot.data!.data;

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24,),
                        itemCount: regions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final region = regions[index];
                          return _buildRegionCard(
                            title: region.title,
                            description: '', 
                            imageAsset:"https://spicekart.mockupz.in/storage/regions/${region.regionImage}" , // Might be URL or path
                            onTap: () async {
                              if (_isLoading) return;
                              setState(() {
                                _isLoading = true;
                              });

                              // Small delay to allow ripple effect to be seen and give interaction feedback
                              await Future.delayed(const Duration(milliseconds: 200));

                              if (!mounted) return;

                              // Update region on server
                              await ApiService.updateUserRegion(region.id);

                              // Save selected region locally
                              await ApiService.saveRegion(region.title);

                              if (!mounted) return;

                              // Pass selected region to HomeScreen
                                Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(selectedRegion: region.title),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                // Footer logo
                Container(
                  padding: const EdgeInsets.only(bottom: 40),
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRegionCard({
    required String title,
    required String description,
    required dynamic imageAsset, // Changed to dynamic to handle potential different types or nulls
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: ShapeDecoration(
        gradient:  LinearGradient(
          begin: Alignment(0.56, 0.57),
          end: Alignment(0.63, 1.64),
          colors: [Colors.white, AppTheme.instance.secondaryLightBlue],
        ),
        shape: RoundedRectangleBorder(
          side:  BorderSide(
            width: 1,
            color: AppTheme.instance.secondaryLightBlue,
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
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 30),
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right side - Region image
                // Handling image: if it starts with http, use network, else asset (fallback)
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
        // Try as asset, but safe fallback if not found?
        // The previous code had specific assets.
        // If the API returns a filename like 'kerala.png', we might need to prefix 'assets/images/'.
        // Assuming raw path for now or fallback.
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
    return const Icon(Icons.image); // Fallback
  }
}

