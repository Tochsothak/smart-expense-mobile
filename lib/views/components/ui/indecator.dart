import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';

class MyIndecator extends StatefulWidget {
  const MyIndecator({super.key});

  @override
  State<MyIndecator> createState() => MyIndecatorState();
}

class MyIndecatorState extends State<MyIndecator> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AppColours.primaryColour,
        backgroundColor: AppColours.primaryColourLight,
        strokeWidth: 3,
        padding: EdgeInsets.all(50),
      ),
    );
  }
}
