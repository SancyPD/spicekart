import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51OWwXpSC0wOLqNzfTJ9nmasceOXhfuwePuUmUcgOS0BonQDOJ2dGUIvReV4kmaGIEBfGMLbfHUJB992LUwyN37oj00B6G3GUBL';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpiceKart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3374F6)),
        useMaterial3: true,
        fontFamily: 'ITC Avant Garde Gothic Pro',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
