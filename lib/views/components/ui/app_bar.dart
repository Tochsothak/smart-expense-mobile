import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';

import 'package:smart_expense/resources/app_styles.dart';

AppBar buildAppBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title, style: AppStyles.appTitle()),
    centerTitle: true,
    backgroundColor: AppColours.bgColor,
    leading:
        Navigator.of(context).canPop()
            ? IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
            )
            : null,
  );
}
