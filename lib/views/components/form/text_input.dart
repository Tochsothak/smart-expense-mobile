import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';

class TextInputComponent extends StatefulWidget {
  final bool isRequired;
  final TextEditingController textEditingController;
  final String label;
  final String? error;
  final bool isPassword;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final TextInputType? textInputType;
  final bool isEnabled;
  const TextInputComponent({
    super.key,
    required this.label,
    this.error,
    this.isPassword = false,
    required this.textEditingController,
    this.onFieldSubmitted,
    this.textInputAction,
    this.focusNode,
    this.textInputType,
    this.isRequired = false,
    this.isEnabled = true,
  });

  @override
  State<TextInputComponent> createState() => _TextInputComponentState();
}

class _TextInputComponentState extends State<TextInputComponent> {
  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textEditingController,
      enabled: widget.isEnabled,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (!widget.isRequired) return null;
        if (value == null || value.isEmpty) {
          return AppStrings.inputIsRequired.replaceAll(":input", widget.label);
        }
        if (!widget.isPassword && value.trim().isEmpty) {
          return AppStrings.inputIsRequired.replaceAll(":input", widget.label);
        }
        return null;
      },
      obscureText: (widget.isPassword && !showPassword),
      onFieldSubmitted: widget.onFieldSubmitted,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      keyboardType: widget.textInputType,
      decoration: InputDecoration(
        errorText: widget.error,
        labelText: widget.label,
        labelStyle: TextStyle(color: AppColours.light20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColours.light20.withAlpha(90)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColours.light20.withAlpha(90)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColours.primaryColour),
        ),
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  onPressed: togglePassword,
                  icon: Icon(
                    showPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColours.light20,
                  ),
                )
                : AppSpacing.empty(),
      ),
    );
  }

  void togglePassword() => setState(() {
    showPassword = !showPassword;
  });
}
