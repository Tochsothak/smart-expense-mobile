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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController =
      TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _isLoading = false;

  Map<String, dynamic> _errors = {};

  @override
  void dispose() {
    _emailEditingController.dispose();
    _passwordEditingController.dispose();

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
        appBar: buildAppBar(context, AppStrings.login),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(24),
            children: [
              AppSpacing.vertical(size: 48),
              _loginForm(),
              AppSpacing.vertical(),
              ButtonComponent(
                isLoading: _isLoading,
                label: AppStrings.login,
                onPressed: _handleLogin,
              ),
              AppSpacing.vertical(),
              InkWell(
                onTap:
                    () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.forgotPassword),
                child: Text(
                  AppStrings.forgotPassword,
                  style: AppStyles.title3(color: AppColours.primaryColour),
                  textAlign: TextAlign.center,
                ),
              ),
              AppSpacing.vertical(size: 16),

              Text.rich(
                textAlign: TextAlign.center,
                style: AppStyles.medium(size: 14),
                TextSpan(
                  text: AppStrings.dontHaveAnAccountYet,
                  style: AppStyles.medium(size: 16, color: AppColours.light20),
                  children: [
                    WidgetSpan(child: AppSpacing.horizontal(size: 4)),
                    WidgetSpan(
                      child: InkWell(
                        onTap:
                            () => Navigator.of(
                              context,
                            ).pushReplacementNamed(AppRoutes.signup),
                        child: Text(
                          AppStrings.signUp,
                          style: AppStyles.medium(
                            size: 16,
                            color: AppColours.primaryColour,
                          ).copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: AppColours.primaryColour,
                          ),
                        ),
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

  Widget _loginForm() {
    return Column(
      children: [
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
      ],
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _errors = {});

    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    var result = await AuthController.login(
      _emailEditingController.text.trim(),
      _passwordEditingController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      Helper.snackBar(context, message: result.message, isSuccess: false);
      if (result.errors != null) {
        setState(() => _errors = result.errors!);
      }
      return;
    }

    if (result.results?.emailVerifiedAt == null) {
      Navigator.of(context).pushNamed(AppRoutes.verification);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (Route<dynamic> route) => false,
      );
    }
  }
}
