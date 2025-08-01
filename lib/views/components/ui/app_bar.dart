import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';

import 'package:smart_expense/resources/app_styles.dart';

AppBar buildAppBar(
  BuildContext context,
  String title, {
  Color? backgroundColor,
  Color? foregroundColor,
  Function()? onTap,
  IconData? icon,
}) {
  return AppBar(
    title: Text(title, style: AppStyles.appTitle(color: foregroundColor)),
    actions: [
      IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: foregroundColor, size: 30),
      ),
    ],
    centerTitle: true,
    backgroundColor: backgroundColor ?? AppColours.bgColor,
    elevation: 0,
    leading:
        Navigator.of(context).canPop()
            ? IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: foregroundColor ?? Colors.white,
              ),
            )
            : null,
  );
}
