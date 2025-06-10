import 'package:flutter/material.dart';
import 'package:smart_expense/controllers/auth.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/form/checkbox_input.dart';
import 'package:smart_expense/views/components/form/text_input.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';
import 'package:smart_expense/views/components/ui/button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController =
      TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _isLoading = false;
  bool _hasAgreed = false;

  Map<String, dynamic> _errors = {};

  @override
  void dispose() {
    _nameEditingController.dispose();
    _emailEditingController.dispose();
    _passwordEditingController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColours.bgColor,
        appBar: buildAppBar(context, AppStrings.signUp),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(24),
            children: [
              AppSpacing.vertical(size: 48),
              _signUpForm(),
              AppSpacing.vertical(),
              ButtonComponent(
                isLoading: _isLoading,
                label: AppStrings.signUp,
                onPressed: _handleSignUp,
              ),
              AppSpacing.vertical(size: 16),
              Text(
                AppStrings.orWith,
                style: AppStyles.bold(size: 14, color: AppColours.light20),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vertical(size: 16),
              ButtonComponent(
                icon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset("assets/images/google.png"),
                ),
                type: ButtonType.light,
                label: AppStrings.signupWithGoogle,
                onPressed: () => print("Sign up with google"),
              ),
              AppSpacing.vertical(size: 16),
              Text.rich(
                textAlign: TextAlign.center,
                style: AppStyles.medium(size: 14),
                TextSpan(
                  text: AppStrings.alreadyHaveAnAccount,
                  style: AppStyles.medium(size: 16, color: AppColours.light20),
                  children: [
                    WidgetSpan(child: AppSpacing.horizontal(size: 4)),
                    TextSpan(
                      text: AppStrings.login,
                      style: AppStyles.medium(
                        size: 16,
                        color: AppColours.primaryColour,
                      ).copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: AppColours.primaryColour,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signUpForm() {
    return Column(
      children: [
        TextInputComponent(
          error: _errors['name']?.join(', '),
          isEnabled: !_isLoading,
          focusNode: _nameFocus,
          label: AppStrings.name,
          textEditingController: _nameEditingController,
          textInputType: TextInputType.name,
          textInputAction: TextInputAction.next,
          isRequired: true,
          onFieldSubmitted:
              (value) => FocusScope.of(context).requestFocus(_emailFocus),
        ),
        AppSpacing.vertical(),
        TextInputComponent(
          error: _errors['email']?.join(', '),
          isEnabled: !_isLoading,
          focusNode: _emailFocus,
          label: AppStrings.emailAddress,
          textEditingController: _emailEditingController,
          textInputType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          isRequired: true,
        ),
        AppSpacing.vertical(),
        TextInputComponent(
          error: _errors['password']?.join(', '),
          isEnabled: !_isLoading,
          focusNode: _passwordFocus,
          label: AppStrings.password,
          isPassword: true,
          textEditingController: _passwordEditingController,
          textInputAction: TextInputAction.done,
          isRequired: true,
        ),
        AppSpacing.vertical(),
        CheckboxInputComponent(
          isEnable: !_isLoading,
          label: Text.rich(
            style: AppStyles.medium(size: 14),
            TextSpan(
              text: AppStrings.agreeText,
              children: [
                WidgetSpan(child: AppSpacing.horizontal(size: 4)),
                TextSpan(
                  text: AppStrings.termsAndPrivacy,
                  style: AppStyles.medium(
                    size: 14,
                    color: AppColours.primaryColour,
                  ),
                ),
              ],
            ),
          ),
          value: _hasAgreed,
          onChanged: (value) => setState(() => _hasAgreed = value),
        ),
      ],
    );
  }

  Future<void> _handleSignUp() async {
    setState(() => _errors = {});
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_hasAgreed) {
      Helper.snackBar(
        isSuccess: false,
        context,
        message: AppStrings.inputIsRequired.replaceAll(
          ':input',
          AppStrings.termsAndPrivacy,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    var result = await AuthController.register(
      _nameEditingController.text.trim(),
      _emailEditingController.text.trim(),
      _passwordEditingController.text,
    );

    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      print(result.errors);
      Helper.snackBar(context, message: result.message, isSuccess: false);
      if (result.errors != null) {
        setState(() => _errors = result.errors!);
      }
      return;
    }

    Navigator.pushNamed(context, AppRoutes.verification);
  }
}
