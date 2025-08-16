import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_expense/controllers/account.dart';
import 'package:smart_expense/controllers/category.dart';
import 'package:smart_expense/controllers/transaction.dart';
import 'package:smart_expense/models/account.dart';
import 'package:smart_expense/models/category.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/bottom_sheet.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/form/select_input.dart';
import 'package:smart_expense/views/components/form/text_input.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';
import 'package:smart_expense/views/components/ui/button.dart';
import 'package:smart_expense/views/components/ui/type_toggle.dart';

class AddTranSactionScreen extends StatefulWidget {
  const AddTranSactionScreen({super.key});

  @override
  State<AddTranSactionScreen> createState() => _AddTranSactionScreenState();
}

class _AddTranSactionScreenState extends State<AddTranSactionScreen> {
  String type = '';

  final _formKey = GlobalKey<FormState>();
  final _amountEditingController = TextEditingController();
  final _textEditingDescriptionController = TextEditingController();
  final _textEditingNoteController = TextEditingController();
  final _textEditingDateTimeController = TextEditingController(
    text: Helper.dateFormat(DateTime.now()),
  );

  final _balanceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _noteFocus = FocusNode();
  final _dateTimeFocus = FocusNode();

  List<AccountModel> accounts = [];
  List<CategoryModel> categories = [];

  AccountModel? selectedAccount;
  CategoryModel? selectedCategory;

  bool _isLoading = false;
  bool _initializing = false;

  bool? _toggleType;

  List<BottomSheetItem> bottomSheetItem = [
    BottomSheetItem(
      text: AppStrings.camera,
      icon: Icons.camera_alt,
      onTap: () {
        print("Camera");
      },
    ),
    BottomSheetItem(
      text: AppStrings.image,
      icon: Icons.image,
      onTap: () {
        print("image");
      },
    ),
    BottomSheetItem(
      text: AppStrings.document,
      icon: Icons.document_scanner,
      onTap: () {
        print("document");
      },
    ),
  ];

  @override
  void dispose() {
    super.dispose();

    _amountEditingController.dispose();
    _textEditingDescriptionController.dispose();
    _textEditingNoteController.dispose();
    _textEditingDateTimeController.dispose();
    _balanceFocus.dispose();
    _descriptionFocus.dispose();
    _noteFocus.dispose();
    _dateTimeFocus.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as String;
    type = args;
    _initScreen();
  }

