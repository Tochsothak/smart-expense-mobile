import 'package:flutter/material.dart';
import 'package:smart_expense/controllers/auth.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final int _pinLength = 4;

  String _pin = "";
  String _pinConfirmation = "";

  int step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.primaryColour,
      body: SafeArea(
        child: Column(
          children: [
            AppSpacing.vertical(size: 48),
            Text(
              textAlign: TextAlign.center,
              (step == 0
                  ? AppStrings.letSetupYourPin
                  : AppStrings.retypeYourPinAgain),
              style: AppStyles.semibold(color: Colors.white),
            ),
            AppSpacing.vertical(size: 48),
            _inputIndicator(),
            const Spacer(),
            _inputNumber(),
          ],
        ),
      ),
    );
  }

  Widget _inputIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pinLength,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColours.primaryColourLight.withAlpha(50),
                width: 4,
              ),
              color:
                  ((step == 1 ? _pinConfirmation.length : _pin.length) >=
                          index + 1
                      ? Colors.white
                      : Colors.transparent),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputNumber() {
    return Column(
      children: [
        ...List.generate(3, (rowIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(3, (index) {
              final number = (rowIndex * 3) + (index + 1);
              return Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: () => _selectNumber(number),
                  child: Text(
                    number.toString(),
                    style: AppStyles.medium(color: Colors.white, size: 48),
                  ),
                ),
              );
            }),
          );
        }),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: _handleBackspace,
              icon: Icon(
                Icons.backspace_outlined,
                color: Colors.white,
                size: 48,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () => _selectNumber(0),
                child: Text(
                  "0",
                  style: AppStyles.medium(color: Colors.white, size: 48),
                ),
              ),
            ),
            IconButton(
              onPressed: _handleSubmit,
              icon: Icon(
                Icons.arrow_forward_outlined,
                color: Colors.white,
                size: 48,
              ),
            ),
          ],
        ),
        AppSpacing.vertical(),
      ],
    );
  }

  void _selectNumber(int number) {
    if (step == 0) {
      if (_pin.length >= _pinLength) return;

      setState(() => _pin = _pin + number.toString());
    } else if (step == 1) {
      if (_pinConfirmation.length >= _pinLength) return;

      setState(() => _pinConfirmation = _pinConfirmation + number.toString());
    }
  }

  void _handleBackspace() {
    if (step == 0) {
      if (_pin.isEmpty) return;
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    } else if (step == 1) {
      if (_pinConfirmation.isEmpty) return;

      setState(
        () =>
            _pinConfirmation = _pinConfirmation.substring(
              0,
              _pinConfirmation.length - 1,
            ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (step == 0) {
      if (_pin.length < _pinLength) return;

      setState(() => step = 1);
    } else if (step == 1) {
      if (_pinConfirmation.length < _pinLength) return;

      // Submit the form

      if (_pin != _pinConfirmation) {
        Helper.snackBar(
          context,
          message: AppStrings.pinDoNotMatch,
          isSuccess: false,
        );

        setState(() {
          step = 0;
          _pin = "";
          _pinConfirmation = "";
        });
        return;
      }
      // submit
      var result = await AuthController.setPin(_pin);
      if (!result.isSuccess) {
        Helper.snackBar(
          context,
          message: AppStrings.pinDoNotMatch,
          isSuccess: false,
        );
      }

      final route = await Helper.initialRoute();
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(route, (Route<dynamic> route) => false);
    }
  }
}
