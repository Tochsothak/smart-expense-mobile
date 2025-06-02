import 'package:flutter/material.dart';
import 'package:smart_expense/controllers/auth_controller.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/form/checkbox_input.dart';
import 'package:smart_expense/views/components/form/text_input.dart';
import 'package:smart_expense/views/components/ui/button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameEditingController = TextEditingController();
  final TextEditingController emailEditingController = TextEditingController();
  final TextEditingController passwordEditingController =
      TextEditingController();
  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  bool isLoading = false;
  bool hasAgreed = false;

  Map<String, dynamic> errors = {};

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColours.bgColor,
        appBar: AppBar(
          backgroundColor: AppColours.bgColor,
          title: Text(AppStrings.signUp, style: AppStyles.appTitle()),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(24),
            children: [
              AppSpacing.vertical(size: 48),
              inputFields(),
              AppSpacing.vertical(),
              CheckboxInputComponent(
                isEnable: !isLoading,
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
                value: hasAgreed,
                onChanged: (value) => setState(() => hasAgreed = value),
              ),
              AppSpacing.vertical(),
              ButtonComponent(
                isLoading: isLoading,
                label: AppStrings.signUp,
                onPressed: signup,
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

  Widget inputFields() {
    return Column(
      children: [
        TextInputComponent(
          error: errors['name']?.join(', '),
          isEnabled: !isLoading,
          focusNode: nameFocus,
          label: AppStrings.name,
          textEditingController: nameEditingController,
          textInputType: TextInputType.name,
          textInputAction: TextInputAction.next,
          isRequired: true,
          onFieldSubmitted:
              (value) => FocusScope.of(context).requestFocus(emailFocus),
        ),
        AppSpacing.vertical(),
        TextInputComponent(
          error: errors['email']?.join(', '),
          isEnabled: !isLoading,
          focusNode: emailFocus,
          label: AppStrings.emailAddress,
          textEditingController: emailEditingController,
          textInputType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          isRequired: true,
        ),
        AppSpacing.vertical(),
        TextInputComponent(
          error: errors['password']?.join(', '),
          isEnabled: !isLoading,
          focusNode: passwordFocus,
          label: AppStrings.password,
          isPassword: true,
          textEditingController: passwordEditingController,
          textInputAction: TextInputAction.done,
          isRequired: true,
        ),
      ],
    );
  }

  Future<void> signup() async {
    setState(() => errors = {});
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!hasAgreed) {
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

    setState(() => isLoading = true);

    var result = await AuthController.register(
      nameEditingController.text.trim(),
      emailEditingController.text.trim(),
      passwordEditingController.text,
    );

    setState(() => isLoading = false);

    if (!result.isSuccess) {
      print(result.errors);
      Helper.snackBar(context, message: result.message, isSuccess: false);
      if (result.errors != null) {
        errors = result.errors!;
      }
      return;
    }

    Navigator.pushNamed(context, AppRoutes.verification);
  }
}