  _initScreen() async {
    setState(() => _initializing = true);
    await Future.wait(
      [_loadAccounts(), _loadCategory(), _initializing = false]
          as Iterable<Future>,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return Scaffold(
        backgroundColor: AppColours.bgColor,
        appBar: buildAppBar(
          context,
          type == 'expense' ? AppStrings.addExpense : AppStrings.addIncome,
          backgroundColor:
              type == 'expense' ? Colors.red.shade400 : Colors.green.shade400,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color:
                type == 'expense' ? Colors.red.shade400 : Colors.green.shade400,
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColours.bgColor,
        appBar: buildAppBar(
          context,
          type == 'expense' ? AppStrings.addExpense : AppStrings.addIncome,
          backgroundColor:
              type == 'expense' ? Colors.red.shade400 : Colors.green.shade400,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _balanceForm(),
                Transform.translate(
                  offset: Offset(0, -105),
                  child: _detailForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _detailForm() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      height: MediaQuery.of(context).size.height / 1.3,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 0.1),
            blurRadius: 5,
            spreadRadius: 0.1,
            color: AppColours.light20,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            AppSpacing.vertical(),
            SelectInputComponent(
              isRequired: true,
              isEnabled: !_isLoading,
              label: AppStrings.wallet,
              items: accounts,
              selectedItem: selectedAccount,
              compareFn: (p0, p1) => p0 == p1,
              onChanged: (AccountModel? value) {
                setState(() => selectedAccount = value);
              },
            ),
            AppSpacing.vertical(),
            SelectInputComponent(
              isRequired: true,
              isEnabled: !_isLoading,
              label: AppStrings.category,
              items: categories,
              selectedItem: selectedCategory,
              compareFn: (p0, p1) => p0 == p1,
              onChanged: (CategoryModel? value) {
                setState(() => selectedCategory = value);
              },
            ),
            AppSpacing.vertical(),
            TextInputComponent(
              isRequired: true,
              isEnabled: !_isLoading,
              label: AppStrings.description,
              textEditingController: _textEditingDescriptionController,
              focusNode: _descriptionFocus,
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.text,
            ),

            AppSpacing.vertical(),
            TextInputComponent(
              isEnabled: !_isLoading,
              label: AppStrings.noteOptional,
              textEditingController: _textEditingNoteController,
              focusNode: _noteFocus,
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.text,
            ),
            AppSpacing.vertical(),
            TextInputComponent(
              isEnabled: !_isLoading,
              label: AppStrings.date,
              textEditingController: _textEditingDateTimeController,
              focusNode: _dateTimeFocus,
              textInputAction: TextInputAction.done,
              textInputType: TextInputType.datetime,
              readOnly: true,
              onTap: _selectDate,
              prefixIcon: Icon(Icons.date_range, color: AppColours.light20),
            ),
            AppSpacing.vertical(),
            GestureDetector(
              onTap: () {
                _showModalBottomSheet();
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: AppColours.light20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attachment, size: 24, color: AppColours.light20),
                    AppSpacing.horizontal(size: 6),
                    Text(
                      AppStrings.addAttachment,
                      style: AppStyles.regular1(color: AppColours.light20),
                    ),
                  ],
                ),
              ),
            ),

            Spacer(),

            ButtonComponent(
              isLoading: _isLoading,
              label: AppStrings.continueText,
              type: type == 'expense' ? ButtonType.expense : ButtonType.income,
              onPressed: _handleSubmit,
            ),
            AppSpacing.vertical(),
          ],
        ),
      ),
    );
  }

  Future _selectDate() async {
    DateTime? pickDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (pickDate != null) {
      _textEditingDateTimeController.text = Helper.dateFormat(pickDate);
    }
    return pickDate;
  }

  _showModalBottomSheet() {
    return showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            height: 150,
            decoration: BoxDecoration(
              color:
                  type == 'expense'
                      ? Colors.red.shade400
                      : Colors.green.shade400,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...bottomSheetItem.map((b) {
                    return GestureDetector(
                      onTap: b.onTap,
                      child: Container(
                        height: 100,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                b.icon,
                                color:
                                    type == 'expense'
                                        ? Colors.red.shade400
                                        : Colors.green.shade400,
                                size: 50,
                              ),
                              Text(
                                b.text,
                                style: AppStyles.medium(
                                  color:
                                      type == 'expense'
                                          ? Colors.red.shade400
                                          : Colors.green.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
    );
  }

  Column _balanceForm() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width / 1.5,
          decoration: BoxDecoration(
            color:
                type == 'expense' ? Colors.red.shade400 : Colors.green.shade400,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.vertical(size: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.amount,
                      style: AppStyles.semibold(
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                    TypeToggle(
                      onTap: () {
                        if (type == 'expense') {
                          setState(() => type = 'income');
                        } else if (type == 'income') {
                          setState(() => type = 'expense');
                        }
                      },
                      expenseBackgroundColor:
                          type == 'expense'
                              ? Colors.red.shade400
                              : Colors.transparent,
                      incomeBackgroundColor:
                          type == 'income'
                              ? Colors.green.shade400
                              : Colors.transparent,
                      expenseTextStyle: AppStyles.medium(
                        color:
                            type == 'expense'
                                ? Colors.white
                                : AppColours.light20,
                        size: type == 'expense' ? 16 : 12,
                      ),
                      incomeTextStyle: AppStyles.medium(
                        color:
                            type == 'income'
                                ? Colors.white
                                : AppColours.light20,
                        size: type == 'income' ? 16 : 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      selectedAccount?.currency.code ?? '',
                      style: AppStyles.semibold(color: Colors.white, size: 48),
                    ),
                    AppSpacing.horizontal(size: 4),
                    Expanded(
                      child: TextFormField(
                        enabled: !_isLoading,
                        controller: _amountEditingController,
                        focusNode: _balanceFocus,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: AppStyles.semibold(
                          size: 48,
                          color: Colors.white,
                        ),
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
                              AppStrings.amount,
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _loadAccounts() async {
    final result = await AccountController.load();
    if (result.isSuccess && result.results != null) {
      setState(() => accounts = result.results!);
    }
  }

  _loadCategory() async {
    final result = await CategoryController.load();
    if (result.isSuccess && result.results != null) {
      setState(() => categories = result.results!);
    }
  }

  _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      Helper.snackBar(
        context,
        message: "Please complete the form ",
        isSuccess: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    final amount = Helper.parseAmount(_amountEditingController.text.trim());

    final result = await TransactionController.create(
      selectedAccount?.id ?? '',
      amount,
      selectedCategory?.id ?? '',
      _textEditingDescriptionController.text.trim(),
      type,
      _textEditingDateTimeController.text,
      _textEditingNoteController.text.trim(),
    );

    setState(() => _isLoading = false);

    print("Result : $result");

    if (!result.isSuccess) {
      Helper.snackBar(context, message: result.message, isSuccess: false);
      return;
    }

    Helper.snackBar(
      context,
      isSuccess: true,
      message: AppStrings.dataAddSuccess.replaceAll(
        ":data",
        AppStrings.transaction,
      ),
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.bottomNavigationBar,
      (Route<dynamic> route) => false,
    );
  }
}
