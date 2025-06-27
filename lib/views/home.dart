import 'package:flutter/material.dart';
import 'package:smart_expense/controllers/auth.dart';
import 'package:smart_expense/models/user.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/services/auth.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? user;
  @override
  void initState() {
    _getUser();
    super.initState();
  }

  Future<void> _getUser() async {
    user = await AuthService.get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.bgColor,
      appBar: buildAppBar(context, 'Home'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user != null) ...[Text("What's up ${user?.name}")],

            TextButton(onPressed: _logout, child: Text(AppStrings.logout)),
          ],
        ),
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
}
