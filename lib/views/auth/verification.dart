import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_expense/controllers/auth.dart';
import 'package:smart_expense/models/user.dart';

import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/services/auth.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';
import 'package:smart_expense/views/components/ui/button.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  var _duration = const Duration(minutes: 5);

  static const otpLength = 6;

  final _formKey = GlobalKey<FormState>();
  final _controllers = List.generate(otpLength, (_) => TextEditingController());
  final _focusNodes = List.generate(otpLength, (_) => FocusNode());
  UserModel? user;

  Timer? _timer;

  bool _isLoading = false;

  @override
  void initState() {
    _initScreen();
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNodes in _focusNodes) {
      focusNodes.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.bgColor,
      appBar: buildAppBar(context, AppStrings.verification),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppSpacing.vertical(size: 48),
          Text(
            AppStrings.enterYourVerificationCode,
            style: AppStyles.medium(size: 36),
          ),
          AppSpacing.vertical(size: 32),
          _inputFields(),
          AppSpacing.vertical(size: 48),
          if (_timer!.isActive) ...[
            Text(
              _showTimer(),
              style: AppStyles.medium(
                size: 16,
                color: AppColours.primaryColour,
              ),
            ),
          ],
          AppSpacing.vertical(size: 32),

          Text.rich(
            TextSpan(
              text: AppStrings.verificationCodeHint1,
              style: AppStyles.medium(),
              children: [
                WidgetSpan(child: AppSpacing.horizontal(size: 4)),
                if (user != null) ...[
                  TextSpan(
                    text: "${user?.email}.",
                    style: AppStyles.medium(color: AppColours.primaryColour),
                  ),
                ],
                WidgetSpan(child: AppSpacing.horizontal(size: 4)),
                TextSpan(text: AppStrings.verificationCodeHint2),
              ],
            ),
          ),
          AppSpacing.vertical(size: 32),
          InkWell(
            onTap: _resend,
            child: Text(
              AppStrings.resendVerificationCodeHint,
              style: AppStyles.medium(color: AppColours.primaryColour).copyWith(
                decoration: TextDecoration.underline,
                decorationColor: AppColours.primaryColour,
              ),
            ),
          ),

          AppSpacing.vertical(size: 48),
          ButtonComponent(
            isLoading: _isLoading,
            label: AppStrings.verify,
            onPressed: _verify,
          ),
          AppSpacing.vertical(size: 48),
          InkWell(
            onTap: _logout,
            child: Text(
              textAlign: TextAlign.center,
              AppStrings.notUserLogout.replaceAll(':user', user?.name ?? ''),
              style: AppStyles.medium(color: AppColours.primaryColour).copyWith(
                decoration: TextDecoration.underline,
                decorationColor: AppColours.primaryColour,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initScreen() async {
    user = await AuthService.get();

    _focusNodes[0].requestFocus();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds == 0) {
        _duration = const Duration(minutes: 5);
        timer.cancel();
      }
      setState(() {
        _duration -= Duration(seconds: 1);
      });
    });
  }

  void _resend() async {
    if (_timer != null && _timer!.isActive || _isLoading) return;

    setState(() => _isLoading = true);
    final result = await AuthController.otp();
    setState(() => _isLoading = false);

    Helper.snackBar(context, message: result.message);
    if (result.isSuccess) {
      _startTimer();
    }
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    final otp = _controllers.map((controller) => controller.text.trim()).join();

    final result = await AuthController.verify(otp);

    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      Helper.snackBar(
        context,
        message: result.message,
        isSuccess: result.isSuccess,
      );
      return;
    }
    final route = await Helper.initialRoute();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(route, (Route<dynamic> route) => false);
  }

  String _showTimer() {
    String minutes = _duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (_duration.inSeconds % 60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  Widget _inputFields() {
    return Form(
      key: _formKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(otpLength, (index) {
          return SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_controllers[index].text.trim().isEmpty)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color:
                          _focusNodes[index].hasFocus
                              ? AppColours.primaryColourLight
                              : AppColours.inputBg,
                      shape: BoxShape.circle,
                    ),
                  ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '*';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  maxLength: 1,
                  cursorColor: AppColours.primaryColour,
                  keyboardType: TextInputType.number,
                  style: AppStyles.bold(size: 32),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    counterText: "",
                  ),
                  onChanged: (value) {
                    _controllers[index].selection = TextSelection.fromPosition(
                      TextPosition(offset: _controllers[index].text.length),
                    );
                    if (value.trim().isNotEmpty &&
                        index < _focusNodes.length - 1) {
                      _focusNodes[index + 1].requestFocus();
                    }
                    if (value.trim().isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                    if (value.trim().isNotEmpty &&
                        index == _focusNodes.length - 1) {
                      FocusScope.of(context).unfocus();
                    }
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _logout() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final result = await AuthController.logout();

    setState(() => _isLoading = false);
    if (!result.isSuccess) {
      Helper.snackBar(context, message: result.message, isSuccess: false);
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.walkthrough);
  }
}
