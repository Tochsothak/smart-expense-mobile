import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/views/auth/signup.dart';
import 'package:smart_expense/views/auth/verification.dart';
import 'package:smart_expense/views/onboarding/splash.dart';
import 'package:smart_expense/views/onboarding/wallkthrough.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColours.primaryColour),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.walkthrough: (context) => const WalkThroughScreen(),
        AppRoutes.signup: (context) => const SignUpScreen(),
        AppRoutes.verification: (context) => const VerificationScreen(),
      },
    );
  }
}
