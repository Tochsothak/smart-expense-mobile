import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';

class TypeToggle extends StatefulWidget {
  final Color expenseBackgroundColor;
  final Color incomeBackgroundColor;
  final TextStyle expenseTextStyle;
  final TextStyle incomeTextStyle;
  final VoidCallback onTap;

  const TypeToggle({
    super.key,
    required this.expenseBackgroundColor,
    required this.incomeBackgroundColor,
    required this.expenseTextStyle,
    required this.incomeTextStyle,
    required this.onTap,
  });

  @override
  State<TypeToggle> createState() => _TypeToggleState();
}

class _TypeToggleState extends State<TypeToggle> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              // onTap: widget.expenseTap,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.expenseBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    AppStrings.expense,
                    style: widget.expenseTextStyle,
                  ),
                ),
              ),
            ),

            AppSpacing.horizontal(size: 3),
            GestureDetector(
              // onTap: widget.incomeTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: widget.incomeBackgroundColor,
                ),

                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(AppStrings.income, style: widget.incomeTextStyle),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
