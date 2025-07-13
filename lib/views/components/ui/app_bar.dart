import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';

import 'package:smart_expense/resources/app_styles.dart';

AppBar buildAppBar(
  BuildContext context,
  String title, {
  Color? backgroundColor,
  Color? foregroundColor,
}) {
  return AppBar(
    title: Text(title, style: AppStyles.appTitle(color: foregroundColor)),
    centerTitle: true,
    backgroundColor: backgroundColor ?? AppColours.bgColor,
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
