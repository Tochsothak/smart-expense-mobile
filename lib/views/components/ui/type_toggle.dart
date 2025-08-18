import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColours.light20.withAlpha(50)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                // onTap: widget.expenseTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.expenseBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      AppStrings.expense,
                      style: widget.expenseTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: GestureDetector(
                // onTap: widget.incomeTap,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    color: widget.incomeBackgroundColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      AppStrings.income,
                      style: widget.incomeTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
