import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/views/components/ui/button.dart';

class SetupAccountScreen extends StatefulWidget {
  const SetupAccountScreen({super.key});

  @override
  State<SetupAccountScreen> createState() => _SetupAccountScreenState();
}

class _SetupAccountScreenState extends State<SetupAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.bgColor,
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            AppSpacing.vertical(size: 48),
            Text(
              AppStrings.letSetupYourAccount,
              style: AppStyles.medium(size: 36),
            ),

            Text(
              AppStrings.letSetupYourAccountHint,
              style: AppStyles.medium(size: 14),
            ),
            Spacer(),
            ButtonComponent(
              label: AppStrings.continueText,
              onPressed:
                  () => Navigator.of(context).pushNamed(AppRoutes.addAccount),
            ),
            AppSpacing.vertical(),
          ],
        ),
      ),
    );
  }
}
