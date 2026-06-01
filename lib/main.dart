import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'controllers/notification_controller.dart';
import 'screens/splash_screen.dart';
import 'controllers/cart_controller.dart';
import 'controllers/theme_controller.dart';
import 'services/api_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize OneSignal Controller first
  Get.put(NotificationController());
  
  // Load token and region before initializing controllers
  await ApiService.loadToken();
  
  // Initialize Controllers
  Get.put(ThemeController());
  Get.put(CartController());

  // Stripe.publishableKey = 'pk_test_51TCGe3KKonH5iwVDNDq7rkBBtSQPxkvlBunEWcJ7IjIYf2AnJg9jvF9F0Bkn2qJSGuEoUJTEjQ9rN5hG8Oz352vm00pfmHlO3q';
  Stripe.publishableKey = 'pk_test_51Sl9rxHhyDU4doRYsbcmTDK4pnSaUUwtFo3E3Q0RkvhhOduORbftKnCDp6F7D2iIYrk0fXovgvAdlaAkzCuWxmwd00q9d9FTIM';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppTheme.instance,
      builder: (context, _) {
        return GetMaterialApp(
          title: 'SpiceKart',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.instance.primaryColor,
              primary: AppTheme.instance.primaryColor,
              secondary: AppTheme.instance.secondaryColor,
              surface: AppTheme.instance.backgroundColor,
            ),
            useMaterial3: true,
            fontFamily: 'ITC Avant Garde Gothic Pro',
          ),
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
          routingCallback: (routing) {
            ThemeController.to.checkThemeOnNavigation();
          },
        );
      },
    );
  }
}
