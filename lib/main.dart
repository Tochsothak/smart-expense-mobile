import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense/models/account.dart';
import 'package:smart_expense/models/account_type.dart';
import 'package:smart_expense/models/category.dart';
import 'package:smart_expense/models/currency.dart';

import 'package:smart_expense/models/transaction.dart';
import 'package:smart_expense/models/transaction_attachment.dart';
import 'package:smart_expense/models/user.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_strings.dart';

import 'package:smart_expense/views/screens/account/account_detail.dart';
import 'package:smart_expense/views/screens/account/add_account.dart';
import 'package:smart_expense/views/pages/my_account_list.dart';
import 'package:smart_expense/views/screens/account/setup_account.dart';
import 'package:smart_expense/views/pages/profile.dart';
import 'package:smart_expense/views/screens/account/update_account.dart';

import 'package:smart_expense/views/screens/transaction/add_transaction.dart';
import 'package:smart_expense/views/auth/forgot_password.dart';
import 'package:smart_expense/views/auth/forgot_password_sent.dart';
import 'package:smart_expense/views/auth/login.dart';
import 'package:smart_expense/views/auth/reset_password.dart';
import 'package:smart_expense/views/auth/setup_pin.dart';
import 'package:smart_expense/views/auth/signup.dart';
import 'package:smart_expense/views/auth/signup_success.dart';
import 'package:smart_expense/views/auth/verification.dart';
import 'package:smart_expense/views/components/ui/bottom_navigation_bar.dart';
import 'package:smart_expense/views/pages/home.dart';
import 'package:smart_expense/views/onboarding/splash.dart';
import 'package:smart_expense/views/onboarding/wallkthrough.dart';
import 'package:smart_expense/views/pages/statistic.dart';
import 'package:smart_expense/views/screens/transaction/all_transaction.dart';
import 'package:smart_expense/views/screens/transaction/detail_transaction.dart';
import 'package:smart_expense/views/screens/notification.dart';
import 'package:smart_expense/views/screens/transaction/update_transaction.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // await Hive.deleteBoxFromDisk(UserModel.userBox);
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(CurrencyModelAdapter());
  Hive.registerAdapter(AccountTypeModelAdapter());
  Hive.registerAdapter(AccountModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(TransactionAttachmentModelAdapter());

  //FOR DEVELOPMENT ONLY

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
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.forgotPasswordSent:
            (context) => const ForgotPasswordSentScreen(),
        AppRoutes.resetPassword: (context) => const ResetPasswordScreen(),
        AppRoutes.setupPin: (context) => const SetupPinScreen(),
        AppRoutes.setUpAccount: (context) => const SetupAccountScreen(),
        AppRoutes.addAccount: (context) => const AddAccountScreen(),
        AppRoutes.signUpSuccess: (context) => const SignupSuccessScreen(),
        AppRoutes.statistic: (context) => const StatisticScreen(),
        AppRoutes.bottomNavigationBar:
            (context) => BottomNavigationBarComponent(),
        AppRoutes.addTransaction: (context) => AddTranSactionScreen(),
        AppRoutes.profile: (context) => Profile(),
        AppRoutes.detailTransaction: (context) => DetailTransaction(),
        AppRoutes.notification: (context) => NotificationScreen(),
        AppRoutes.myAccountList: (context) => MyAccountList(),
        AppRoutes.accountDetail: (context) => AccountDetail(),
        AppRoutes.updateAccount: (context) => UpdateAccount(),
        AppRoutes.updateTransaction: (context) => UpdateTransaction(),
        AppRoutes.allTransactions: (context) => AllTransactions(),

        //FOR DEVELOPMENT ONLY
      },
    );
  }
}
