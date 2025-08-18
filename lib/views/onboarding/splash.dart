import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';

import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.primaryColour,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Column(
            children: [
              Image.asset("assets/images/logo.jpg", width: 200),
              Text(
                AppStrings.appName,
                style: AppStyles.titleX(size: 40, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    initApp();
    super.initState();
  }

  Future<void> initApp() async {
    final route = await Helper.initialRoute();
    print(route);

    Future.delayed(
      const Duration(seconds: 3),
      () => Navigator.of(context).pushReplacementNamed(route),
    );
  }
}
