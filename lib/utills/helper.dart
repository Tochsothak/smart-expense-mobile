import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/services/account.dart';
import 'package:smart_expense/services/auth.dart';

class Helper {
  static snackBar(context, {required String message, bool isSuccess = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        hitTestBehavior: HitTestBehavior.opaque,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
        content: Text(message, style: AppStyles.snackBar()),
        duration: Duration(seconds: 2),
        backgroundColor: isSuccess ? Colors.blue.shade400 : Colors.red.shade400,
      ),
    );
  }

  static Future<String> initialRoute() async {
    final user = await AuthService.get();
    final account = await AccountService.get();

    if (user == null) {
      return AppRoutes.walkthrough;
    } else if (user.emailVerifiedAt == null) {
      return AppRoutes.verification;
    } else if (user.pin == null) {
      return AppRoutes.setupPin;
    } else if (account == null) {
      return AppRoutes.setUpAccount;
    }

    return AppRoutes.bottomNavigationBar;
  }

  static double parseAmount(String value) {
    if (value.isEmpty) return 0;

    value = value.replaceAll(",", ".");
    return double.parse(value);
  }

  static dateFormat(DateTime dateTime) {
    String formattedDate = DateFormat('EEEE, MMMM dd, yyyy').format(dateTime);
    return formattedDate;
  }

  static timeFormat(DateTime date) {
    String formattedTime = DateFormat('h:mm a').format(date);
    return formattedTime;
  }

  static Map<String, IconData> transactionIcon = {
    'work': Icons.work,
    'business': Icons.business,
    'trending_up': Icons.trending_up,
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'medical_services': Icons.medical_services,
    'school': Icons.school,
    'play_circle': Icons.play_circle,
    'shopping_bag': Icons.shopping_bag,
    'receipt_long': Icons.receipt_long,
    'shield': Icons.shield,
    'savings': Icons.savings,
    'credit_card': Icons.credit_card,
    'flight': Icons.flight,
    'favorite': Icons.favorite,
    'card_giftcard': Icons.card_giftcard,
    'laptop_mac': Icons.laptop_mac,
    'home_work': Icons.home_work,
    'more_horiz': Icons.more_horiz,
    'child_care': Icons.child_care,
    'pets': Icons.pets,
    'description': Icons.description,
    'repeat': Icons.repeat,
    'attach_money': Icons.attach_money,
    'gavel': Icons.gavel,
    'event': Icons.event,
    'build': Icons.build,
    'shopping_cart': Icons.shopping_cart,
    'warning': Icons.warning,
  };

  static final Map<String, IconData> accountTypeIcons = {
    'cash': Icons.attach_money,
    'general': Icons.account_balance,
    'momo': Icons.phone_iphone,
    'saving-account': Icons.savings,
    'current-account': Icons.account_balance_wallet,
    'investment-account': Icons.trending_up,
    'insurance-account': Icons.shield,
    'loan': Icons.request_quote,
    'credit-card': Icons.credit_card,
  };
}
