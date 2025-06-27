import 'package:flutter/material.dart';
import 'package:smart_expense/controllers/auth.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/form/text_input.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';
import 'package:smart_expense/views/components/ui/button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpEditingController = TextEditingController();
  final _passwordEditingController = TextEditingController();
  final _passwordConfirmationEditingController = TextEditingController();

  final _otpFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _passwordConfirmationFocus = FocusNode();

  late String email;

  bool _isLoading = false;
  @override
  void dispose() {
    _otpEditingController.dispose();
    _passwordEditingController.dispose();
    _passwordConfirmationEditingController.dispose();

    _otpFocus.dispose();
    _passwordFocus.dispose();
    _passwordConfirmationFocus.dispose();
    super.dispose();
  }

  Map<String, dynamic> _errors = {};
  @override
  Widget build(BuildContext context) {
    email = ModalRoute.of(context)!.settings.arguments as String;
    print(email);
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        backgroundColor: AppColours.bgColor,
        appBar: buildAppBar(context, AppStrings.resetPassword),
        body: ListView(
          padding: EdgeInsets.all(24),
          children: [
            AppSpacing.vertical(size: 48),
            _resetForm(),
            AppSpacing.vertical(),
            ButtonComponent(
              isLoading: _isLoading,
              label: AppStrings.resetPassword,
              onPressed: _handleReset,
            ),
          ],
        ),
      ),
    );
  }

  Widget _resetForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextInputComponent(
            label: AppStrings.verificationCode,
            textEditingController: _otpEditingController,
            error: _errors['otp']?.join(', '),
            isEnabled: !_isLoading,
            isRequired: true,
            textInputType: TextInputType.number,
            focusNode: _otpFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted:
                (value) => FocusScope.of(context).requestFocus(_passwordFocus),
          ),
          AppSpacing.vertical(),
          TextInputComponent(
            label: AppStrings.newPassword,
            textEditingController: _passwordEditingController,
            error: _errors['password']?.join(', '),
            isEnabled: !_isLoading,
            isRequired: true,
            isPassword: true,
            textInputType: TextInputType.visiblePassword,
            focusNode: _passwordFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted:
                (value) => FocusScope.of(
                  context,
                ).requestFocus(_passwordConfirmationFocus),
          ),
          AppSpacing.vertical(),
          TextInputComponent(
            label: AppStrings.retypeNewPassword,
            textEditingController: _passwordConfirmationEditingController,
            error: _errors['password_confirmation']?.join(', '),
            isEnabled: !_isLoading,
            isRequired: true,
            isPassword: true,
            textInputType: TextInputType.visiblePassword,
            focusNode: _passwordConfirmationFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (value) => FocusScope.of(context).unfocus(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReset() async {
    setState(() => _errors = {});

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordEditingController.text !=
        _passwordConfirmationEditingController.text) {
      Helper.snackBar(
        context,
        message: AppStrings.passwordDonotMatch,
        isSuccess: false,
      );
      FocusScope.of(context).requestFocus(_passwordConfirmationFocus);
      return;
    }

    setState(() => _isLoading = true);

    var result = await AuthController.resetPassword(
      email,
      _otpEditingController.text.trim(),
      _passwordEditingController.text,
      _passwordConfirmationEditingController.text,
    );
    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      Helper.snackBar(context, message: result.message, isSuccess: false);
      if (result.errors != null) {
        setState(() => _errors = result.errors!);
      }
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (
      Route<dynamic> route,
    ) {
      return route.settings.name == AppRoutes.walkthrough;
    });
  }
}
