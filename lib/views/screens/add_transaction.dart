import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_expense/data/list_money.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/form/select_input.dart';
import 'package:smart_expense/views/components/form/text_input.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';
import 'package:smart_expense/views/components/ui/button.dart';

class AddTranSactionScreen extends StatefulWidget {
  const AddTranSactionScreen({super.key});

  @override
  State<AddTranSactionScreen> createState() => _AddTranSactionScreenState();
}

class _AddTranSactionScreenState extends State<AddTranSactionScreen> {
  List items = ["Item1", "Item2", "Item3", "Item4"];
  String? selectedItem;
  String? type;

  final _formKey = GlobalKey<FormState>();
  final _balanceEditingController = TextEditingController();
  final _textEditingDescriptionController = TextEditingController();
  final _textEditingNoteController = TextEditingController();

  final _balanceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _noteFocus = FocusNode();

  final bool _isLoading = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as String;
    type = args;
  }

  @override
  Widget build(BuildContext context) {
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
                  offset: Offset(0, -120),
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
      height: MediaQuery.of(context).size.height / 1.6,
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
              label: AppStrings.category,
              items: geter().map((e) => e.name).toList(),
              compareFn: (p0, p1) => p0 == p1,
              onChanged: (value) {
                setState(() => selectedItem = value);
              },
            ),
            AppSpacing.vertical(),
            TextInputComponent(
              label: AppStrings.description,
              textEditingController: _textEditingDescriptionController,
              focusNode: _descriptionFocus,
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.text,
            ),
            AppSpacing.vertical(),
            SelectInputComponent(
              label: AppStrings.wallet,
              items: geter().map((e) => e.name).toList(),
              compareFn: (p0, p1) => p0 == p1,
              onChanged: (value) {
                setState(() => selectedItem = value);
              },
            ),
            AppSpacing.vertical(),
            TextInputComponent(
              label: AppStrings.noteOptional,
              textEditingController: _textEditingNoteController,
              focusNode: _noteFocus,
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.text,
            ),
            AppSpacing.vertical(),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showModalBottomSheet();
                    },
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.5,
                          color: AppColours.light20,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.attachment,
                            size: 24,
                            color: AppColours.light20,
                          ),
                          AppSpacing.horizontal(size: 6),
                          Text(
                            AppStrings.addAttachment,
                            style: AppStyles.regular1(
                              color: AppColours.light20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AppSpacing.horizontal(size: 8),
                GestureDetector(
                  onTap: _showDatePicker,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: AppColours.light20),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.date_range, color: Colors.grey),
                  ),
                ),
              ],
            ),
            Spacer(),
            ButtonComponent(
              label: AppStrings.continueText,
              type: type == 'expense' ? ButtonType.expense : ButtonType.income,
              onPressed: () {},
            ),
            AppSpacing.vertical(),
          ],
        ),
      ),
    );
  }

  _showDatePicker() {
    return showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(20025),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColours.primaryColour,
              surface: Colors.white,
            ),
          ),

          child: child!,
        );
      },
    );
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
                Text(
                  AppStrings.balance,
                  style: AppStyles.semibold(color: Colors.white.withAlpha(200)),
                ),
                Row(
                  children: [
                    Text(
                      'USD',
                      style: AppStyles.semibold(color: Colors.white, size: 48),
                    ),
                    AppSpacing.horizontal(size: 4),
                    Expanded(
                      child: TextFormField(
                        enabled: !_isLoading,
                        controller: _balanceEditingController,
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
            ),
          ),
        ),
      ],
    );
  }
}

class BottomSheetItem {
  final String text;
  final IconData icon;
  final Function() onTap;

  const BottomSheetItem({
    required this.text,
    required this.icon,
    required this.onTap,
  });
}
