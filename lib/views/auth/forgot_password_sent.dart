import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/views/components/ui/button.dart';

class ForgotPasswordSentScreen extends StatefulWidget {
  const ForgotPasswordSentScreen({super.key});

  @override
  State<ForgotPasswordSentScreen> createState() =>
      _ForgotPasswordSentScreenState();
}

class _ForgotPasswordSentScreenState extends State<ForgotPasswordSentScreen> {
  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      backgroundColor: AppColours.bgColor,
      body: ListView(
        padding: EdgeInsets.all(24),
        children: [
          AppSpacing.vertical(size: 48),
          Center(
            child: Image.asset(
              "assets/images/email.png",
              width: MediaQuery.of(context).size.width / 1.5,
            ),
          ),
          AppSpacing.vertical(size: 16),
          Text(
            AppStrings.yourEmailIsOnTheWay,
            style: AppStyles.medium(size: 24),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vertical(),
          Text(
            textAlign: TextAlign.center,
            AppStrings.yourEmailIsOnTheWayHint.replaceAll(':email', email),
            style: AppStyles.regular1(),
          ),
          AppSpacing.vertical(),
          ButtonComponent(
            label: AppStrings.continueText,
            onPressed:
                () => Navigator.of(context).pushReplacementNamed(
                  AppRoutes.resetPassword,
                  arguments: email,
                ),
          ),
        ],
      ),
    );
  }
}
