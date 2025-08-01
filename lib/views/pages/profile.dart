import 'package:flutter/material.dart';
import 'package:smart_expense/controllers/auth.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColours.bgColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ListView(
            children: [
              AppSpacing.vertical(size: 48),
              Text(AppStrings.profile, style: AppStyles.title1()),
              AppSpacing.vertical(),
              _profileImage(),
              AppSpacing.vertical(),
              _mainMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Container _mainMenu() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.myAccountList);
            },
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColours.primaryColourLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: AppColours.primaryColour,
                      size: 30,
                    ),
                  ),
                ),
                AppSpacing.horizontal(size: 12),
                Text(AppStrings.account, style: AppStyles.medium(size: 18)),
              ],
            ),
          ),
          SizedBox(child: Divider(height: 40, color: Colors.grey.shade300)),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColours.primaryColourLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.settings,
                      color: AppColours.primaryColour,
                      size: 30,
                    ),
                  ),
                ),
                AppSpacing.horizontal(size: 12),
                Text(AppStrings.setting, style: AppStyles.medium(size: 18)),
              ],
            ),
          ),
          SizedBox(height: 40, child: Divider(color: Colors.grey.shade300)),
          GestureDetector(
            onTap:
                () => Navigator.of(context).pushNamed(AppRoutes.notification),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColours.primaryColourLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.notifications,
                      color: AppColours.primaryColour,
                    ),
                  ),
                ),
                AppSpacing.horizontal(size: 12),
                Text(
                  AppStrings.notificationSettings,
                  style: AppStyles.medium(size: 18),
                ),
              ],
            ),
          ),
          SizedBox(height: 40, child: Divider(color: Colors.grey.shade300)),
          GestureDetector(
            onTap: () {
              Helper.snackBar(context, message: "Hello", isSuccess: false);
            },
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColours.primaryColourLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.subscriptions,
                      color: AppColours.primaryColour,
                    ),
                  ),
                ),
                AppSpacing.horizontal(size: 12),
                Text(
                  AppStrings.subscription,
                  style: AppStyles.medium(size: 18),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: Divider(height: 40, color: Colors.grey.shade300),
          ),
          GestureDetector(
            onTap: _logout,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.logout, color: Colors.red),
                  ),
                ),
                AppSpacing.horizontal(size: 12),
                Text(
                  AppStrings.logout,
                  style: AppStyles.medium(size: 18, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final result = await AuthController.logout();

    if (!result.isSuccess) {
      Helper.snackBar(context, message: result.message, isSuccess: false);
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.walkthrough);
  }

  Container _profileImage() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: (Image.asset("assets/images/sothak.jpg")),
                  ),
                ),
              ),
              AppSpacing.horizontal(size: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.username,
                    style: AppStyles.regular1(
                      color: AppColours.light20,
                      size: 14,
                    ),
                  ),

                  Text("Sothak", style: AppStyles.medium(size: 24)),
                  Text(
                    'thecambodia369@gmail.com',
                    style: AppStyles.regular1(
                      size: 14,
                      color: AppColours.light20,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.edit, size: 30, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
