import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/services/auth.dart';

class Helper {
  static snackBar(context, {required String message, bool isSuccess = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppStyles.snackBar()),
        backgroundColor:
            isSuccess ? AppColours.primaryColour : Colors.red.shade900,
      ),
    );
  }

  static Future<String> initialRoute() async {
    final user = await AuthService.get();
    if (user == null) {
      return AppRoutes.walkthrough;
    } else if (user.emailVerifiedAt == null) {
      return AppRoutes.verification;
    } else if (user.pin == null) {
      return AppRoutes.setupPin;
    }

    return AppRoutes.home;
  }
}
