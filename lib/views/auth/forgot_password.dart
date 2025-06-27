import 'package:flutter/material.dart';
import 'package:smart_expense/controllers/auth.dart';

import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/form/text_input.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';
import 'package:smart_expense/views/components/ui/button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailEditingController = TextEditingController();
  bool _isLoading = false;
  final _emailFocus = FocusNode();
  Map<String, dynamic> _errors = {};

  @override
  void dispose() {
    _emailEditingController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        backgroundColor: AppColours.bgColor,
        appBar: buildAppBar(context, AppStrings.forgotPasswordTitle),
        body: ListView(
          padding: EdgeInsets.all(24),
          children: [
            AppSpacing.vertical(size: 48),
            Text(
              AppStrings.forgotPasswordHint,
              style: AppStyles.medium(size: 24),
            ),
            AppSpacing.vertical(size: 48),
            Form(
              key: _formKey,
              child: TextInputComponent(
                error: _errors['email']?.join(', '),
                isEnabled: !_isLoading,
                isRequired: true,
                textInputType: TextInputType.emailAddress,
                focusNode: _emailFocus,
                label: AppStrings.emailAddress,
                textEditingController: _emailEditingController,
                onFieldSubmitted:
                    (value) => FocusScope.of(context).requestFocus(FocusNode()),
                textInputAction: TextInputAction.done,
              ),
            ),
            AppSpacing.vertical(size: 32),
            ButtonComponent(
              label: AppStrings.continueText,
              isLoading: _isLoading,
              onPressed: handleContinue,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleContinue() async {
    setState(() => _errors = {});

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthController.resetOtp(
      _emailEditingController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      Helper.snackBar(context, isSuccess: false, message: result.message);
      if (result.errors != null) {
        setState(() => _errors = result.errors!);
      }
      return;
    }

    Navigator.of(context).pushNamed(
      AppRoutes.forgotPasswordSent,
      arguments: _emailEditingController.text.trim(),
    );
  }
}
