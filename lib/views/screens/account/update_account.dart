import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_expense/controllers/account.dart';
import 'package:smart_expense/controllers/account_type.dart';
import 'package:smart_expense/models/account.dart';
import 'package:smart_expense/models/account_type.dart';
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
import 'package:smart_expense/views/components/ui/indecator.dart';

class UpdateAccount extends StatefulWidget {
  const UpdateAccount({super.key});

  @override
  State<UpdateAccount> createState() => _UpdateAccountState();
}

class _UpdateAccountState extends State<UpdateAccount> {
  String? accountId;

  String? selectedCurrency;

  AccountModel? currentAccount;

  AccountTypeModel? selectedAccountType;

  List<AccountTypeModel> accountTypes = [];

  final _balanceEditingController = TextEditingController(text: '0');
  final _nameEditingController = TextEditingController();

  final FocusNode _balanceFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isInitializing = true;
  @override
  void dispose() {
    super.dispose();
    _balanceEditingController.dispose();
    _nameEditingController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (accountId == null) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      if (arg != null && arg is String) {
        accountId = arg;
        _loadAccountData();
        _loadAccountType();
        print(accountId);
      } else {
        setState(() => _isInitializing = false);
      }
    }
  }

  _loadAccountData() async {
    if (accountId == null) return;
    setState(() => _isInitializing = true);

    try {
      final result = await AccountController.get({'id': accountId!});

      if (result!.isSuccess && result.results != null) {
        currentAccount = result.results;
        _nameEditingController.text = currentAccount!.name;
        _balanceEditingController.text =
            currentAccount!.currentBalance.toString();

        selectedAccountType = currentAccount?.accountType;
        selectedCurrency = currentAccount?.currency.code.toString();
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      Helper.snackBar(
        context,
        message: AppStrings.failedToLoadData.replaceAll(
          ':data',
          AppStrings.account,
        ),
        isSuccess: false,
      );
      setState(() => _isInitializing = false);
    }
  }

  _handleUpdate(String id) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final initialBalance = Helper.parseAmount(
        _balanceEditingController.text.trim(),
      );

      final result = await AccountController.update(
        {'id': id},
        selectedAccountType?.id ?? '',
        _nameEditingController.text.trim(),
        initialBalance,
        1,
      );

      print(result.results);

      setState(() => _isLoading = false);

      if (!result.isSuccess) {
        Helper.snackBar(context, message: result.message, isSuccess: false);
        return;
      }
      Helper.snackBar(
        context,
        message: AppStrings.dataUpdatedSuccess.replaceAll(
          ':data',
          AppStrings.account,
        ),
        isSuccess: true,
      );

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.bottomNavigationBar,
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      Helper.snackBar(context, message: e.toString(), isSuccess: false);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        appBar: buildAppBar(
          context,
          AppStrings.updateAccount,
          backgroundColor: AppColours.primaryColour,
          foregroundColor: Colors.white,
        ),
        body: MyIndecator(),
      );
    }
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        backgroundColor: AppColours.primaryColour,
        appBar: buildAppBar(
          context,
          AppStrings.updateAccount,
          backgroundColor: AppColours.primaryColour,
          foregroundColor: Colors.white,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(padding: EdgeInsets.all(24), child: _balanceForm('')),
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

  Widget _balanceForm(String currency) {
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
              selectedCurrency ?? '',
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
        AppSpacing.vertical(size: 16),
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
          selectedItem: selectedAccountType,
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
            _handleUpdate(accountId!);
          },
        ),
        AppSpacing.vertical(size: 100),
      ],
    );
  }

  _loadAccountType() async {
    final result = await AccountTypeController.load();
    if (result.isSuccess && result.results != null) {
      setState(() {
        accountTypes = result.results!;
      });
    }
  }
}
