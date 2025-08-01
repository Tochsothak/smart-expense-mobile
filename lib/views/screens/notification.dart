import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.bgColor,
      appBar: buildAppBar(
        context,
        AppStrings.notifications,
        foregroundColor: Colors.black,
      ),

      body: ListView(
        children: [
          AppSpacing.vertical(),
          ...List.generate(15, (index) {
            return Slidable(
              endActionPane: ActionPane(
                motion: ScrollMotion(),
                children: [
                  SlidableAction(
                    foregroundColor: Colors.red.shade400,
                    onPressed: (value) {},
                    icon: Icons.delete,
                    label: 'delete',
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Shoping Wallet is limit",
                      style: AppStyles.medium(),
                    ),
                    AppSpacing.vertical(size: 4),
                    Text(
                      "Hello Your money is out of your wallet please owe your your neighbor more.",
                      style: AppStyles.regular1(
                        size: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(child: Divider()),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
