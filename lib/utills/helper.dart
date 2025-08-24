import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/controllers/exchange_rate.dart';

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

  static Future<double> convertAmount(
    double amount,
    String from,
    String to,
  ) async {
    double rate;
    final result = await ExchangeRateController.convert(amount, from, to);
    if (result.isSuccess && result.results != null) {
      rate = result.results!.rate;
      return rate;
    }
    return amount;
  }

  static String formatCurrency(
    double amount,
    String currency, {
    bool compact = false,
    String symbolPosition = 'before',
  }) {
    String formatted;
    double absAmount = amount.abs();

    if (compact && absAmount >= 1000) {
      if (absAmount >= 1000000) {
        formatted = '${(amount / 1000000).toStringAsFixed(1)}M';
      } else {
        formatted = '${(amount / 1000).toStringAsFixed(1)}K';
      }
    } else {
      formatted = amount.toStringAsFixed(2);
    }

    if (symbolPosition == 'before') {
      return '$currency $formatted';
    } else {
      return '$formatted $currency';
    }
  }

  static dateFormat(DateTime dateTime) {
    String formattedDate = DateFormat('EEEE, MMMM dd, yyyy').format(dateTime);
    return formattedDate;
  }

  // Get Formatted date to display
  static String getFormattedDate(String dateKey) {
    DateTime date = DateTime.parse(dateKey);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));
    DateTime transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMMM dd, yyyy').format(date);
    }
  }

  static String timeFormat(String time) {
    DateTime transactionTime = DateTime.parse(time);
    DateTime now = DateTime.now();
    // If it's midnight  (day-only date)

    //Calculate time
    Duration deference = now.difference(transactionTime);

    if (deference.inMinutes < 1) {
      return "Just now";
    } else if (deference.inHours < 1) {
      return "${deference.inMinutes} m ago";
    } else if (deference.inDays < 1) {
      return "${deference.inHours}h ago";
    } else if (deference.inDays < 10) {
      return "${deference.inDays} ${deference.inDays > 1 ? "days ago" : "day ago"}";
    }
    return DateFormat('hh:mm a').format(transactionTime);
  }

  static String greeting() {
    DateTime now = DateTime.now();

    if (now.hour >= 5 && now.hour < 12) {
      return "Good Morning";
    } else if (now.hour >= 12 && now.hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  static String getPeriodTitle(int index) {
    DateTime now = DateTime.now();
    switch (index) {
      case 0:
        return DateFormat('EEEE, MMM dd').format(now);
      case 1:
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
        return '${DateFormat('MMM dd').format(startOfWeek)} - ${DateFormat('MMM dd').format(endOfWeek)}';
      case 2:
        return DateFormat('MMMM yyyy').format(now);
      case 3:
        return DateFormat('yyyy').format(now);
      default:
        return DateFormat('MMMM yyy').format(now);
    }
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
