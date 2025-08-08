import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_styles.dart';

class ButtonComponent extends StatefulWidget {
  final String label;
  final double? width;
  final Widget? icon;
  final ButtonType type;
  final Function() onPressed;
  final bool isLoading;
  const ButtonComponent({
    super.key,
    required this.label,
    this.icon,
    this.type = ButtonType.primary,
    this.width,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<ButtonComponent> createState() => _ButtonComponentState();
}

class _ButtonComponentState extends State<ButtonComponent> {
  // Background Colors for difference button type
  final Map<ButtonType, Color> backgroundColor = {
    ButtonType.primary: AppColours.primaryColour,
    ButtonType.secondary: AppColours.primaryColourLight,
    ButtonType.light: Colors.white,
    ButtonType.expense: Colors.red.shade400,
    ButtonType.income: Colors.green.shade400,
  };

  // Foreground Colors for difference button type
  final Map<ButtonType, Color> foregroundColor = {
    ButtonType.primary: Colors.white,
    ButtonType.secondary: AppColours.primaryColour,
    ButtonType.light: Colors.black,
    ButtonType.expense: Colors.white,
    ButtonType.income: Colors.white,
  };

  // Border Colors
  final Map<ButtonType, Color> borderColor = {
    ButtonType.primary: AppColours.primaryColour,
    ButtonType.secondary: AppColours.primaryColourLight,
    ButtonType.light: AppColours.light20.withAlpha(90),
    ButtonType.expense: Colors.red.shade400,
    ButtonType.income: Colors.green.shade400,
  };
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? MediaQuery.of(context).size.width,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (!widget.isLoading) widget.onPressed();
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor[widget.type]!),
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: backgroundColor[widget.type],
        ),
        child:
            widget.isLoading
                ? CircularProgressIndicator(color: foregroundColor[widget.type])
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      AppSpacing.horizontal(size: 8),
                    ],
                    Text(
                      widget.label,
                      style: AppStyles.title3(
                        color: foregroundColor[widget.type]!,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

enum ButtonType { primary, secondary, light, expense, income }
