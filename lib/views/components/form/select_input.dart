import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_strings.dart';

class SelectInputComponent<T> extends StatefulWidget {
  final bool isRequired;
  final String label;
  final String? error;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool isEnabled;
  final List<T> items;
  final T? selectedItem;
  final Function(T? value) onChanged;
  final bool Function(T, T)? compareFn;
  final bool? showSearchBox;
  final String? searchBoxLabel;
  final Widget? suffixIcon;
  const SelectInputComponent({
    super.key,
    required this.label,
    this.error,
    this.onFieldSubmitted,
    this.focusNode,
    this.isRequired = false,
    this.isEnabled = true,
    required this.items,
    required this.onChanged,
    this.selectedItem,
    this.compareFn,
    this.showSearchBox,
    this.searchBoxLabel,
    this.suffixIcon,
  });

  @override
  State<SelectInputComponent<T>> createState() =>
      _SelectInputComponentState<T>();
}

class _SelectInputComponentState<T> extends State<SelectInputComponent<T>> {
  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      items: (f, cs) => widget.items,
      compareFn: widget.compareFn,
      enabled: widget.isEnabled,
      popupProps: PopupProps.modalBottomSheet(
        showSelectedItems: true,
        showSearchBox: widget.showSearchBox ?? false,
        searchFieldProps: TextFieldProps(
          padding: EdgeInsets.only(top: 24, right: 16, left: 16, bottom: 24),
          decoration: InputDecoration(
            labelText: widget.searchBoxLabel ?? AppStrings.search,
            suffixIcon: widget.suffixIcon ?? Icon(Icons.search),
            suffixIconColor: AppColours.light20,
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
          ),
        ),
      ),
      decoratorProps: DropDownDecoratorProps(
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
        ),
      ),
      onChanged: widget.onChanged,
      selectedItem: widget.selectedItem,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (widget.isRequired && value == null) {
          return AppStrings.inputIsRequired.replaceAll(":input", widget.label);
        }
        return null;
      },
    );
  }
}
