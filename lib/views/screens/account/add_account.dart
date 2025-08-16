import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_expense/controllers/account.dart';
import 'package:smart_expense/controllers/account_type.dart';
import 'package:smart_expense/controllers/currency.dart';
import 'package:smart_expense/models/account_type.dart';
import 'package:smart_expense/models/currency.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/form/select_input.dart';
import 'package:smart_expense/views/components/form/text_input.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';
import 'package:smart_expense/views/components/ui/button.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

@override
class _AddAccountScreenState extends State<AddAccountScreen> {
  CurrencyModel? selectedCurrency;
  List<CurrencyModel> currencies = [];

  AccountTypeModel? selectedAccountType;
  List<AccountTypeModel> accountTypes = [];

  final _balanceEditingController = TextEditingController(text: '0');
  final _nameEditingController = TextEditingController();

  final FocusNode _balanceFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        backgroundColor: AppColours.primaryColour,
        appBar: buildAppBar(
          context,
          AppStrings.addNewAccount,
          backgroundColor: AppColours.primaryColour,
          foregroundColor: Colors.white,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(padding: EdgeInsets.all(24), child: _balanceForm()),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: _detailForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _balanceForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpacing.vertical(size: MediaQuery.of(context).size.height / 5),
        Text(
          AppStrings.balance,
          style: AppStyles.semibold(color: Colors.white.withAlpha(200)),
        ),
        Row(
          children: [
            Text(
              selectedCurrency?.code ?? '',
              style: AppStyles.semibold(color: Colors.white, size: 64),
            ),
            AppSpacing.horizontal(size: 4),
            Expanded(
              child: TextFormField(
                enabled: !_isLoading,
                controller: _balanceEditingController,
                focusNode: _balanceFocus,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: AppStyles.semibold(size: 64, color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorStyle: TextStyle(color: Colors.white),
                ),
                cursorColor: Colors.white,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'(^\d*[.,]?\d{0,3})'),
                  ),
                ],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.inputIsRequired.replaceAll(
                      ":input",
                      AppStrings.balance,
                    );
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailForm() {
    return Column(
      children: [
        TextInputComponent(
          isEnabled: !_isLoading,
          label: AppStrings.name,
          isRequired: true,
          textEditingController: _nameEditingController,
          focusNode: _nameFocus,
          textInputAction: TextInputAction.next,
          textInputType: TextInputType.name,
        ),
        AppSpacing.vertical(),
        SelectInputComponent(
          isEnabled: !_isLoading,
          isRequired: true,
          label: AppStrings.currency,
          searchBoxLabel: AppStrings.currency,
          items: currencies,
          compareFn: (item1, item2) => item1.isEqual(item2),
          selectedItem: selectedCurrency,
          showSearchBox: true,
          onChanged: (CurrencyModel? value) {
            setState(() => selectedCurrency = value);
          },
        ),
        AppSpacing.vertical(),
        SelectInputComponent(
          isEnabled: !_isLoading,
          isRequired: true,
          label: AppStrings.accountType,
          searchBoxLabel: AppStrings.accountType,
          showSearchBox: true,
          items: accountTypes,
          compareFn: (item1, item2) => item1.isEqual(item2),
          onChanged: (AccountTypeModel? value) {
            setState(() => selectedAccountType = value);
          },
        ),
        AppSpacing.vertical(),
        ButtonComponent(
          isLoading: _isLoading,
          label: AppStrings.continueText,
          onPressed: () {
            _handleSubmit();
          },
        ),
        AppSpacing.vertical(size: 80),
      ],
    );
  }

  _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final initialBalance = Helper.parseAmount(
      _balanceEditingController.text.trim(),
    );

    final result = await AccountController.create(
      initialBalance,
      _nameEditingController.text.trim(),
      selectedCurrency?.id ?? '',
      selectedAccountType?.id ?? '',
    );

    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      Helper.snackBar(context, message: result.message, isSuccess: false);
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.signUpSuccess,
      (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  _initScreen() {
    _loadCurrencies();
    _loadAccountTypes();
  }

  _loadCurrencies() async {
    final result = await CurrencyController.load();

    if (result.isSuccess && result.results != null) {
      setState(() => currencies = result.results!);
    }
  }

  _loadAccountTypes() async {
    final result = await AccountTypeController.load();
    if (result.isSuccess && result.results != null) {
      setState(() => accountTypes = result.results!);
    }
  }
}
