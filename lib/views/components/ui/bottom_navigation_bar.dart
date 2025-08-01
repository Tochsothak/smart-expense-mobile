import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/views/account/my_account_list.dart';
import 'package:smart_expense/views/pages/home.dart';
import 'package:smart_expense/views/pages/profile.dart';
import 'package:smart_expense/views/pages/statistic.dart';

class BottomNavigationBarComponent extends StatefulWidget {
  final Function(int)? onTap;
  const BottomNavigationBarComponent({super.key, this.onTap});

  @override
  State<BottomNavigationBarComponent> createState() =>
      _BottomNavigationBarComponentState();
}

class _BottomNavigationBarComponentState
    extends State<BottomNavigationBarComponent> {
  List screens = [HomeScreen(), StatisticScreen(), MyAccountList(), Profile()];
  List<NavigationItem> navigationItems = [
    NavigationItem(icon: Icons.home, label: 'Home'),
    NavigationItem(icon: Icons.bar_chart_outlined, label: 'Analytics'),
    NavigationItem(
      icon: Icons.account_balance_wallet_outlined,
      label: 'Wallet',
    ),
    NavigationItem(icon: Icons.person_outline, label: 'Profile'),
  ];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      backgroundColor: AppColours.bgColor,
      floatingActionButton: SpeedDial(
        activeBackgroundColor: Colors.white,
        activeForegroundColor: AppColours.primaryColour,
        overlayColor: AppColours.primaryColour,
        overlayOpacity: 0.5,
        childrenButtonSize: Size(68, 68),
        spaceBetweenChildren: 15,
        backgroundColor: AppColours.primaryColour,
        foregroundColor: Colors.white,
        activeIcon: Icons.close,
        icon: Icons.add,
        children: [
          SpeedDialChild(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.addTransaction,
                arguments: 'income',
              );
            },
            backgroundColor: Colors.green.shade400,
            foregroundColor: Colors.white,
            child: Icon(
              Icons.arrow_downward,
              size: 30,
              semanticLabel: AppStrings.addIncome,
            ),
            shape: const CircleBorder(),
            label: AppStrings.income,
          ),
          SpeedDialChild(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.addTransaction,
                arguments: 'expense',
              );
            },
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            child: Icon(
              Icons.arrow_upward,
              size: 30,
              semanticLabel: AppStrings.addExpense,
            ),
            shape: const CircleBorder(),
            label: AppStrings.expense,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 10,
        surfaceTintColor: AppColours.primaryColour,
        height: 80,
        color: AppColours.primaryColour,
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...navigationItems.take(2).toList().asMap().entries.map((entry) {
                int index = entry.key;
                return GestureDetector(
                  onTap: () => setState(() => currentIndex = index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Icon(
                          entry.value.icon,
                          size: 30,
                          color:
                              currentIndex == index
                                  ? Colors.white
                                  : Colors.white.withAlpha(100),
                        ),
                      ),
                      Text(
                        entry.value.label,
                        style: AppStyles.semibold(
                          size: 12,
                          color:
                              currentIndex == index
                                  ? Colors.white
                                  : Colors.white.withAlpha(100),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              AppSpacing.horizontal(size: 20),
              ...navigationItems.skip(2).toList().asMap().entries.map((entry) {
                int index = entry.key + 2;
                return GestureDetector(
                  onTap: () => setState(() => currentIndex = index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Icon(
                          entry.value.icon,
                          size: 30,
                          color:
                              currentIndex == index
                                  ? Colors.white
                                  : Colors.white.withAlpha(100),
                        ),
                      ),
                      Text(
                        entry.value.label,
                        style: AppStyles.semibold(
                          size: 12,
                          color:
                              currentIndex == index
                                  ? Colors.white
                                  : Colors.white.withAlpha(100),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  const NavigationItem({required this.icon, required this.label});
}
