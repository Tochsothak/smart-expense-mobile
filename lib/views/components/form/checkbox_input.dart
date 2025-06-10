import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';

class CheckboxInputComponent extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? label;
  final bool isEnable;

  const CheckboxInputComponent({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.isEnable = true,
  });

  @override
  State<CheckboxInputComponent> createState() => _CheckboxInputComponentState();
}

class _CheckboxInputComponentState extends State<CheckboxInputComponent> {
  late bool value;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.scale(
          scale: 1.5,
          child: Checkbox(
            activeColor: AppColours.primaryColour,
            checkColor: Colors.white,
            side: BorderSide(color: AppColours.primaryColour, width: 1.5),
            value: (value),
            onChanged:
                widget.isEnable
                    ? (bool? newValue) {
                      setState(() => value = newValue!);
                      widget.onChanged(value);
                    }
                    : null,
          ),
        ),
        if (widget.label != null) ...[Expanded(child: widget.label!)],
      ],
    );
  }

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }
}
