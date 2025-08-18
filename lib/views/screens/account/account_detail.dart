import 'package:flutter/material.dart';
import 'package:smart_expense/controllers/account.dart';
import 'package:smart_expense/models/account.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';
import 'package:smart_expense/views/components/ui/button.dart';
import 'package:smart_expense/views/components/ui/indecator.dart';

class AccountDetail extends StatefulWidget {
  const AccountDetail({super.key});

  @override
  State<AccountDetail> createState() => _AccountDetailState();
}

class _AccountDetailState extends State<AccountDetail> {
  AccountModel? accountModel;
  String? id;

  bool _isLoading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (id == null) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      if (arg != null && arg is String) {
        id = arg;
        _getAccount(id!);
      } else {
        setState(() {
          _error = "No account ID provided";
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getAccount(String accountId) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // print("Fetching account with ID: $accountId");

      final account = await AccountController.get({'id': accountId});

      // print("Account response : $account");
      // print("Account results : ${account!.results}");

      if (mounted) {
        setState(() {
          if (account?.results != null) {
            accountModel = account?.results;
            // print("Account model set : $accountModel");
          } else {
            _error = "Account not found";
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      // print("Error fetching accoutn: $e");
      if (mounted) {
        setState(() {
          _error = "Failed to load account $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.bgColor,
      appBar: buildAppBar(
        context,
        AppStrings.accountDetail,
        foregroundColor: Colors.white,
        backgroundColor: AppColours.primaryColour,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return MyIndecator();
    }

    if (_error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          AppSpacing.vertical(size: 16),
          Text(
            _error!,
            style: AppStyles.regular1(color: Colors.red.shade400),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vertical(size: 16),
          ButtonComponent(
            width: MediaQuery.of(context).size.width / 2,
            type: ButtonType.light,
            label: 'Retry',
            onPressed: () {
              if (id != null) {
                _getAccount(id!);
              }
            },
          ),
        ],
      );
    }
    if (accountModel == null) {
      return const Center(child: const Text("No account data available"));
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _header(),
        Positioned(
          top: 180,
          left: MediaQuery.of(context).size.width / 1.1 / 2 - 167,
          child: _body(),
        ),
        Positioned(
          top: 145,
          left: 70,
          child: IconButton(
            onPressed: _showDialog,
            icon: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              child: Icon(Icons.delete, size: 40),
            ),
          ),
        ),
        Positioned(
          top: 145,
          right: 70,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.updateAccount,
                arguments: accountModel as AccountModel,
              );
            },
            icon: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green.shade400,
              foregroundColor: Colors.white,
              child: Icon(Icons.edit, size: 40),
            ),
          ),
        ),
      ],
    );
  }

  _showDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: Text(
              AppStrings.areYouSureToDeleteAccount,
              style: AppStyles.medium(),
            ),
            actions: [
              TextButton(
                child: Text(AppStrings.cancel),
                onPressed: () => Navigator.of(context).pop(),
              ),

              TextButton(
                onPressed: _handleDelete,
                child: Text(AppStrings.okay),
              ),
            ],
          ),
    );
  }

  Future<bool> _handleDelete() async {
    try {
      await AccountController.delete({'id': id});
      Helper.snackBar(
        context,
        message: AppStrings.dataDeleteSuccess.replaceAll(
          ':data',
          AppStrings.account,
        ),
        isSuccess: true,
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.bottomNavigationBar,
        (Route<dynamic> route) => false,
      );

      return true;
    } catch (e) {
      Helper.snackBar(
        context,
        message: AppStrings.failToDeleteData.replaceAll(
          ':data',
          AppStrings.account,
        ),
      );
      return false;
    }
  }

  Widget _body() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.1,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.5, 0.5),
            blurRadius: 1,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            AppSpacing.vertical(size: 48),
            _buildRow(AppStrings.name, accountModel?.name),
            SizedBox(child: Divider(color: Colors.grey.shade300)),
            _buildRow(AppStrings.accountType, accountModel?.accountType.name),
            SizedBox(child: Divider(color: Colors.grey.shade300)),
            _buildRow(
              AppStrings.currency,
              "${accountModel?.currency.name} (${accountModel?.currency.code})",
            ),
            SizedBox(child: Divider(color: Colors.grey.shade300)),
            _buildRow(AppStrings.totalIncome, accountModel?.totalIncomeText),
            SizedBox(child: Divider(color: Colors.grey.shade300)),
            _buildRow(AppStrings.totalExpense, accountModel?.totalExpenseText),
            SizedBox(child: Divider(color: Colors.grey.shade300)),
            _buildRow(
              AppStrings.transactionCount,
              accountModel?.transactionCount.toString(),
            ),
            SizedBox(child: Divider(color: Colors.grey.shade300)),
            _buildRow(
              AppStrings.incomeCount,
              accountModel?.incomeCount.toString(),
            ),
            SizedBox(child: Divider(color: Colors.grey.shade300)),
            _buildRow(
              AppStrings.expenseCount,
              accountModel?.expenseCount.toString(),
            ),
            AppSpacing.vertical(size: 16),
          ],
        ),
      ),
    );
  }

  Row _buildRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: AppStyles.regular1(color: AppColours.light20),
          ),
        ),
        SizedBox(
          height: 50,
          child: VerticalDivider(color: Colors.grey.withAlpha(50)),
        ),
        Expanded(
          child: Text(
            value ?? "Cash",
            style: AppStyles.regular1(color: AppColours.light20),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColours.primaryColour,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 48, left: 15, right: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.initialBalance,
                    style: AppStyles.medium(
                      color: Colors.grey.shade50.withAlpha(700),
                      size: 14,
                    ),
                  ),
                  AppSpacing.vertical(size: 16),
                  Text(
                    accountModel?.initialBalanceText ?? "\$0",
                    style: AppStyles.title1(color: Colors.white, size: 24),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
              child: VerticalDivider(
                thickness: 5,
                color: Colors.grey.shade100.withAlpha(800),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.currentBalance,
                    style: AppStyles.medium(
                      color: Colors.grey.shade50.withAlpha(700),
                      size: 14,
                    ),
                  ),
                  AppSpacing.vertical(size: 16),
                  Expanded(
                    child: Text(
                      accountModel?.currentBalanceText ?? "\$ 0",
                      style: AppStyles.title1(color: Colors.white, size: 24),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
