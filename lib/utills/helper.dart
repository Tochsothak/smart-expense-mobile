import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_styles.dart';

class Helper {
  static snackBar(context, {required String message, bool isSuccess = true}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppStyles.snackBar()),
        backgroundColor:
            isSuccess ? Colors.green.shade500 : Colors.red.shade500,
      ),
    );
  }
}
