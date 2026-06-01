import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:spicekart/screens/subscription_screen.dart';
import 'login_screen.dart';
import 'region_selection_screen.dart';
import 'main_screen.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // Set system status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    _startAnimation();
  }

  void _startAnimation() {
    // Animate progress bar
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _progress += 0.02;
          if (_progress >= 1.0) {
            _progress = 1.0;
            timer.cancel();
            // Navigate to login screen after animation completes
            Future.delayed(const Duration(milliseconds: 500), () async {
              if (mounted) {
                // Check if user is already logged in (tokens already loaded in main.dart)
                if (ApiService.selectedRegion != null &&
                    ApiService.selectedRegion!.isNotEmpty) {
                  print('Region already selected (${ApiService.selectedRegion}), navigating to MainScreen');
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(
                          initialRegion: ApiService.selectedRegion!,
                        ),
                      ),
                    );
                  }
                } else if (ApiService.accessToken != null &&
                    ApiService.accessToken!.isNotEmpty) {
                  print('User logged in but no region selected, navigating to RegionSelectionScreen');
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegionSelectionScreen(fromHome: false,),
                      ),
                    );
                  }
                } else {
                  print('No token, no region, navigating to LoginScreen');
                  if (mounted) {
                    Get.offAll(() => const LoginScreen());
                  }
                }
              }
            });
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top gradient background
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_top_gradient _bg.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/top_ellipse_bg.png',
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
          // Top image (logo area)
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/splash_top_img.png',
              fit: BoxFit.contain,
              height: 230,
            ),
          ),
          Positioned(
            top: 390,
            left: 0,
            right: 0,
            child: Text(
              'Where Every Aloo Finds Its Masala',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'ITC Avant Garde Gothic Pro',
                fontWeight: FontWeight.w600,
                height: 1.63,
              ),
            ),
          ),
          // Bottom background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/splash_bottom_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Bottom shadow
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/blur_elipse.png',
              fit: BoxFit.cover,
            ),
          ),
          // Bottom image (basket)
          Positioned(
            left: 0,
            right: 0,
            bottom: 200,
            child: Image.asset(
              'assets/images/splash_bottom_img.png',
              fit: BoxFit.contain,
              height: 200,
            ),
          ),
          Positioned(
            left: 0,
            right: 200,
            bottom: 200,
            child: Image.asset(
              'assets/images/red_chilli.png',
              fit: BoxFit.contain,
              height: 19,
            ),
          ),
          Positioned(
            left: 0,
            right: 180,
            bottom: 197,
            child: Image.asset(
              'assets/images/green_chilli.png',
              fit: BoxFit.contain,
              height: 19,
            ),
          ),

          // Loading bar at the bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  // Progress bar track
                  SizedBox(
                    height: 4,
                    width: 108,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _progress, // 0.0 to 1.0
                        backgroundColor: const Color(0xFFEDEDED), // track color
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4DA96D), // progress color
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
